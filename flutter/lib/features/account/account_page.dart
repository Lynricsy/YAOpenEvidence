import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/theme_controller.dart';
import '../../app/theme/tokens.dart';
import '../../core/api/api_error.dart';
import '../../core/api/endpoints.dart';
import '../../core/session/session_controller.dart';
import '../../core/session/token_store.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/page_header.dart';
import '../../shared/widgets/surface.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final session = ref.read(sessionControllerProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(apiClientProvider)
          .changePassword(current: _current.text, newPassword: _password.text);
      messenger.showSnackBar(const SnackBar(content: Text('密码已修改，请重新登录')));
      await session.logout();
    } on ApiError catch (error) {
      if (mounted) setState(() => _error = error.userMessage);
      if (!mounted && messenger.mounted) {
        messenger.showSnackBar(SnackBar(content: Text(error.userMessage)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showConfirm(
      context,
      title: '退出登录',
      body: '确定退出当前账号？',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(sessionControllerProvider.notifier).logout();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider).value;
    if (session is! SignedIn) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final mode = ref.watch(themeControllerProvider);
    final insecure = ref.watch(tokenStoreProvider).usesInsecureFallback;
    final s = session.server;
    // 只给主机名[:端口]：完整 URL 里的 scheme/path 是配置细节。
    final hostPort = s.hasPort ? '${s.host}:${s.port}' : s.host;

    return SingleChildScrollView(
      child: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(title: '账号'),
            PicoSeekCard(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      session.user.username,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  Pill(
                    text: session.user.role.label,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: PicoSeekTokens.sectionSpacing),
            PicoSeekCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '服务器',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: PicoSeekTokens.space1),
                  SelectableText(
                    hostPort,
                    style: theme.textTheme.bodyMedium?.merge(monoStyle),
                  ),
                ],
              ),
            ),
            const SizedBox(height: PicoSeekTokens.sectionSpacing),
            PicoSeekCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('外观', style: theme.textTheme.labelLarge),
                  const SizedBox(height: PicoSeekTokens.space3),
                  SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('跟随系统'),
                      ),
                      ButtonSegment(value: ThemeMode.light, label: Text('浅色')),
                      ButtonSegment(value: ThemeMode.dark, label: Text('深色')),
                    ],
                    selected: {mode},
                    onSelectionChanged: (selection) async {
                      await ref
                          .read(themeControllerProvider.notifier)
                          .set(selection.single);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: PicoSeekTokens.sectionSpacing),
            PicoSeekCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (insecure) ...[
                    PicoSeekCard(
                      tint: context.picoseek.warning,
                      padding: const EdgeInsets.all(PicoSeekTokens.space3),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_outlined,
                            color: context.picoseek.warning,
                          ),
                          const SizedBox(width: PicoSeekTokens.space2),
                          Expanded(
                            child: Text(
                              '当前平台无安全存储，令牌以明文保存',
                              style: TextStyle(color: context.picoseek.warning),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: PicoSeekTokens.space3),
                  ],
                  Text('修改密码', style: theme.textTheme.labelLarge),
                  const SizedBox(height: PicoSeekTokens.space3),
                  Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _current,
                          enabled: !_busy,
                          obscureText: true,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: const InputDecoration(hintText: '当前密码'),
                          validator: (value) =>
                              value == null || value.isEmpty ? '请输入当前密码' : null,
                        ),
                        const SizedBox(height: PicoSeekTokens.space3),
                        TextFormField(
                          controller: _password,
                          enabled: !_busy,
                          obscureText: true,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: const InputDecoration(hintText: '新密码'),
                          validator: (value) =>
                              value == null ||
                                  value.runes.length < 12 ||
                                  value.runes.length > 128
                              ? '密码须为 12–128 个字符'
                              : null,
                        ),
                        const SizedBox(height: PicoSeekTokens.space3),
                        TextFormField(
                          controller: _confirmation,
                          enabled: !_busy,
                          obscureText: true,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: const InputDecoration(hintText: '确认新密码'),
                          validator: (value) =>
                              value != _password.text ? '两次输入的密码不一致' : null,
                          onFieldSubmitted: (_) async {
                            if (!_busy) await _changePassword();
                          },
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: PicoSeekTokens.space2),
                          Text(
                            _error!,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ],
                        const SizedBox(height: PicoSeekTokens.space3),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton.icon(
                            onPressed: _busy ? null : _changePassword,
                            icon: const Icon(Icons.lock_outline),
                            label: Text(_busy ? '正在处理' : '修改密码'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: PicoSeekTokens.sectionSpacing),
            Center(
              child: FilledButton.tonalIcon(
                onPressed: _busy ? null : _logout,
                style: FilledButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                icon: const Icon(Icons.logout_outlined),
                label: const Text('退出登录'),
              ),
            ),
            const SizedBox(height: PicoSeekTokens.space3),
            Text(
              '本应用输出仅供医学专业人员参考，不构成诊疗建议。',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
