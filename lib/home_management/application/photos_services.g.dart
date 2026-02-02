// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photos_services.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(photosServices)
final photosServicesProvider = PhotosServicesProvider._();

final class PhotosServicesProvider
    extends $FunctionalProvider<PhotosServices, PhotosServices, PhotosServices>
    with $Provider<PhotosServices> {
  PhotosServicesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'photosServicesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$photosServicesHash();

  @$internal
  @override
  $ProviderElement<PhotosServices> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PhotosServices create(Ref ref) {
    return photosServices(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhotosServices value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PhotosServices>(value),
    );
  }
}

String _$photosServicesHash() => r'e13056fb85f7ce2cb3dc2e0ecbf859d05b30d11b';
