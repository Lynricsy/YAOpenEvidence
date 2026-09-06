import 'dart:ui' show Color;

/// 正文里的一处引用：第 [n] 篇文献的第 [pid] 段（[pid] 可缺省）。
class CitationRef {
  const CitationRef(this.n, this.pid);

  final int n;
  final int? pid;

  @override
  bool operator ==(Object other) =>
      other is CitationRef && other.n == n && other.pid == pid;

  @override
  int get hashCode => Object.hash(n, pid);

  @override
  String toString() => pid == null ? '[$n]' : '[$n¶$pid]';
}

/// 一处裸标记在文本里的位置（[start]、[end] 为 UTF-16 下标）。
class CitationMarker {
  const CitationMarker(this.start, this.end, this.ref);

  final int start;
  final int end;
  final CitationRef ref;
}

/// 裸标记 `[n]` 或 `[n¶pid]`（¶ = U+00B6）。
const markerPattern = r'\[(\d{1,2})(?:¶(\d{1,4}))?\]';

/// 渲染稿里的引用链接：`/v1/answers/{id}/papers/{n}/markdown#p{pid}`。
const answerLinkPattern =
    r'^/v1/answers/[^/]+/papers/(\d+)/markdown(?:#p(\d+))?$';

final _markerRegex = RegExp(markerPattern);
final _answerLinkRegex = RegExp(answerLinkPattern);

/// 解析渲染稿的引用链接；不是引用链接则返回 null。
CitationRef? parseAnswerLink(String destination) {
  final match = _answerLinkRegex.firstMatch(destination);
  if (match == null) return null;
  final n = int.tryParse(match.group(1) ?? '');
  if (n == null) return null;
  return CitationRef(n, int.tryParse(match.group(2) ?? ''));
}

/// 在一段文本里查找所有裸标记。
List<CitationMarker> markersIn(String text) {
  final out = <CitationMarker>[];
  for (final match in _markerRegex.allMatches(text)) {
    final n = int.tryParse(match.group(1) ?? '');
    if (n == null) continue;
    out.add(
      CitationMarker(
        match.start,
        match.end,
        CitationRef(n, int.tryParse(match.group(2) ?? '')),
      ),
    );
  }
  return out;
}

/// 统计正文里每篇文献被引用的次数（来源卡「正文引用 N 处」）。
Map<int, int> countMarkers(String markdown) {
  final counts = <int, int>{};
  for (final marker in markersIn(markdown)) {
    counts.update(marker.ref.n, (value) => value + 1, ifAbsent: () => 1);
  }
  return counts;
}

/// 引用色板，与 Web 端一致。
const citationPalette = <Color>[
  Color(0xFF087F96),
  Color(0xFF956124),
  Color(0xFF6366A0),
  Color(0xFF297D54),
  Color(0xFFB34F69),
  Color(0xFF397BB5),
  Color(0xFF89742C),
  Color(0xFF7D5B9E),
];

/// 第 [n] 篇文献的引用色。深色模式下往白色插值 25%，保证在暖褐底上的对比度。
Color citationColor(int n, {bool dark = false}) {
  final base = citationPalette[n >= 1 ? (n - 1) % citationPalette.length : 0];
  if (!dark) return base;
  return Color.lerp(base, const Color(0xFFFFFFFF), 0.25)!;
}
