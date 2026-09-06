import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:yaopenevidence/core/api/api_client.dart';
import 'package:yaopenevidence/core/logic/job_live.dart';
import 'package:yaopenevidence/core/session/session_controller.dart';
import 'package:yaopenevidence/features/answer/job_live_monitor.dart';

/// 记录每次事件流请求发生的时刻，用于校验退避节奏。
class _Recorder {
  final List<Duration> eventCalls = [];
  final List<Duration> probeCalls = [];
}

http.StreamedResponse _sse(String body, {int status = 200}) =>
    http.StreamedResponse(
      Stream.value(utf8.encode(body)),
      status,
      headers: {'content-type': 'text/event-stream'},
    );

ProviderContainer _container({
  required _Recorder recorder,
  required FakeAsync async,
  String? eventBody,
  int probeStatus = 200,
}) {
  final client = ApiClient(
    baseUrl: Uri.parse('http://127.0.0.1:8765'),
    token: () => 'token',
    onUnauthorized: () {},
    client: MockClient.streaming((request, body) async {
      if (request.url.path.endsWith('/events')) {
        recorder.eventCalls.add(async.elapsed);
        return _sse(eventBody ?? '');
      }
      recorder.probeCalls.add(async.elapsed);
      return http.StreamedResponse(
        Stream.value(utf8.encode('{"code":"unauthenticated"}')),
        probeStatus,
        headers: {'content-type': 'application/json'},
      );
    }),
  );
  return ProviderContainer(
    overrides: [apiClientProvider.overrideWithValue(client)],
  );
}

void main() {
  test('断流后按 1→2→4 s 退避重连，封顶 10 s', () {
    fakeAsync((async) {
      final recorder = _Recorder();
      final container = _container(
        recorder: recorder,
        async: async,
        probeStatus: 200,
      );
      addTearDown(container.dispose);
      container.listen(
        jobLiveMonitorProvider('j1'),
        (previous, next) {},
        fireImmediately: true,
      );

      async.elapse(const Duration(seconds: 40));
      final gaps = [
        for (var i = 1; i < recorder.eventCalls.length; i++)
          recorder.eventCalls[i] - recorder.eventCalls[i - 1],
      ];
      expect(recorder.eventCalls.length, greaterThan(4));
      expect(gaps.take(4), [
        const Duration(seconds: 1),
        const Duration(seconds: 2),
        const Duration(seconds: 4),
        const Duration(seconds: 8),
      ]);
      // 封顶 10 s：第 5 次之后不再增长。
      expect(gaps.skip(4).take(2), everyElement(const Duration(seconds: 10)));
      // 每次重连前都先探活（末次探活可能落在观察窗内，也可能刚好在窗外）。
      expect(
        recorder.probeCalls.length,
        greaterThanOrEqualTo(recorder.eventCalls.length - 1),
      );
    });
  });

  test('探活返回 401 时直接收摊', () {
    fakeAsync((async) {
      final recorder = _Recorder();
      final container = _container(
        recorder: recorder,
        async: async,
        probeStatus: 401,
      );
      addTearDown(container.dispose);
      container.listen(
        jobLiveMonitorProvider('j1'),
        (previous, next) {},
        fireImmediately: true,
      );

      async.elapse(const Duration(seconds: 30));
      expect(
        container.read(jobLiveMonitorProvider('j1')).connection,
        SseConnection.closed,
      );
      expect(recorder.eventCalls, hasLength(1));
    });
  });

  test('收到 succeeded 后不再重连', () {
    fakeAsync((async) {
      final recorder = _Recorder();
      final container = _container(
        recorder: recorder,
        async: async,
        eventBody:
            'id: 7-0\nevent: succeeded\ndata: {"answer_id":"a1"}\n\n',
      );
      addTearDown(container.dispose);
      container.listen(
        jobLiveMonitorProvider('j1'),
        (previous, next) {},
        fireImmediately: true,
      );

      async.elapse(const Duration(seconds: 30));
      final state = container.read(jobLiveMonitorProvider('j1'));
      expect(state.live.terminal, const Succeeded(answerId: 'a1'));
      expect(state.lastEventId, '7-0');
      expect(state.connection, SseConnection.closed);
      expect(recorder.eventCalls, hasLength(1));
      expect(recorder.probeCalls, isEmpty);
    });
  });
}
