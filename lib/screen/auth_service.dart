import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// NOTE: Google Sign-In integration was causing build-time errors
  /// due to breaking API changes in the `google_sign_in` package.
  /// To make the project build reliably, this method is a safe stub
  /// that returns null. Reintroduce the real Google Sign-In flow
  /// once the project updates `google_sign_in` usage to the
  /// installed package API.
  Future<User?> signInWithGoogle() async {
    // Stub: no-op sign in
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}