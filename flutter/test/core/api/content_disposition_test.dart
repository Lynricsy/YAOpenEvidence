import 'package:flutter_test/flutter_test.dart';
import 'package:picoseek/core/api/content_disposition.dart';

void main() {
  test('同时给出 filename 与 filename* 时取后者并解出中文', () {
    expect(
      filenameFromContentDisposition(
        'attachment; filename="PicoSeek-x.pdf"; '
        "filename*=UTF-8''PicoSeek-20260919-%E9%97%AE%E9%A2%98.pdf",
      ),
      'PicoSeek-20260919-问题.pdf',
    );
  });

  test('只有 ASCII 的 filename 时按引号内的值解析', () {
    expect(
      filenameFromContentDisposition('attachment; filename="a.pdf"'),
      'a.pdf',
    );
  });

  test('没有响应头时返回 null', () {
    expect(filenameFromContentDisposition(null), isNull);
  });

  test('filename* 的百分号编码非法时返回 null，而不是给出半截名字', () {
    expect(
      filenameFromContentDisposition("attachment; filename*=UTF-8''%E9%97.pdf"),
      isNull,
    );
  });
}
