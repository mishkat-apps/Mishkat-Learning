// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminUserRepository)
const adminUserRepositoryProvider = AdminUserRepositoryProvider._();

final class AdminUserRepositoryProvider
    extends
        $FunctionalProvider<
          AdminUserRepository,
          AdminUserRepository,
          AdminUserRepository
        >
    with $Provider<AdminUserRepository> {
  const AdminUserRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminUserRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminUserRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdminUserRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdminUserRepository create(Ref ref) {
    return adminUserRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminUserRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminUserRepository>(value),
    );
  }
}

String _$adminUserRepositoryHash() =>
    r'7a75e367e94b0786f0dfa5eae4c7a07230f91b49';

@ProviderFor(UserSearchTerm)
const userSearchTermProvider = UserSearchTermProvider._();

final class UserSearchTermProvider
    extends $NotifierProvider<UserSearchTerm, String> {
  const UserSearchTermProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userSearchTermProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userSearchTermHash();

  @$internal
  @override
  UserSearchTerm create() => UserSearchTerm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$userSearchTermHash() => r'e9e99867e7a18e5f887e08b7b4f980cd37132683';

abstract class _$UserSearchTerm extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(adminUserList)
const adminUserListProvider = AdminUserListProvider._();

final class AdminUserListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AdminUserModel>>,
          List<AdminUserModel>,
          Stream<List<AdminUserModel>>
        >
    with
        $FutureModifier<List<AdminUserModel>>,
        $StreamProvider<List<AdminUserModel>> {
  const AdminUserListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminUserListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminUserListHash();

  @$internal
  @override
  $StreamProviderElement<List<AdminUserModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AdminUserModel>> create(Ref ref) {
    return adminUserList(ref);
  }
}

String _$adminUserListHash() => r'89ebe79e7808ea2042100fc112331694a143dfab';

@ProviderFor(adminUserDetails)
const adminUserDetailsProvider = AdminUserDetailsFamily._();

final class AdminUserDetailsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AdminUserModel>,
          AdminUserModel,
          FutureOr<AdminUserModel>
        >
    with $FutureModifier<AdminUserModel>, $FutureProvider<AdminUserModel> {
  const AdminUserDetailsProvider._({
    required AdminUserDetailsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'adminUserDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminUserDetailsHash();

  @override
  String toString() {
    return r'adminUserDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AdminUserModel> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AdminUserModel> create(Ref ref) {
    final argument = this.argument as String;
    return adminUserDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminUserDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminUserDetailsHash() => r'21e23b4e94f6b5e4954fbb5397ae43b9baa142eb';

final class AdminUserDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AdminUserModel>, String> {
  const AdminUserDetailsFamily._()
    : super(
        retry: null,
        name: r'adminUserDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AdminUserDetailsProvider call(String uid) =>
      AdminUserDetailsProvider._(argument: uid, from: this);

  @override
  String toString() => r'adminUserDetailsProvider';
}
