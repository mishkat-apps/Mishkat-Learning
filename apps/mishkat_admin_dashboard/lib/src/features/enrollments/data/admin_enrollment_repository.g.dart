// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_enrollment_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminEnrollmentRepository)
const adminEnrollmentRepositoryProvider = AdminEnrollmentRepositoryProvider._();

final class AdminEnrollmentRepositoryProvider
    extends
        $FunctionalProvider<
          AdminEnrollmentRepository,
          AdminEnrollmentRepository,
          AdminEnrollmentRepository
        >
    with $Provider<AdminEnrollmentRepository> {
  const AdminEnrollmentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminEnrollmentRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminEnrollmentRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdminEnrollmentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdminEnrollmentRepository create(Ref ref) {
    return adminEnrollmentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminEnrollmentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminEnrollmentRepository>(value),
    );
  }
}

String _$adminEnrollmentRepositoryHash() =>
    r'43317f1aa68f6dd3bda27b99899418af3f38e3e9';

@ProviderFor(adminEnrollmentList)
const adminEnrollmentListProvider = AdminEnrollmentListFamily._();

final class AdminEnrollmentListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AdminEnrollment>>,
          List<AdminEnrollment>,
          Stream<List<AdminEnrollment>>
        >
    with
        $FutureModifier<List<AdminEnrollment>>,
        $StreamProvider<List<AdminEnrollment>> {
  const AdminEnrollmentListProvider._({
    required AdminEnrollmentListFamily super.from,
    required ({String? uid, String? courseId}) super.argument,
  }) : super(
         retry: null,
         name: r'adminEnrollmentListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminEnrollmentListHash();

  @override
  String toString() {
    return r'adminEnrollmentListProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<AdminEnrollment>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AdminEnrollment>> create(Ref ref) {
    final argument = this.argument as ({String? uid, String? courseId});
    return adminEnrollmentList(
      ref,
      uid: argument.uid,
      courseId: argument.courseId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AdminEnrollmentListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminEnrollmentListHash() =>
    r'95f805df63d1ada2fb381d0af2b943843565b04e';

final class AdminEnrollmentListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<AdminEnrollment>>,
          ({String? uid, String? courseId})
        > {
  const AdminEnrollmentListFamily._()
    : super(
        retry: null,
        name: r'adminEnrollmentListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AdminEnrollmentListProvider call({String? uid, String? courseId}) =>
      AdminEnrollmentListProvider._(
        argument: (uid: uid, courseId: courseId),
        from: this,
      );

  @override
  String toString() => r'adminEnrollmentListProvider';
}
