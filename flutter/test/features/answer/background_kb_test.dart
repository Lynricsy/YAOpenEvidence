import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:yaopenevidence/core/api/api_client.dart';
import 'package:yaopenevidence/core/logic/ask_rail.dart';
import 'package:yaopenevidence/core/session/session_controller.dart';
import 'package:yaopenevidence/features/answer/background_kb.dart';

String _job(String id, String kind, String status, {String body = ''}) =>
    jsonEncode({
      'id': id,
      'kind': kind,
      'status': status,
      'created_at': '2026-09-19T00:00:00Z',
      if (body.isNotEmpty) ...jsonDecode(body) as Map<String, dynamic>,
    });

ProviderContainer _container(
  Future<http.Response> Function(http.Request request) handler,
) {
  final client = ApiClient(
    baseUrl: Uri.parse('http://127.0.0.1:8765'),
    token: () => 'token',
    onUnauthorized: () {},
    client: MockClient(handler),
  );
  final container = ProviderContainer(
    overrides: [apiClientProvider.overrideWithValue(client)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('父任务的 kb_job_id 指向子任务，取其状态与篇数', () async {
    final container = _container((request) async {
      if (request.url.path.endsWith('/jobs/parent')) {
        return http.Response(
          _job(
            'parent',
            'ask',
            'succeeded',
            body: '{"result":{"kb_job_id":"kb1"}}',
          ),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      expect(request.url.path, endsWith('/jobs/kb1'));
      return http.Response(
        _job(
          'kb1',
          'answer_kb',
          'running',
          body: '{"progress":{"stage":"kb","current":3,"total":10}}',
        ),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    expect(
      await container.read(backgroundKbWatcherProvider('parent').future),
      const BackgroundKb(status: KbStatus.running, current: 3, total: 10),
    );
  });

  test('父任务没有挂出 kb_job_id 时不给节点任何状态', () async {
    final container = _container(
      (request) async => http.Response(
        _job('parent', 'ask', 'succeeded'),
        200,
        headers: {'content-type': 'application/json'},
      ),
    );

    expect(
      await container.read(backgroundKbWatcherProvider('parent').future),
      isNull,
    );
  });

  test('请求失败收敛为 unknown，而不是「没有任务」', () async {
    final container = _container(
      (request) async => http.Response('{"detail":"boom"}', 500),
    );

    expect(
      await container.read(backgroundKbWatcherProvider('parent').future),
      BackgroundKb.unknown,
    );
  });
}
