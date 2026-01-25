// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_payment_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminPaymentRepository)
const adminPaymentRepositoryProvider = AdminPaymentRepositoryProvider._();

final class AdminPaymentRepositoryProvider
    extends
        $FunctionalProvider<
          AdminPaymentRepository,
          AdminPaymentRepository,
          AdminPaymentRepository
        >
    with $Provider<AdminPaymentRepository> {
  const AdminPaymentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminPaymentRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminPaymentRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdminPaymentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdminPaymentRepository create(Ref ref) {
    return adminPaymentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminPaymentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminPaymentRepository>(value),
    );
  }
}

String _$adminPaymentRepositoryHash() =>
    r'df29f762422ea20c6ee30f5cc9b22ef9d23c6b17';

@ProviderFor(adminPaymentList)
const adminPaymentListProvider = AdminPaymentListFamily._();

final class AdminPaymentListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AdminPaymentModel>>,
          List<AdminPaymentModel>,
          Stream<List<AdminPaymentModel>>
        >
    with
        $FutureModifier<List<AdminPaymentModel>>,
        $StreamProvider<List<AdminPaymentModel>> {
  const AdminPaymentListProvider._({
    required AdminPaymentListFamily super.from,
    required ({int limit, String? status}) super.argument,
  }) : super(
         retry: null,
         name: r'adminPaymentListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminPaymentListHash();

  @override
  String toString() {
    return r'adminPaymentListProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<AdminPaymentModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AdminPaymentModel>> create(Ref ref) {
    final argument = this.argument as ({int limit, String? status});
    return adminPaymentList(
      ref,
      limit: argument.limit,
      status: argument.status,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AdminPaymentListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminPaymentListHash() => r'e91ec0cffdd9336499e882bd746e2f6dc7ede5ab';

final class AdminPaymentListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<AdminPaymentModel>>,
          ({int limit, String? status})
        > {
  const AdminPaymentListFamily._()
    : super(
        retry: null,
        name: r'adminPaymentListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AdminPaymentListProvider call({int limit = 50, String? status}) =>
      AdminPaymentListProvider._(
        argument: (limit: limit, status: status),
        from: this,
      );

  @override
  String toString() => r'adminPaymentListProvider';
}

@ProviderFor(adminPaymentDetails)
const adminPaymentDetailsProvider = AdminPaymentDetailsFamily._();

final class AdminPaymentDetailsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AdminPaymentModel>,
          AdminPaymentModel,
          FutureOr<AdminPaymentModel>
        >
    with
        $FutureModifier<AdminPaymentModel>,
        $FutureProvider<AdminPaymentModel> {
  const AdminPaymentDetailsProvider._({
    required AdminPaymentDetailsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'adminPaymentDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminPaymentDetailsHash();

  @override
  String toString() {
    return r'adminPaymentDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AdminPaymentModel> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AdminPaymentModel> create(Ref ref) {
    final argument = this.argument as String;
    return adminPaymentDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminPaymentDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminPaymentDetailsHash() =>
    r'6f9f3c420bc88fb173fea5313474fd7bb8a0ac9c';

final class AdminPaymentDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AdminPaymentModel>, String> {
  const AdminPaymentDetailsFamily._()
    : super(
        retry: null,
        name: r'adminPaymentDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AdminPaymentDetailsProvider call(String id) =>
      AdminPaymentDetailsProvider._(argument: id, from: this);

  @override
  String toString() => r'adminPaymentDetailsProvider';
}
