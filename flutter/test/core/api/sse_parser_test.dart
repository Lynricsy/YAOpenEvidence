import 'package:flutter_test/flutter_test.dart';
import 'package:picoseek/core/api/sse.dart';

/// 把完整的 SSE 报文整块喂进解析器。
List<SseEvent> parse(String stream) {
  final parser = SseParser();
  return parser.feed(stream).toList();
}

void main() {
  test('心跳注释不产出事件', () {
    final parsed = parse(
      ': ping\n\nid: 1-0\nevent: stage\n'
      'data: {"stage":"search","status":"started"}\n\n',
    );
    expect(parsed, hasLength(1));
    expect(parsed[0].id, '1-0');
    expect(parsed[0].event, 'stage');
    expect(parsed[0].data, '{"stage":"search","status":"started"}');
  });

  test('缺省事件名为 message，多行 data 用换行连接', () {
    final parsed = parse('data: a\ndata: b\n\n');
    expect(parsed, hasLength(1));
    expect(parsed[0].event, 'message');
    expect(parsed[0].id, isNull);
    expect(parsed[0].data, 'a\nb');
  });

  test('事件之间状态不残留', () {
    final parsed = parse(
      'id: 5-0\nevent: log\ndata: {}\n\nevent: cancelled\ndata: {}\n\n',
    );
    expect(parsed, hasLength(2));
    expect(parsed[0].id, '5-0');
    expect(parsed[1].id, isNull);
    expect(parsed[1].event, 'cancelled');
  });

  test('CRLF 行尾与无 data 的帧', () {
    final parsed = parse('event: ping\r\n\r\nid: 9-1\r\ndata: x\r\n\r\n');
    expect(parsed, hasLength(1));
    expect(parsed[0].id, '9-1');
    expect(parsed[0].data, 'x');
  });

  test('跨块切分的帧在收齐后才派发', () {
    final parser = SseParser();
    expect(parser.feed('id: 3-0\neve'), isEmpty);
    expect(parser.feed('nt: stage\ndata: {"a":1}'), isEmpty);
    final events = parser.feed('\n\n').toList();
    expect(events, hasLength(1));
    expect(events[0].event, 'stage');
    expect(events[0].data, '{"a":1}');
  });

  test('流末尾未以空行收尾时 flush 仍派发', () {
    final parser = SseParser();
    expect(parser.feed('data: tail\n'), isEmpty);
    final events = parser.flush().toList();
    expect(events, hasLength(1));
    expect(events[0].data, 'tail');
  });
}
