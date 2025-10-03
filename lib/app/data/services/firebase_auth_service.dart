import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swardenapp/app/core/global_providers.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>(
  (ref) => FirebaseAuthService(auth: ref.watch(firebaseAuthProvider)),
);

class FirebaseAuthService {
  final FirebaseAuth auth;

  FirebaseAuthService({required this.auth});

  /// Usuari actual de Firebase Auth
  User? get currentUser => auth.currentUser;

  /// Stream per escoltar canvis d'autenticació
  Stream<User?> get authStateChanges => auth.authStateChanges();

  /// Registre amb email i contrasenya
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Inici de sessió amb email i contrasenya
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Tancar sessió
  Future<void> signOut() async {
    await auth.signOut();
  }

  /// Eliminar compte
  Future<void> deleteAccount() async {
    final user = auth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  /// Gestió d'errors d'autenticació
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'La contrasenya és massa feble';
      case 'email-already-in-use':
        return 'Aquest email ja està en ús';
      case 'user-not-found':
        return 'No s\'ha trobat cap usuari amb aquest email';
      case 'wrong-password':
        return 'Contrasenya incorrecta';
      case 'invalid-email':
        return 'Email invàlid';
      case 'user-disabled':
        return 'Aquest compte ha estat desactivat';
      default:
        return 'Error d\'autenticació: ${e.message}';
    }
  }
}
