import 'markdown_document.dart';

/// 给命中引文的片段打上 `highlight`（每条 quote 只标注首次出现）。
///
/// 坐标一律用 Unicode 码点：字素簇会跨 run 合并（例如 `**abcd**́` 解析出
/// `['abcd', '\u0301']`，拼接后只有 4 个字素却有 5 个码点），
/// 若按字素计数逐 run 累加下标就会错位甚至越界。
List<InlineRun> highlightQuotes(List<InlineRun> runs, List<String> quotes) {
  final runeRuns = runs
      .map((r) => r.text.runes.toList(growable: false))
      .toList(growable: false);
  final total = runeRuns.fold<int>(0, (sum, item) => sum + item.length);
  if (total == 0 || quotes.isEmpty) return runs;

  final plain = plainTextOf(runs);
  final marked = List<bool>.filled(total, false);
  var hit = false;
  for (final quote in quotes) {
    final needle = quote.trim();
    // 过短的片段容易在正文里误命中，与 Web 端一致地跳过。
    if (needle.runes.length < 4) continue;
    final index = plain.indexOf(needle);
    if (index < 0) continue;
    final start = plain.substring(0, index).runes.length;
    final end = start + needle.runes.length;
    if (start >= end || end > total) continue;
    for (var i = start; i < end; i++) {
      marked[i] = true;
    }
    hit = true;
  }
  if (!hit) return runs;

  final output = <InlineRun>[];
  var cursor = 0;
  for (var index = 0; index < runeRuns.length; index++) {
    final scalars = runeRuns[index];
    if (scalars.isEmpty) continue;
    var segmentStart = 0;
    for (var offset = 1; offset <= scalars.length; offset++) {
      final isBoundary =
          offset == scalars.length ||
          marked[cursor + offset] != marked[cursor + segmentStart];
      if (isBoundary) {
        final run = runs[index];
        output.add(
          run.copyWith(
            text: String.fromCharCodes(scalars.sublist(segmentStart, offset)),
            style: marked[cursor + segmentStart]
                ? run.style | InlineStyle.highlight
                : run.style,
          ),
        );
        segmentStart = offset;
      }
    }
    cursor += scalars.length;
  }
  return output;
}
