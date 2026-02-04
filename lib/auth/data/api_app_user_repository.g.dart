// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_app_user_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(apiAppUserRepository)
final apiAppUserRepositoryProvider = ApiAppUserRepositoryProvider._();

final class ApiAppUserRepositoryProvider
    extends
        $FunctionalProvider<
          ApiAppUserRepository,
          ApiAppUserRepository,
          ApiAppUserRepository
        >
    with $Provider<ApiAppUserRepository> {
  ApiAppUserRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiAppUserRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiAppUserRepositoryHash();

  @$internal
  @override
  $ProviderElement<ApiAppUserRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ApiAppUserRepository create(Ref ref) {
    return apiAppUserRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiAppUserRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiAppUserRepository>(value),
    );
  }
}

String _$apiAppUserRepositoryHash() =>
    r'43866ba0a7ae449b14c105bec7310c777e8b470e';
