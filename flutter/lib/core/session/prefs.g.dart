// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prefs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 在 `main()` 里用 `overrideWithValue` 注入，保证各处同步读偏好。

@ProviderFor(prefs)
final prefsProvider = PrefsProvider._();

/// 在 `main()` 里用 `overrideWithValue` 注入，保证各处同步读偏好。

final class PrefsProvider extends $FunctionalProvider<Prefs, Prefs, Prefs>
    with $Provider<Prefs> {
  /// 在 `main()` 里用 `overrideWithValue` 注入，保证各处同步读偏好。
  PrefsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'prefsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$prefsHash();

  @$internal
  @override
  $ProviderElement<Prefs> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Prefs create(Ref ref) {
    return prefs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Prefs value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Prefs>(value),
    );
  }
}

String _$prefsHash() => r'ded257991787a85d6eea913bb1ca33bec16efaa4';
