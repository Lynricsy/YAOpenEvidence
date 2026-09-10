import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/tokens.dart';
import '../../core/api/api_error.dart';
import '../../core/session/prefs.dart';
import '../../core/session/server_url.dart';
import '../../core/session/session_controller.dart';
import '../../shared/widgets/brand_logo.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _server;
  final _username = TextEditingController();
  final _password = TextEditingController();

  bool _obscure = true;
  bool _submitting = false;
  String? _error;
  int _cooldown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final last = ref.read(prefsProvider).getString(PrefKeys.serverUrl);
    _server = TextEditingController(text: last ?? defaultServerUrl);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _server.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    _timer?.cancel();
    setState(() => _cooldown = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _cooldown -= 1);
      if (_cooldown <= 0) timer.cancel();
    });
  }

  Future<void> _submit() async {
    if (_submitting || _cooldown > 0) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final server = parseServerUrl(_server.text);
    if (server == null) return;

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .login(
            server: server,
            username: _username.text.trim(),
            password: _password.text,
          );
      // 成功后由 router 的 redirect 跳到 next。
    } on ApiError catch (error) {
      if (!mounted) return;
      if (error.status == 401) {
        setState(() => _error = '用户名或密码错误');
      } else if (error.code == 'login_rate_limited') {
        setState(() => _error = error.userMessage);
        _startCooldown(error.retryAfter ?? 60);
      } else {
        setState(() => _error = error.userMessage);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(YaoeTokens.space5),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // BrandLockup 只支持横排，这里要竖排（Logo 在上、标题在下）。
                  const Center(
                    child: BrandLogo(size: 72, semanticLabel: 'YAOpenEvidence'),
                  ),
                  const SizedBox(height: YaoeTokens.space3),
                  Text(
                    'YAOpenEvidence',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: YaoeTokens.space2),
                  Text(
                    '基于文献证据的临床问答',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _FieldLabel('服务器地址'),
                  TextFormField(
                    controller: _server,
                    autocorrect: false,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      hintText: defaultServerUrl,
                    ),
                    validator: (value) => validateServerUrl(value ?? ''),
                  ),
                  const SizedBox(height: YaoeTokens.space3),
                  _FieldLabel('用户名'),
                  TextFormField(
                    controller: _username,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    decoration: const InputDecoration(hintText: '请输入用户名'),
                    validator: (value) =>
                        (value ?? '').trim().isEmpty ? '请输入用户名' : null,
                  ),
                  const SizedBox(height: YaoeTokens.space3),
                  _FieldLabel('密码'),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    autocorrect: false,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: '请输入密码',
                      suffixIcon: IconButton(
                        tooltip: _obscure ? '显示密码' : '隐藏密码',
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 18,
                        ),
                      ),
                    ),
                    validator: (value) =>
                        (value ?? '').isEmpty ? '请输入密码' : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: YaoeTokens.space3),
                    Text(
                      _error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: YaoeTokens.space5),
                  FilledButton(
                    onPressed: (_submitting || _cooldown > 0) ? null : _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_cooldown > 0 ? '$_cooldown 秒后重试' : '登录'),
                  ),
                  const SizedBox(height: YaoeTokens.space4),
                  Text(
                    '本应用输出仅供医学专业人员参考，不构成诊疗建议。',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 输入框上方的字段名（对齐 iOS 的表单排版）。
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: YaoeTokens.space1),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
