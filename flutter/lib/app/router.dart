import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/session/session_controller.dart';
import '../features/account/account_page.dart';
import '../features/admin/users_page.dart';
import '../features/answer/answer_page.dart';
import '../features/ask/ask_page.dart';
import '../features/history/history_page.dart';
import '../features/kb/kb_page.dart';
import '../features/library/library_page.dart';
import '../features/library/paper_page.dart';
import '../features/literature/literature_page.dart';
import '../features/login/login_page.dart';
import '../features/shell/app_shell.dart';
import 'theme/tokens.dart';

part 'router.g.dart';

/// 180 ms 淡入 + 8 px 上移。`key` 固定为路由标识：同一路由换参数（`/a/1`→`/a/2`）
/// 不重放进入动画。
CustomTransitionPage<void> _page(String key, Widget child) =>
    CustomTransitionPage<void>(
      key: ValueKey(key),
      child: child,
      transitionDuration: YaoeTokens.motionFast,
      reverseTransitionDuration: YaoeTokens.motionFast,
      transitionsBuilder: (context, animation, secondary, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: YaoeTokens.motionCurve,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );

/// 只接受站内相对路径，挡掉 `//evil.example` 这类协议相对跳转。
String _safeNext(String? next) {
  if (next == null || !next.startsWith('/') || next.startsWith('//')) {
    return '/';
  }
  return next;
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final session = ref.read(sessionControllerProvider);
      final value = session.value;
      // 检查中：App 渲染启动页，不参与路由决策。
      if (value == null) return null;
      final location = state.matchedLocation;
      final isLogin = location == '/login';

      if (value is SignedOut) {
        if (isLogin) return null;
        final full = state.uri.toString();
        return Uri(
          path: '/login',
          queryParameters: full == '/' ? null : {'next': full},
        ).toString();
      }
      if (isLogin) return _safeNext(state.uri.queryParameters['next']);
      if (location.startsWith('/admin') &&
          !ref.read(isAdminProvider)) {
        return '/';
      }
      return null;
    },
    errorBuilder: (context, state) => const _NotFoundRedirect(),
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _page('login', const LoginPage()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) => _page('ask', const AskPage()),
                routes: [
                  GoRoute(
                    path: 'a/:answerId',
                    pageBuilder: (context, state) => _page(
                      'answer',
                      AnswerPage(answerId: state.pathParameters['answerId']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                pageBuilder: (context, state) =>
                    _page('history', const HistoryPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                pageBuilder: (context, state) =>
                    _page('library', const LibraryPage()),
                routes: [
                  GoRoute(
                    path: ':key',
                    pageBuilder: (context, state) => _page(
                      'paper',
                      PaperPage(
                        paperKey: state.pathParameters['key']!,
                        pid: int.tryParse(
                          state.uri.queryParameters['pid'] ?? '',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/kb',
                pageBuilder: (context, state) => _page('kb', const KbPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                pageBuilder: (context, state) =>
                    _page('search', const LiteraturePage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/users',
                pageBuilder: (context, state) =>
                    _page('users', const UsersPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                pageBuilder: (context, state) =>
                    _page('account', const AccountPage()),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // 会话变化（登录/登出/令牌失效）后重跑 redirect。
  ref.listen(sessionControllerProvider, (_, _) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
}

/// 未匹配路径直接回到提问页。
class _NotFoundRedirect extends StatelessWidget {
  const _NotFoundRedirect();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.go('/');
    });
    return const Scaffold(body: SizedBox.shrink());
  }
}
