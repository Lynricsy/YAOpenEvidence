import 'dart:io' show Platform;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'prefs.dart';

part 'token_store.g.dart';

/// Linux 的安全存储走 libsecret，需要桌面会话的 Secret Service。
/// 没有 D-Bus 会话（无头环境、Xvfb、容器）时 libsecret 只报 GLib 警告，
/// 插件侧无法转成 Dart 异常，进程会在写入时直接退出——因此先看环境再决定用不用它。
bool _secureStorageUsable() {
  if (!Platform.isLinux) return true;
  final bus = Platform.environment['DBUS_SESSION_BUS_ADDRESS'] ?? '';
  if (bus.isEmpty || bus.startsWith('disabled')) return false;
  final secret = Platform.environment['SECRET_SERVICE_ADDRESS'] ?? '';
  return !secret.startsWith('disabled');
}

/// 会话令牌存储。优先系统安全存储；平台不可用时回退到明文偏好并置位
/// [usesInsecureFallback]（账号页据此提示），不因此阻塞登录。
class TokenStore {
  TokenStore({required this.prefs, FlutterSecureStorage? storage, bool? secure})
    // v11 起 Android 默认就是 AES-GCM + KeyStore 包裹，无需再传 aOptions。
    : _storage = storage ?? const FlutterSecureStorage(),
      _secure = secure ?? _secureStorageUsable();

  static const _key = 'session-token';

  final Prefs prefs;
  final FlutterSecureStorage _storage;
  final bool _secure;

  bool _insecure = false;

  /// 当前令牌是否以明文保存（Linux 无 Secret Service 等情形）。
  bool get usesInsecureFallback => _insecure || !_secure;

  Future<String?> read() async {
    if (_secure) {
      try {
        final token = await _storage.read(key: _key);
        if (token != null) return token;
      } catch (_) {
        _insecure = true;
      }
    }
    final fallback = prefs.getString(PrefKeys.insecureToken);
    if (fallback != null) _insecure = true;
    return fallback;
  }

  Future<void> write(String token) async {
    if (_secure) {
      try {
        await _storage.write(key: _key, value: token);
        await prefs.remove(PrefKeys.insecureToken);
        _insecure = false;
        return;
      } catch (_) {
        _insecure = true;
      }
    }
    await prefs.setString(PrefKeys.insecureToken, token);
  }

  Future<void> clear() async {
    if (_secure) {
      try {
        await _storage.delete(key: _key);
      } catch (_) {
        // 安全存储不可用时只需清掉回退位置。
      }
    }
    await prefs.remove(PrefKeys.insecureToken);
  }
}

@Riverpod(keepAlive: true)
TokenStore tokenStore(Ref ref) => TokenStore(prefs: ref.watch(prefsProvider));
