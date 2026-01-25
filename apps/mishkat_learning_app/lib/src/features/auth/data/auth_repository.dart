import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'user_repository.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '59319593263-8e9baoelklse564258nc6iib6iuq9h19.apps.googleusercontent.com',
  );
  final UserRepository _userRepository;

  AuthRepository(this._userRepository);


  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    await _ensureUserProfileCreated(credential.user);
    
    
    return credential;
  }

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (credential.user != null) {
      final newUser = MishkatUser(
        id: credential.user!.uid,
        email: email,
        displayName: email.split('@')[0], // Placeholder
        role: 'student',
        rank: 'Seeker',
        studyTimeMinutes: 0,
        certificates: [],
        createdAt: DateTime.now(),
      );
      await _userRepository.createUserProfile(newUser);
    }
    return credential;
  }

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    await _ensureUserProfileCreated(userCredential.user);
    return userCredential;
  }

  Future<UserCredential?> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final OAuthCredential credential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    await _ensureUserProfileCreated(userCredential.user);
    return userCredential;
  }

  Future<MishkatUser?> _ensureUserProfileCreated(User? user) async {
    if (user == null) return null;
    
    var profile = await _userRepository.getUserProfile(user.uid);
    if (profile == null) {
      profile = MishkatUser(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? user.email?.split('@')[0] ?? 'Seeker',
        photoUrl: user.photoURL,
        role: 'student',
        rank: 'Seeker',
        studyTimeMinutes: 0,
        certificates: [],
        createdAt: DateTime.now(),
      );
      await _userRepository.createUserProfile(profile);
    }
    return profile;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signOut();
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return AuthRepository(userRepository);
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
