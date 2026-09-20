import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:picoseek/core/api/api_client.dart';
import 'package:picoseek/core/api/api_error.dart';
import 'package:picoseek/core/api/endpoints.dart';
import 'package:picoseek/core/models/kb.dart';

ApiClient clientFor(
  MockClient mock, {
  String? token = 'token',
  void Function()? onUnauthorized,
}) => ApiClient(
  baseUrl: Uri.parse('http://127.0.0.1:8765'),
  token: () => token,
  onUnauthorized: onUnauthorized ?? () {},
  client: mock,
);

http.Response jsonResponse(
  String body, {
  int status = 200,
  String contentType = 'application/json',
  Map<String, String> headers = const {},
}) => http.Response(
  body,
  status,
  headers: {'content-type': contentType, ...headers},
);

void main() {
  test('查询参数里的加号、空格与中文都被百分号转义', () async {
    late Uri seen;
    late Map<String, String> headers;
    final client = clientFor(
      MockClient((request) async {
        seen = request.url;
        headers = request.headers;
        return jsonResponse('{"query":"x","items":[]}');
      }),
    );

    await client.kbSearch(q: 'a+b c中', kind: KbKind.fact, topK: 5);

    final query = seen.query;
    expect(query, contains('q=a%2Bb%20c%E4%B8%AD'));
    expect(query, contains('top_k=5'));
    expect(query, contains('kind=fact'));
    expect(seen.path, '/v1/kb/search');
    expect(headers['Authorization'], 'Bearer token');
  });

  test('就绪探针 503 仍按业务模型解码，且不带鉴权头', () async {
    late Map<String, String> headers;
    final client = clientFor(
      MockClient((request) async {
        headers = request.headers;
        return jsonResponse('''
{"status":"degraded","checks":{
"db":{"ok":false,"detail":"database is locked"},
"redis":{"ok":true,"detail":"ok"},
"llm":{"ok":true,"detail":"ok"},
"kb":{"ok":true,"detail":"ok"},
"ranks":{"ok":true,"detail":"ok"}}}''', status: 503);
      }),
    );

    final readiness = await client.ready();
    expect(readiness.status, 'degraded');
    expect(readiness.checks.db.ok, isFalse);
    expect(readiness.checks.db.detail, 'database is locked');
    expect(headers.containsKey('Authorization'), isFalse);
  });

  test('普通端点的 409 仍解析为 Problem 文案', () async {
    final client = clientFor(
      MockClient(
        (request) async => jsonResponse(
          '{"type":"urn:picoseek:error:conflict","title":"Conflict",'
          '"status":409,"detail":"answer is active","code":"conflict"}',
          status: 409,
          contentType: 'application/problem+json',
        ),
      ),
    );

    final error =
        await client.deleteAnswer('x').then<Object?>(
              (_) => null,
              onError: (Object e) => e,
            )
            as ApiError;
    expect(error, isA<HttpProblem>());
    expect(error.status, 409);
    expect(error.code, 'conflict');
    expect(error.userMessage, '当前状态不允许该操作');
  });

  test('非登录端点 401 触发一次会话失效回调，登录端点不触发', () async {
    var calls = 0;
    final client = clientFor(
      MockClient(
        (request) async => jsonResponse(
          '{"status":401,"code":"unauthenticated","detail":"invalid token"}',
          status: 401,
          contentType: 'application/problem+json',
        ),
      ),
      onUnauthorized: () => calls++,
    );

    await client.me().catchError((Object e) => throw e).then<void>(
      (_) {},
      onError: (Object _) {},
    );
    expect(calls, 1);

    await client
        .login(username: 'u', password: 'p')
        .then<void>((_) {}, onError: (Object _) {});
    expect(calls, 1);
  });

  test('登录限流的 Retry-After 进入错误文案', () async {
    final client = clientFor(
      MockClient(
        (request) async => jsonResponse(
          '{"status":429,"code":"login_rate_limited","detail":"slow down"}',
          status: 429,
          contentType: 'application/problem+json',
          headers: {'retry-after': '42'},
        ),
      ),
    );

    final error =
        await client.login(username: 'u', password: 'p').then<Object?>(
          (_) => null,
          onError: (Object e) => e,
        )
            as ApiError;
    expect(error.retryAfter, 42);
    expect(error.userMessage, '登录尝试过多，请 42 秒后再试');
  });

  test('events 带 Last-Event-ID 与 SSE Accept 头并解析出一帧', () async {
    late Map<String, String> headers;
    late Uri seen;
    final client = clientFor(
      MockClient((request) async {
        headers = request.headers;
        seen = request.url;
        return http.Response(
          'id: 2-0\nevent: stage\ndata: {"stage":"search","status":"started"}\n\n',
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      }),
    );

    var opened = 0;
    final events = await client
        .events(jobId: 'j 1', lastEventId: '1-0', onOpen: () => opened++)
        .toList();

    expect(seen.path, '/v1/jobs/j%201/events');
    expect(headers['Last-Event-ID'], '1-0');
    expect(headers['Accept'], 'text/event-stream');
    expect(opened, 1);
    expect(events, hasLength(1));
    expect(events.single.id, '2-0');
    expect(events.single.event, 'stage');
    expect(
      jsonDecode(events.single.data),
      {'stage': 'search', 'status': 'started'},
    );
  });

  test('传输层异常包装为 Transport', () async {
    final client = clientFor(
      MockClient((request) async => throw const SocketExceptionStub()),
    );
    final error = await client.health().then<Object?>(
      (_) => null,
      onError: (Object e) => e,
    );
    expect(error, isA<Transport>());
    expect((error! as ApiError).userMessage, '网络连接失败，请稍后重试');
  });
}

class SocketExceptionStub implements Exception {
  const SocketExceptionStub();
}
