import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/problem.dart';
import 'api_error.dart';
import 'query_encoding.dart';
import 'sse.dart';

/// 一次请求的描述。[path] 不含 `/v1` 前缀，由 [ApiClient] 统一拼接。
class ApiRequest {
  const ApiRequest({
    this.method = 'GET',
    required this.path,
    this.query = const <String, Object?>{},
    this.body,
    this.requiresAuth = true,
    this.acceptStatuses = const <int>{},
  });

  final String method;
  final String path;
  final Map<String, Object?> query;

  /// 会被 `jsonEncode` 编码的请求体（模型的 `toJson()` 结果）。
  final Object? body;
  final bool requiresAuth;

  /// 除 2xx 之外也视为成功、需要按正常模型解码的状态码（如就绪探针的 503）。
  final Set<int> acceptStatuses;
}

/// 后端 REST + SSE 客户端。鉴权令牌由宿主提供，401 统一回调宿主清理会话。
class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.token,
    required this.onUnauthorized,
    http.Client? client,
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null;

  final Uri baseUrl;

  /// 当前会话令牌提供者；未登录返回 null。
  final String? Function() token;

  /// 非登录端点收到 401 时回调宿主清理会话。
  final void Function() onUnauthorized;

  final http.Client _client;
  final bool _ownsClient;

  /// 知识库首次检索要加载嵌入模型，约 15 秒；留足余量。
  static const requestTimeout = Duration(seconds: 60);

  /// 心跳约 15 秒一次；90 秒无任何字节才判定为断流。
  static const streamIdleTimeout = Duration(seconds: 90);

  void close() {
    if (_ownsClient) _client.close();
  }

  Future<T> json<T>(ApiRequest request, T Function(Object?) decode) async {
    final response = await _send(request, accept: 'application/json');
    final Object? payload;
    try {
      payload = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (error) {
      throw Decoding(error);
    }
    try {
      return decode(payload);
    } catch (error) {
      throw Decoding(error);
    }
  }

  Future<String> text(ApiRequest request) async {
    final response = await _send(request, accept: 'text/markdown');
    return utf8.decode(response.bodyBytes);
  }

  Future<void> noContent(ApiRequest request) async {
    await _send(request, accept: 'application/json');
  }

  /// 订阅任务事件流。断线重连由调用方负责（传入上一次收到的 `Last-Event-ID`）。
  /// [onOpen] 在响应头到达且状态为 2xx 时回调一次，供 UI 点亮连接指示灯。
  Stream<SseEvent> events({
    required String jobId,
    required String lastEventId,
    void Function()? onOpen,
  }) async* {
    final path = '/jobs/${encodePathComponent(jobId)}/events';
    final request = http.Request('GET', _uri(path, const {}));
    request.headers['Accept'] = 'text/event-stream';
    request.headers['Last-Event-ID'] = lastEventId;
    final token = this.token();
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    final http.StreamedResponse response;
    try {
      response = await _client.send(request);
    } on ApiError {
      rethrow;
    } catch (error) {
      throw Transport(error);
    }

    if (!_isSuccess(response.statusCode, const {})) {
      List<int> body;
      try {
        body = await response.stream.toBytes();
      } catch (_) {
        body = const [];
      }
      throw _failure(
        status: response.statusCode,
        headers: response.headers,
        body: body,
        path: path,
      );
    }
    onOpen?.call();

    final parser = SseParser();
    final chunks = utf8.decoder.bind(response.stream.timeout(streamIdleTimeout));
    try {
      await for (final chunk in chunks) {
        for (final event in parser.feed(chunk)) {
          yield event;
        }
      }
    } on ApiError {
      rethrow;
    } catch (error) {
      throw Transport(error);
    }
    for (final event in parser.flush()) {
      yield event;
    }
  }

  Future<http.Response> _send(
    ApiRequest request, {
    required String accept,
  }) async {
    final httpRequest = http.Request(request.method, _uri(request.path, request.query));
    httpRequest.headers['Accept'] = accept;
    if (request.body != null) {
      httpRequest.headers['Content-Type'] = 'application/json';
      httpRequest.bodyBytes = utf8.encode(jsonEncode(request.body));
    }
    final token = this.token();
    if (request.requiresAuth && token != null) {
      httpRequest.headers['Authorization'] = 'Bearer $token';
    }

    final http.Response response;
    try {
      response = await _client
          .send(httpRequest)
          .then(http.Response.fromStream)
          .timeout(requestTimeout);
    } on ApiError {
      rethrow;
    } catch (error) {
      throw Transport(error);
    }

    if (!_isSuccess(response.statusCode, request.acceptStatuses)) {
      throw _failure(
        status: response.statusCode,
        headers: response.headers,
        body: response.bodyBytes,
        path: request.path,
      );
    }
    return response;
  }

  Uri _uri(String path, Map<String, Object?> query) {
    final base = baseUrl.toString().replaceFirst(RegExp(r'/+$'), '');
    final qs = encodeQuery(query);
    return Uri.parse('$base/v1$path${qs.isEmpty ? '' : '?$qs'}');
  }

  bool _isSuccess(int status, Set<int> alsoAccept) =>
      (status >= 200 && status < 300) || alsoAccept.contains(status);

  /// 非 2xx → [HttpProblem]；登录端点自身的 401 不触发会话失效。
  ApiError _failure({
    required int status,
    required Map<String, String> headers,
    required List<int> body,
    required String path,
  }) {
    if (status == 401 && path != '/auth/login') onUnauthorized();
    final retryAfterRaw = int.tryParse(headers['retry-after'] ?? '');
    final retryAfter = (retryAfterRaw != null && retryAfterRaw > 0)
        ? retryAfterRaw
        : null;

    String text;
    try {
      text = utf8.decode(body);
    } catch (_) {
      text = '';
    }
    Problem? problem;
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map<String, Object?>) problem = Problem.fromJson(decoded);
    } catch (_) {
      problem = null;
    }
    if (problem == null) {
      final trimmed = text.trim();
      return HttpProblem(
        status: status,
        code: 'internal_error',
        detail: trimmed.length > 200 ? trimmed.substring(0, 200) : trimmed,
        retryAfter: retryAfter,
      );
    }
    return HttpProblem(
      status: status,
      code: problem.code ?? 'internal_error',
      detail: problem.detail ?? '',
      errors: problem.errors,
      retryAfter: retryAfter,
    );
  }
}
