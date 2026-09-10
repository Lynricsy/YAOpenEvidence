import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/tokens.dart';
import '../../core/api/api_error.dart';
import '../../core/models/auth.dart';
import '../../shared/format.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loadable.dart';
import '../../shared/widgets/page_header.dart';
import '../../shared/widgets/pagination.dart';
import '../../shared/widgets/surface.dart';
import 'users_controller.dart';

class UsersPage extends ConsumerWidget {
  const UsersPage({super.key});

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    UserRead user,
  ) async {
    try {
      await ref.read(usersControllerProvider.notifier).toggleActive(user);
    } on ApiError catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.userMessage)));
      }
    }
  }

  Future<void> _showEditor(BuildContext context, {UserRead? user}) async {
    final success = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _UserDialog(user: user),
    );
    if (success == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(user == null ? '用户已创建' : '密码已重置')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(usersControllerProvider);
    final controller = ref.read(usersControllerProvider.notifier);
    final theme = Theme.of(context);
    Widget active(UserRead user) => Switch(
      value: user.isActive,
      onChanged: controller.updating.contains(user.id)
          ? null
          : (_) => _toggle(context, ref, user),
    );
    Widget reset(UserRead user) => IconButton(
      tooltip: '重置密码',
      icon: const Icon(Icons.lock_reset_outlined),
      onPressed: controller.updating.contains(user.id)
          ? null
          : () => _showEditor(context, user: user),
    );
    return SingleChildScrollView(
      child: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: '用户管理',
              actions: [
                FilledButton.icon(
                  onPressed: controller.updating.isNotEmpty
                      ? null
                      : () => _showEditor(context),
                  icon: const Icon(Icons.person_add_outlined),
                  label: const Text('新建用户'),
                ),
              ],
            ),
            AsyncValueView(
              value: value,
              onRetry: controller.reload,
              builder: (page) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (page.items.isEmpty)
                    const EmptyState(icon: Icons.group_outlined, title: '暂无用户')
                  else
                    // 宽窄一套实现：表格在窄屏要横滚，卡片行两端都读得通。
                    for (final user in page.items)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: YaoeTokens.space3,
                        ),
                        child: YaoeCard(
                          padding: const EdgeInsets.all(YaoeTokens.space3),
                          child: Row(
                            children: [
                              UserAvatar(name: user.username, radius: 16),
                              const SizedBox(width: YaoeTokens.space3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.username,
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                    Text(
                                      '${user.role.label} · 创建于 '
                                      '${relativeTime(user.createdAt)}',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              active(user),
                              reset(user),
                            ],
                          ),
                        ),
                      ),
                  const SizedBox(height: YaoeTokens.space3),
                  Pager(
                    total: page.total,
                    limit: page.limit,
                    offset: page.offset,
                    onChange: controller.setOffset,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserDialog extends ConsumerStatefulWidget {
  const _UserDialog({this.user});
  final UserRead? user;

  @override
  ConsumerState<_UserDialog> createState() => _UserDialogState();
}

class _UserDialogState extends ConsumerState<_UserDialog> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  UserRole _role = UserRole.user;
  bool _busy = false;
  String? _usernameError;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final controller = ref.read(usersControllerProvider.notifier);
      final user = widget.user;
      if (user == null) {
        await controller.create(
          username: _username.text.trim(),
          password: _password.text,
          role: _role,
        );
      } else {
        await controller.reset(id: user.id, newPassword: _password.text);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on ApiError catch (error) {
      if (!mounted) return;
      if (widget.user == null && error.code == 'username_exists') {
        setState(() => _usernameError = error.userMessage);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.userMessage)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(widget.user == null ? '新建用户' : '重置密码'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.user == null) ...[
                    TextFormField(
                      controller: _username,
                      enabled: !_busy,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        hintText: '用户名',
                        errorText: _usernameError,
                      ),
                      onChanged: (_) {
                        if (_usernameError != null) {
                          setState(() => _usernameError = null);
                        }
                      },
                      validator: (value) =>
                          RegExp(r'^[A-Za-z0-9][A-Za-z0-9_.-]{2,63}$')
                              .hasMatch(value?.trim() ?? '')
                          ? null
                          : '3–64 位，以字母或数字开头，可含 _ . -',
                    ),
                    const SizedBox(height: YaoeTokens.space3),
                  ] else ...[
                    Text(widget.user!.username),
                    const SizedBox(height: YaoeTokens.space3),
                  ],
                  TextFormField(
                    controller: _password,
                    enabled: !_busy,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      hintText: widget.user == null ? '密码' : '新密码',
                    ),
                    validator: (value) =>
                        value == null ||
                            value.runes.length < 12 ||
                            value.runes.length > 128
                        ? '密码须为 12–128 个字符'
                        : null,
                  ),
                  const SizedBox(height: YaoeTokens.space3),
                  if (widget.user != null)
                    TextFormField(
                      controller: _confirmation,
                      enabled: !_busy,
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: const InputDecoration(hintText: '确认新密码'),
                      validator: (value) =>
                          value != _password.text ? '两次输入的密码不一致' : null,
                    )
                  else
                    DropdownButtonFormField<UserRole>(
                      initialValue: _role,
                      decoration: const InputDecoration(hintText: '角色'),
                      items: [
                        for (final role in UserRole.values)
                          DropdownMenuItem(
                            value: role,
                            child: Text(role.label),
                          ),
                      ],
                      onChanged: _busy
                          ? null
                          : (role) {
                              if (role != null) setState(() => _role = role);
                            },
                    ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: Text(_busy ? '正在提交' : '确认'),
          ),
        ],
      ),
    );
  }
}
