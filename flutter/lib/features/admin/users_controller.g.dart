// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UsersController)
final usersControllerProvider = UsersControllerProvider._();

final class UsersControllerProvider
    extends $AsyncNotifierProvider<UsersController, Page<UserRead>> {
  UsersControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usersControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usersControllerHash();

  @$internal
  @override
  UsersController create() => UsersController();
}

String _$usersControllerHash() => r'b0fdab2c0dd75c4b19ae9075b764d3c826118157';

abstract class _$UsersController extends $AsyncNotifier<Page<UserRead>> {
  FutureOr<Page<UserRead>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Page<UserRead>>, Page<UserRead>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Page<UserRead>>, Page<UserRead>>,
              AsyncValue<Page<UserRead>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
