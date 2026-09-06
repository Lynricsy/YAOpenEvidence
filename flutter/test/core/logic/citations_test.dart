import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:yaopenevidence/core/logic/citations.dart';

void main() {
  test('解析渲染稿引用链接', () {
    expect(
      parseAnswerLink('/v1/answers/abc/papers/3/markdown#p7'),
      const CitationRef(3, 7),
    );
    expect(
      parseAnswerLink('/v1/answers/abc/papers/3/markdown'),
      const CitationRef(3, null),
    );
    expect(parseAnswerLink('https://example.com'), isNull);
    expect(parseAnswerLink('/v1/answers/abc/papers/3/markdown#other'), isNull);
  });

  test('统计正文引用次数', () {
    final counts = countMarkers('结论 [1¶3] 与 [1] 一致，[2¶9] 不同，[2024] 只是年份。');
    expect(counts[1], 2);
    expect(counts[2], 1);
    expect(counts.containsKey(2024), isFalse);
  });

  test('引用色板按 n 循环', () {
    expect(citationColor(1), const Color(0xFF087F96));
    expect(citationColor(8), const Color(0xFF7D5B9E));
    expect(citationColor(9), const Color(0xFF087F96));
    expect(citationColor(0), const Color(0xFF087F96));
    expect(citationColor(1, dark: true), isNot(const Color(0xFF087F96)));
  });
}
