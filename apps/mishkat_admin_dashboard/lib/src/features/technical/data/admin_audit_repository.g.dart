// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_audit_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminAuditRepository)
const adminAuditRepositoryProvider = AdminAuditRepositoryProvider._();

final class AdminAuditRepositoryProvider
    extends
        $FunctionalProvider<
          AdminAuditRepository,
          AdminAuditRepository,
          AdminAuditRepository
        >
    with $Provider<AdminAuditRepository> {
  const AdminAuditRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminAuditRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminAuditRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdminAuditRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdminAuditRepository create(Ref ref) {
    return adminAuditRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminAuditRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminAuditRepository>(value),
    );
  }
}

String _$adminAuditRepositoryHash() =>
    r'7b483dd6f6102e4d2b9f639215488d5c9f3fb3d2';

@ProviderFor(adminAuditLogs)
const adminAuditLogsProvider = AdminAuditLogsFamily._();

final class AdminAuditLogsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AdminAuditModel>>,
          List<AdminAuditModel>,
          Stream<List<AdminAuditModel>>
        >
    with
        $FutureModifier<List<AdminAuditModel>>,
        $StreamProvider<List<AdminAuditModel>> {
  const AdminAuditLogsProvider._({
    required AdminAuditLogsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'adminAuditLogsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminAuditLogsHash();

  @override
  String toString() {
    return r'adminAuditLogsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<AdminAuditModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AdminAuditModel>> create(Ref ref) {
    final argument = this.argument as int;
    return adminAuditLogs(ref, limit: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminAuditLogsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminAuditLogsHash() => r'161329afbe0e45116b9b6995612ccedcc8026474';

final class AdminAuditLogsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<AdminAuditModel>>, int> {
  const AdminAuditLogsFamily._()
    : super(
        retry: null,
        name: r'adminAuditLogsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AdminAuditLogsProvider call({int limit = 50}) =>
      AdminAuditLogsProvider._(argument: limit, from: this);

  @override
  String toString() => r'adminAuditLogsProvider';
}
