import 'package:flutter/foundation.dart';
import 'package:swardenapp/app/core/typedefs.dart';
import 'package:swardenapp/app/domain/either/either.dart';
import 'package:swardenapp/app/domain/swarden_exceptions/swarden_exceptions.dart';
import 'package:swardenapp/app/domain/models/user_model.dart';
import 'package:swardenapp/app/domain/repos/auth_repo.dart';
import '../services/firebase_auth_service.dart';
import '../services/firebase_firestore_service.dart';
import '../services/crypto_service.dart';

class AuthRepoImpl implements AuthRepo {
  final FirebaseAuthService firebaseAuthService;
  final FirebaseFirestoreService firestoreService;
  final CryptoService cryptoService;

  AuthRepoImpl({
    required this.firebaseAuthService,
    required this.firestoreService,
    required this.cryptoService,
  });

  @override
  AsyncSwardenResult<UserModel?> register(String email, String password) async {
    try {
      // Crear usuari a Firebase Auth
      final credentialEither = await firebaseAuthService
          .registerWithEmailAndPassword(email: email, password: password);

      return credentialEither.when(
        left: (exception) => Either.left(exception),
        right: (cred) async {
          // Crear element del usuari a Firestore
          // Retornar salt i dekBox
          final vaultData = cryptoService.createUserVault(password);
          final user = UserModel(
            uid: cred.user!.uid,
            email: cred.user!.email ?? email,
            salt: vaultData.$1,
            dekBox: vaultData.$2,
          );
          await firestoreService.createUser(user: user);

          return Either.right(user);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error en registre: $e');
      }
      return Either.left(SwardenException.undefined(message: e.toString()));
    }
  }

  @override
  AsyncSwardenResult<UserModel?> signIn(String email, String password) async {
    try {
      final credentialEither = await firebaseAuthService
          .signInWithEmailAndPassword(email: email, password: password);

      return credentialEither.when(
        left: (exception) => Either.left(exception),
        right: (cred) async {
          final user = await firestoreService.loadUser(cred.user!.uid);
          if (user == null) {
            return Either.left(SwardenException.userNotFound());
          }
          return Either.right(user);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error en login: $e');
      }
      return Either.left(SwardenException.undefined(message: e.toString()));
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      await firebaseAuthService.signOut();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
      return false;
    }
  }

  @override
  AsyncSwardenResult<UserModel?> getCurrentUser() async {
    try {
      // Verificar si hay un usuario autenticado en Firebase
      final currentFirebaseUser = firebaseAuthService.currentUser;

      if (currentFirebaseUser == null) {
        return Either.left(SwardenException.noCredentials());
      }

      // Cargar los datos del usuario desde Firestore
      final user = await firestoreService.loadUser(currentFirebaseUser.uid);

      if (user == null) {
        return Either.left(SwardenException.userNotFound());
      }

      return Either.right(user);
    } catch (e) {
      if (kDebugMode) {
        print('Error obteniendo usuario actual: $e');
      }
      return Either.left(SwardenException.undefined(message: e.toString()));
    }
  }

  @override
  Future<bool> deleteAccount() async {
    try {
      final uid = firebaseAuthService.currentUser?.uid;
      if (uid == null) return false;
      final authDeleted = await firebaseAuthService.deleteUserAccount();
      if (!authDeleted) return false;
      final firestoreDeleted = await firestoreService.deleteUser(uid);
      return firestoreDeleted;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting account: $e');
      }
      return false;
    }
  }
}
