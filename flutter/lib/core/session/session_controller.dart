import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api/api_client.dart';
import '../api/api_error.dart';
import '../api/endpoints.dart';
import '../models/auth.dart';
import 'prefs.dart';
import 'server_url.dart';
import 'token_store.dart';

part 'session_controller.g.dart';

/// 会话状态。`AsyncLoading` 即「检查中」（启动页），这里只有登入/登出两种落地态。
sealed class SessionState {
  const SessionState();
}

final class SignedOut extends SessionState {
  const SignedOut({this.lastServer});

  final String? lastServer;
}

final class SignedIn extends SessionState {
  const SignedIn({
    required this.user,
    required this.server,
    required this.token,
    required this.generation,
  });

  final UserRead user;
  final Uri server;
  final String token;

  /// 会话代数：`expire()` 只接受当前代数的失效通知，避免旧客户端的 401
  /// 把刚建立的新会话踢掉。
  final int generation;
}

@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  int _generation = 0;

  @override
  Future<SessionState> build() async {
    final prefs = ref.watch(prefsProvider);
    final store = ref.watch(tokenStoreProvider);
    final lastServer = prefs.getString(PrefKeys.serverUrl);
    final server = parseServerUrl(lastServer ?? defaultServerUrl);
    final token = await store.read();
    final expiresAt = DateTime.tryParse(
      prefs.getString(PrefKeys.tokenExpiresAt) ?? '',
    );

    if (server == null ||
        token == null ||
        token.isEmpty ||
        expiresAt == null ||
        !expiresAt.isAfter(DateTime.now())) {
      if (token != null) await store.clear();
      return SignedOut(lastServer: lastServer);
    }

    final cached = prefs.getJson(PrefKeys.user);
    final client = ApiClient(
      baseUrl: server,
      token: () => token,
      onUnauthorized: () {},
    );
    try {
      final user = await client.me();
      await prefs.setJson(PrefKeys.user, user.toJson());
      return SignedIn(
        user: user,
        server: server,
        token: token,
        generation: ++_generation,
      );
    } on ApiError catch (error) {
      if (error.status == 401) {
        await _clear();
        return SignedOut(lastServer: lastServer);
      }
      // 网络不可用：用缓存用户先进入界面，具体页面各自显示错误态。
      if (cached == null) return SignedOut(lastServer: lastServer);
      return SignedIn(
        user: UserRead.fromJson(cached),
        server: server,
        token: token,
        generation: ++_generation,
      );
    } finally {
      client.close();
    }
  }

  /// 登录：临时客户端换取令牌，成功后落盘并切到 [SignedIn]。
  Future<void> login({
    required Uri server,
    required String username,
    required String password,
  }) async {
    final client = ApiClient(
      baseUrl: server,
      token: () => null,
      onUnauthorized: () {},
    );
    try {
      final response = await client.login(
        username: username,
        password: password,
      );
      final prefs = ref.read(prefsProvider);
      await ref.read(tokenStoreProvider).write(response.accessToken);
      await prefs.setString(PrefKeys.serverUrl, server.toString());
      await prefs.setString(
        PrefKeys.tokenExpiresAt,
        response.expiresAt.toUtc().toIso8601String(),
      );
      await prefs.setJson(PrefKeys.user, response.user.toJson());
      state = AsyncData(
        SignedIn(
          user: response.user,
          server: server,
          token: response.accessToken,
          generation: ++_generation,
        ),
      );
    } finally {
      client.close();
    }
  }

  /// 退出登录：先通知后端吊销令牌（失败也继续），再清空本地会话。
  Future<void> logout() async {
    final current = state.value;
    if (current is SignedIn) {
      final client = ApiClient(
        baseUrl: current.server,
        token: () => current.token,
        onUnauthorized: () {},
      );
      try {
        await client.logout();
      } on ApiError {
        // 令牌可能已失效，本地清理照常进行。
      } finally {
        client.close();
      }
    }
    final lastServer = ref.read(prefsProvider).getString(PrefKeys.serverUrl);
    await _clear();
    state = AsyncData(SignedOut(lastServer: lastServer));
  }

  /// 令牌被后端拒绝（401）。只有代数一致才清空，避免踢掉新会话。
  void expire(int generation) {
    final current = state.value;
    if (current is! SignedIn || current.generation != generation) return;
    final lastServer = ref.read(prefsProvider).getString(PrefKeys.serverUrl);
    state = AsyncData(SignedOut(lastServer: lastServer));
    _clear().ignore();
  }

  /// 修改密码后同步最新用户信息（角色/状态可能被管理员改过）。
  Future<void> refreshUser() async {
    final current = state.value;
    if (current is! SignedIn) return;
    final user = await ref.read(apiClientProvider).me();
    await ref.read(prefsProvider).setJson(PrefKeys.user, user.toJson());
    state = AsyncData(
      SignedIn(
        user: user,
        server: current.server,
        token: current.token,
        generation: current.generation,
      ),
    );
  }

  Future<void> _clear() async {
    final prefs = ref.read(prefsProvider);
    await ref.read(tokenStoreProvider).clear();
    await prefs.remove(PrefKeys.tokenExpiresAt);
    await prefs.remove(PrefKeys.user);
  }
}

/// 受保护页面用的 API 客户端。仅在 [SignedIn] 下可用。
@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  final session = ref.watch(sessionControllerProvider).value;
  if (session is! SignedIn) {
    throw StateError('未登录状态下不应访问 apiClientProvider');
  }
  final client = ApiClient(
    baseUrl: session.server,
    token: () => session.token,
    onUnauthorized: () =>
        ref.read(sessionControllerProvider.notifier).expire(session.generation),
  );
  ref.onDispose(client.close);
  return client;
}

@Riverpod(keepAlive: true)
UserRead? currentUser(Ref ref) {
  final session = ref.watch(sessionControllerProvider).value;
  return session is SignedIn ? session.user : null;
}

@Riverpod(keepAlive: true)
bool isAdmin(Ref ref) => ref.watch(currentUserProvider)?.role == UserRole.admin;
