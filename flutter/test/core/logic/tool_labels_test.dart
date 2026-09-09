import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaopenevidence/core/logic/tool_labels.dart';

void main() {
  test('已登记工具取中文动作，未登记的退回 server/tool', () {
    expect(toolLabel('semantic_scholar', 'read_pdf'), '读取 PDF');
    expect(toolIcon('read_pdf'), Icons.picture_as_pdf_outlined);
    expect(toolLabel('mystery', 'brand_new'), 'mystery/brand_new');
    expect(toolIcon('brand_new'), Icons.build_outlined);
  });

  test('参数摘要按键优先级取值，section 追加在后', () {
    expect(
      describeToolArgs(const {'path': 'x.pdf', 'query': 'sepsis'}),
      '「sepsis」',
    );
    // query 缺席时才轮到后面的键。
    expect(describeToolArgs(const {'pmids': '123,456'}), '「123,456」');
    expect(
      describeToolArgs(const {'paper_id': 'S2:1', 'section': 'Methods'}),
      '「S2:1」 · Methods',
    );
    // 空 section 不该留个孤零零的分隔点。
    expect(describeToolArgs(const {'command': 'ls', 'section': ''}), '「ls」');
    expect(describeToolArgs(const {'other': 'x'}), '');
    expect(describeToolArgs(const {'query': null, 'name': 'Doe'}), '「Doe」');
  });

  test('超过 60 字的参数截断加省略号', () {
    expect(describeToolArgs({'query': 'a' * 60}), '「${'a' * 60}」');
    expect(describeToolArgs({'query': 'a' * 61}), '「${'a' * 60}…」');
  });

  test('耗时保留一位小数，null 为空串', () {
    expect(formatDuration(null), '');
    expect(formatDuration(820), '0.8s');
    expect(formatDuration(12340), '12.3s');
    expect(formatDuration(0), '0.0s');
  });
}
