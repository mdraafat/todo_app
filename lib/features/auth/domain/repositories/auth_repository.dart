import '../../data/models/user.dart';

abstract class AuthRepository {
  Future<User?> signInWithGoogle();
  Future<void> signOut();
  Stream<User?> get authStateChanges;
  User? get currentUser;
}