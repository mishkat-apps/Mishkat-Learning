import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mishkat_admin_dashboard/src/features/users/domain/admin_user_model.dart';

part 'admin_user_repository.g.dart';

class AdminUserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  AdminUserRepository(this._firestore, this._functions);

  Stream<List<AdminUserModel>> watchUsers({String? searchTerm}) {
    var query = _firestore.collection('users').orderBy('createdAt', descending: true);
    
    return query.snapshots().map((snapshot) {
      final users = snapshot.docs.map((doc) => AdminUserModel.fromFirestore(doc)).toList();
      
      if (searchTerm != null && searchTerm.isNotEmpty) {
        final term = searchTerm.toLowerCase();
        return users.where((u) => 
          u.email.toLowerCase().contains(term) || 
          u.displayName.toLowerCase().contains(term)
        ).toList();
      }
      return users;
    });
  }

  Future<void> setUserRole(String targetUid, String role) async {
    final callable = _functions.httpsCallable('adminSetUserRole');
    await callable.call({
      'targetUid': targetUid,
      'role': role,
    });
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<AdminUserModel> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return AdminUserModel.fromFirestore(doc);
  }
}

@riverpod
AdminUserRepository adminUserRepository(Ref ref) {
  return AdminUserRepository(
    FirebaseFirestore.instance,
    FirebaseFunctions.instance,
  );
}

@riverpod
class UserSearchTerm extends _$UserSearchTerm {
  @override
  String build() => '';
  
  void set(String term) => state = term;
}

@riverpod
Stream<List<AdminUserModel>> adminUserList(Ref ref) {
  final term = ref.watch(userSearchTermProvider);
  return ref.watch(adminUserRepositoryProvider).watchUsers(searchTerm: term);
}

@riverpod
Future<AdminUserModel> adminUserDetails(Ref ref, String uid) {
  return ref.watch(adminUserRepositoryProvider).getUser(uid);
}
