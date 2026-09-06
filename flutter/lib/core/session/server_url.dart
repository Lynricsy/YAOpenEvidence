/// 默认后端地址（本机开发栈）。
const defaultServerUrl = 'http://localhost:8765';

/// 解析服务器地址：去掉尾部 `/`，非法输入返回 null。
Uri? parseServerUrl(String text) {
  final trimmed = text.trim().replaceFirst(RegExp(r'/+$'), '');
  if (trimmed.isEmpty) return null;
  final uri = Uri.tryParse(trimmed);
  if (uri == null) return null;
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;
  if (uri.host.isEmpty) return null;
  return uri;
}

/// 本地网络地址（明文 http 只允许指向这些主机）。
bool isLocalHost(String host) {
  final lower = host.toLowerCase();
  if (lower == 'localhost' || lower == '::1' || lower == '[::1]') return true;
  if (lower.endsWith('.local') || lower.endsWith('.localhost')) return true;
  final octets = lower.split('.');
  if (octets.length != 4) return false;
  final parts = octets.map(int.tryParse).toList();
  if (parts.any((p) => p == null || p < 0 || p > 255)) return false;
  final [a, b, _, _] = parts.cast<int>();
  if (a == 127 || a == 10) return true;
  if (a == 192 && b == 168) return true;
  if (a == 169 && b == 254) return true;
  if (a == 172 && b >= 16 && b <= 31) return true;
  return false;
}

/// 表单校验：通过返回 null，否则返回中文错误文案。
String? validateServerUrl(String text) {
  final uri = parseServerUrl(text);
  if (uri == null) return '请输入 http:// 或 https:// 开头的服务器地址';
  if (uri.scheme == 'http' && !isLocalHost(uri.host)) {
    return '非本地网络地址需使用 https://';
  }
  return null;
}
