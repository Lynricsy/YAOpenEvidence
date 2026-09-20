import 'package:flutter_test/flutter_test.dart';
import 'package:picoseek/core/session/server_url.dart';

void main() {
  test('本地网络允许明文 http', () {
    expect(validateServerUrl('http://192.168.1.5:8765'), isNull);
    expect(validateServerUrl('http://127.0.0.1:8765'), isNull);
    expect(validateServerUrl('http://localhost:8765'), isNull);
    expect(validateServerUrl('http://mac.local:8765'), isNull);
    expect(validateServerUrl('http://10.0.0.2'), isNull);
    expect(validateServerUrl('http://172.20.3.4'), isNull);
  });

  test('公网地址必须走 https', () {
    expect(validateServerUrl('http://example.com'), '非本地网络地址需使用 https://');
    expect(validateServerUrl('http://172.32.0.1'), '非本地网络地址需使用 https://');
    expect(validateServerUrl('https://example.com'), isNull);
  });

  test('协议与主机非法时拒绝', () {
    expect(validateServerUrl('ftp://x'), isNotNull);
    expect(validateServerUrl(''), isNotNull);
    expect(validateServerUrl('example.com'), isNotNull);
  });

  test('去掉尾部斜杠', () {
    expect(
      parseServerUrl('https://api.example.com/')?.toString(),
      'https://api.example.com',
    );
    expect(
      parseServerUrl(' http://localhost:8765// ')?.toString(),
      'http://localhost:8765',
    );
  });
}
