import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/api/endpoints.dart';
import '../../core/models/auth.dart';
import '../../core/models/page.dart';
import '../../core/session/session_controller.dart';

part 'users_controller.g.dart';

@riverpod
class UsersController extends _$UsersController {
  static const limit = 20;
  int offset = 0;
  final Set<String> updating = {};
  int _request = 0;

  @override
  Future<Page<UserRead>> build() {
    return ref.watch(apiClientProvider).users(limit: limit, offset: offset);
  }

  Future<void> setOffset(int value) async {
    if (updating.isNotEmpty || value == offset) return;
    offset = value;
    await reload();
  }

  Future<void> reload() async {
    if (updating.isNotEmpty) return;
    final request = ++_request;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(apiClientProvider).users(limit: limit, offset: offset),
    );
    if (ref.mounted && request == _request) state = result;
  }

  void _replace(UserRead user) {
    final page = state.value;
    if (page == null) return;
    state = AsyncData(page.copyWith(
      items: [for (final item in page.items) if (item.id == user.id) user else item],
    ));
  }

  Future<void> toggleActive(UserRead user) async {
    if (state.isLoading || !updating.add(user.id)) return;
    _replace(user.copyWith(isActive: !user.isActive));
    try {
      final updated = await ref.read(apiClientProvider).updateUser(
        id: user.id,
        isActive: !user.isActive,
      );
      if (!ref.mounted) return;
      updating.remove(user.id);
      _replace(updated);
      // 服务端结果可能与乐观值相等，仍需通知界面解除行内禁用。
      ref.notifyListeners();
    } catch (_) {
      if (ref.mounted) {
        updating.remove(user.id);
        // 仅回滚当前行，保留其他并发操作的结果。
        _replace(user);
      }
      rethrow;
    }
  }

  Future<void> create({
    required String username,
    required String password,
    required UserRole role,
  }) async {
    await ref.read(apiClientProvider).createUser(
      username: username,
      password: password,
      role: role,
    );
    if (ref.mounted) await reload();
  }

  Future<void> reset({required String id, required String newPassword}) {
    return ref.read(apiClientProvider).resetPassword(
      id: id,
      newPassword: newPassword,
    );
  }
}
