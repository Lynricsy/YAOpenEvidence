import 'dart:convert';

/// RFC 3986 unreserved 字符集。
const _unreserved =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

final Set<int> _unreservedBytes = _unreserved.codeUnits.toSet();

const _hex = '0123456789ABCDEF';

/// 按 unreserved 字符集百分号编码：`+`→`%2B`、空格→`%20`、CJK→UTF-8 百分号。
///
/// 不能用 `Uri.encodeQueryComponent`（把空格编成 `+`）或 `Uri(queryParameters:)`：
/// FastAPI 按表单规则把 `+` 解成空格，会静默改写 `HER2+`、DOI 与全文章节名。
String encodeQueryComponent(String text) {
  final bytes = utf8.encode(text);
  final out = StringBuffer();
  for (final byte in bytes) {
    if (_unreservedBytes.contains(byte)) {
      out.writeCharCode(byte);
    } else {
      out
        ..write('%')
        ..write(_hex[byte >> 4])
        ..write(_hex[byte & 0x0f]);
    }
  }
  return out.toString();
}

/// 路径参数转义：文献 key 只允许 `[A-Za-z0-9._-]`，非法字符转义后由后端按 404 处理，
/// 避免斜杠等注入到路由里。
String encodePathComponent(String text) => encodeQueryComponent(text);

/// 拼查询串。值可为 `String | int | bool | Iterable`（可迭代值展开为重复键），
/// `null` 整项跳过；空字符串仍会编码为 `key=`（后端部分端点靠空串表示「不限」）。
String encodeQuery(Map<String, Object?> params) {
  final parts = <String>[];
  for (final entry in params.entries) {
    final value = entry.value;
    if (value == null) continue;
    final key = encodeQueryComponent(entry.key);
    if (value is Iterable) {
      for (final item in value) {
        if (item == null) continue;
        parts.add('$key=${encodeQueryComponent('$item')}');
      }
    } else {
      parts.add('$key=${encodeQueryComponent('$value')}');
    }
  }
  return parts.join('&');
}
