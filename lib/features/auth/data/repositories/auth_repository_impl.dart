import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRepositoryImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  @override
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(credential);
      return _mapFirebaseUser(userCredential.user);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      firebaseAuth.signOut(),
      googleSignIn.signOut(),
    ]);
  }

  @override
  Stream<User?> get authStateChanges {
    return firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  User? get currentUser => _mapFirebaseUser(firebaseAuth.currentUser);

  User? _mapFirebaseUser(firebase_auth.User? firebaseUser) {
    if (firebaseUser == null) return null;
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
    );
  }
}