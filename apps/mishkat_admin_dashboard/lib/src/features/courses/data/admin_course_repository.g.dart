// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_course_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminCourseRepository)
const adminCourseRepositoryProvider = AdminCourseRepositoryProvider._();

final class AdminCourseRepositoryProvider
    extends
        $FunctionalProvider<
          AdminCourseRepository,
          AdminCourseRepository,
          AdminCourseRepository
        >
    with $Provider<AdminCourseRepository> {
  const AdminCourseRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminCourseRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminCourseRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdminCourseRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdminCourseRepository create(Ref ref) {
    return adminCourseRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminCourseRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminCourseRepository>(value),
    );
  }
}

String _$adminCourseRepositoryHash() =>
    r'b76e5296cbf9c694265450481630d54cab57238d';

@ProviderFor(adminCourseList)
const adminCourseListProvider = AdminCourseListProvider._();

final class AdminCourseListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AdminCourseModel>>,
          List<AdminCourseModel>,
          Stream<List<AdminCourseModel>>
        >
    with
        $FutureModifier<List<AdminCourseModel>>,
        $StreamProvider<List<AdminCourseModel>> {
  const AdminCourseListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminCourseListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminCourseListHash();

  @$internal
  @override
  $StreamProviderElement<List<AdminCourseModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AdminCourseModel>> create(Ref ref) {
    return adminCourseList(ref);
  }
}

String _$adminCourseListHash() => r'85946690f1685c6f8cca5d7a0585967f8558090d';
