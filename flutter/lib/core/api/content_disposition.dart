/// 从 `Content-Disposition` 响应头里取下载文件名。
///
/// 优先 RFC 5987 的 `filename*=UTF-8''<百分号编码>`：只有它能无损承载中文标题；
/// 百分号序列非法时不做猜测，直接返回 null，由调用方退回本地兜底名。
String? filenameFromContentDisposition(String? header) {
  if (header == null) return null;

  final extended = _extended.firstMatch(header);
  if (extended != null) {
    try {
      return Uri.decodeComponent(extended.group(1)!);
    } on ArgumentError {
      return null;
    } on FormatException {
      return null;
    }
  }

  return _plain.firstMatch(header)?.group(1);
}

final _extended = RegExp(r"""filename\*=(?:UTF-8|utf-8)''([^;]+)""");
final _plain = RegExp(r'filename="([^"]+)"');
