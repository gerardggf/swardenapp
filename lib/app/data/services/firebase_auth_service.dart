import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swardenapp/app/core/extensions/swarden_exceptions_extensions.dart';
import 'package:swardenapp/app/core/global_providers.dart';
import 'package:swardenapp/app/core/typedefs.dart';
import 'package:swardenapp/app/core/utils/either/either.dart';
import 'package:swardenapp/app/core/utils/swarden_exceptions/swarden_exceptions.dart';

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
  AsyncSwardenResult<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Either.right(userCredential);
    } on FirebaseAuthException catch (e) {
      return Either.left(e.code.fromFirebaseError());
    } catch (e) {
      return Either.left(SwardenException.undefined(message: e.toString()));
    }
  }

  /// Inici de sessió amb email i contrasenya
  AsyncSwardenResult<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredentials = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Either.right(userCredentials);
    } on FirebaseAuthException catch (e) {
      return Either.left(e.code.fromFirebaseError());
    } catch (e) {
      return Either.left(SwardenException.undefined(message: e.toString()));
    }
  }

  /// Tancar sessió
  Future<void> signOut() async {
    await auth.signOut();
  }

  /// Reautenticar usuari amb la seva contrasenya
  Future<bool> reauthenticate(String password) async {
    try {
      final user = auth.currentUser;
      if (user?.email == null) return false;

      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Eliminar compte
  Future<bool> deleteUserAccount() async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        await user.delete();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      // Si requereix autenticació recent, retorna false perquè el controlador pugui gestionar-ho
      if (e.code == 'requires-recent-login') {
        rethrow;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
