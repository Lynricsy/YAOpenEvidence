/// 相对时间：刚刚 / N 分钟前 / N 小时前 / N 天前 / 具体日期。
String relativeTime(DateTime time, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final diff = reference.difference(time.toLocal());
  if (diff.isNegative) return formatDateTime(time);
  if (diff.inMinutes < 1) return '刚刚';
  if (diff.inMinutes < 60) return '${diff.inMinutes} 分钟前';
  if (diff.inHours < 24) return '${diff.inHours} 小时前';
  if (diff.inDays < 30) return '${diff.inDays} 天前';
  return formatDate(time);
}

String _two(int value) => value.toString().padLeft(2, '0');

/// `2026-09-06`。
String formatDate(DateTime time) {
  final local = time.toLocal();
  return '${local.year}-${_two(local.month)}-${_two(local.day)}';
}

/// `2026-09-06 22:41`。
String formatDateTime(DateTime time) {
  final local = time.toLocal();
  return '${formatDate(local)} ${_two(local.hour)}:${_two(local.minute)}';
}

/// 时长：`12 秒` / `3 分 05 秒`。
String formatDuration(Duration duration) {
  final seconds = duration.inSeconds.abs();
  if (seconds < 60) return '$seconds 秒';
  return '${seconds ~/ 60} 分 ${_two(seconds % 60)} 秒';
}

/// 千分位整数。
String formatCount(int value) {
  final text = value.abs().toString();
  final out = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) out.write(',');
    out.write(text[i]);
  }
  return out.toString();
}

/// 相似度分数两位小数。
String formatScore(double score) => score.toStringAsFixed(2);

/// 作者列表：前 3 位 + 「等」。
String formatAuthors(List<String> authors, {int limit = 3}) {
  if (authors.isEmpty) return '';
  if (authors.length <= limit) return authors.join('、');
  return '${authors.take(limit).join('、')} 等';
}
