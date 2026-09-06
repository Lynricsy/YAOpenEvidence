/// 一帧 Server-Sent Event。
class SseEvent {
  const SseEvent({this.id, this.event = 'message', required this.data});

  final String? id;
  final String event;
  final String data;

  @override
  bool operator ==(Object other) =>
      other is SseEvent &&
      other.id == id &&
      other.event == event &&
      other.data == data;

  @override
  int get hashCode => Object.hash(id, event, data);

  @override
  String toString() => 'SseEvent(id: $id, event: $event, data: $data)';
}

/// 按块喂入的 SSE 解析器：空行触发派发，`:` 开头是注释（心跳）。
///
/// 不能用 `stream.transform(LineSplitter())`：SSE 用空行作帧分隔符，
/// 行分割器把结尾不完整的行与空行语义混在一起，需要自己保留残行缓冲。
class SseParser {
  final StringBuffer _pending = StringBuffer();
  String? _id;
  String? _event;
  final List<String> _dataLines = [];

  /// 喂入任意长度的文本块，返回本次凑齐的所有帧。
  Iterable<SseEvent> feed(String chunk) {
    final events = <SseEvent>[];
    for (var i = 0; i < chunk.length; i++) {
      final char = chunk[i];
      if (char == '\n') {
        final event = _feedLine(_pending.toString());
        _pending.clear();
        if (event != null) events.add(event);
      } else {
        _pending.write(char);
      }
    }
    return events;
  }

  /// 流结束时冲刷残留缓冲（服务端未以空行收尾时仍派发已凑齐的帧）。
  Iterable<SseEvent> flush() {
    final events = <SseEvent>[];
    if (_pending.isNotEmpty) {
      final event = _feedLine(_pending.toString());
      _pending.clear();
      if (event != null) events.add(event);
    }
    final tail = _dispatch();
    if (tail != null) events.add(tail);
    return events;
  }

  SseEvent? _feedLine(String rawLine) {
    // 上游按 \n 切行，CRLF 流会留下尾部 \r。
    final line = rawLine.endsWith('\r')
        ? rawLine.substring(0, rawLine.length - 1)
        : rawLine;
    if (line.isEmpty) return _dispatch();
    if (line.startsWith(':')) return null;

    final String field;
    String value;
    final colon = line.indexOf(':');
    if (colon >= 0) {
      field = line.substring(0, colon);
      value = line.substring(colon + 1);
      if (value.startsWith(' ')) value = value.substring(1);
    } else {
      field = line;
      value = '';
    }

    switch (field) {
      case 'id':
        _id = value;
      case 'event':
        _event = value;
      case 'data':
        _dataLines.add(value);
      default:
        break; // retry 及未知字段忽略
    }
    return null;
  }

  SseEvent? _dispatch() {
    final id = _id;
    final event = _event;
    final data = _dataLines.isEmpty ? null : _dataLines.join('\n');
    _id = null;
    _event = null;
    _dataLines.clear();
    if (data == null) return null;
    return SseEvent(id: id, event: event ?? 'message', data: data);
  }
}
