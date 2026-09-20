import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'prefs.g.dart';

/// 本地偏好键名（与 Apple 端一致，便于同一后端下的行为对齐）。
abstract final class PrefKeys {
  static const serverUrl = 'picoseek.serverURL';
  static const tokenExpiresAt = 'picoseek.tokenExpiresAt';
  static const user = 'picoseek.user';
  static const filters = 'picoseek.filters';
  static const theme = 'picoseek.theme';
  static const sidebar = 'picoseek.sidebar';
  static const readerLayout = 'picoseek.reader-layout';

  /// 平台无安全存储时的令牌回退位置（明文，账号页会提示）。
  static const insecureToken = 'picoseek.token-insecure';

  static const all = <String>{
    serverUrl,
    tokenExpiresAt,
    user,
    filters,
    theme,
    sidebar,
    readerLayout,
    insecureToken,
  };
}

/// `SharedPreferencesWithCache` 的薄封装：读同步、写异步。
class Prefs {
  Prefs(this._cache);

  final SharedPreferencesWithCache _cache;

  static Future<Prefs> open() async => Prefs(
    await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: PrefKeys.all,
      ),
    ),
  );

  String? getString(String key) => _cache.getString(key);

  Future<void> setString(String key, String value) =>
      _cache.setString(key, value);

  Future<void> remove(String key) => _cache.remove(key);

  Map<String, dynamic>? getJson(String key) {
    final raw = _cache.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> setJson(String key, Map<String, Object?> value) =>
      _cache.setString(key, jsonEncode(value));
}

/// 在 `main()` 里用 `overrideWithValue` 注入，保证各处同步读偏好。
@Riverpod(keepAlive: true)
Prefs prefs(Ref ref) =>
    throw StateError('prefsProvider 必须在 main() 中以 overrideWithValue 注入');
