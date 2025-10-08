import 'package:flutter/foundation.dart';
import 'package:swardenapp/app/core/typedefs.dart';
import 'package:swardenapp/app/domain/either/either.dart';
import 'package:swardenapp/app/domain/swarden_exceptions/swarden_exceptions.dart';
import 'package:swardenapp/app/domain/models/user_model.dart';
import 'package:swardenapp/app/domain/repos/auth_repo.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_user_service.dart';
import '../services/crypto_service.dart';

class AuthRepoImpl implements AuthRepo {
  final FirebaseAuthService firebaseAuthService;
  final FirestoreUserService firestoreService;
  final CryptoService cryptoService;

  AuthRepoImpl({
    required this.firebaseAuthService,
    required this.firestoreService,
    required this.cryptoService,
  });

  @override
  AsyncSwardenResult<UserModel?> register(
    String email,
    String password,
    String vaultPassword,
  ) async {
    try {
      // Registre a Firebase Auth
      final credentialEither = await firebaseAuthService
          .registerWithEmailAndPassword(email: email, password: password);

      return credentialEither.when(
        left: (exception) => Either.left(exception),
        right: (cred) async {
          // Es crea la bóveda de l'usuari amb la contrasenya de la bóveda
          final vaultData = cryptoService.createUserVault(vaultPassword);
          final user = UserModel(
            uid: cred.user!.uid,
            email: cred.user!.email ?? email,
            salt: vaultData.$1,
            dekBox: vaultData.$2,
          );
          // Es desa l'usuari a Firestore
          await firestoreService.createUser(user: user);

          // Desbloqueja automàticament la bóveda creada amb la contrasenya de la bóveda
          final unlockSuccess = cryptoService.unlock(vaultPassword, user);
          if (!unlockSuccess) {
            if (kDebugMode) {
              print(
                'Warning: No s\'ha pogut desbloquejar la bóveda automàticament després del registre',
              );
            }
          }

          // Retorna l'usuari creat per establir la sessió
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
      // Inici de sessió a Firebase Auth
      final credentialEither = await firebaseAuthService
          .signInWithEmailAndPassword(email: email, password: password);

      return credentialEither.when(
        left: (exception) => Either.left(exception),
        right: (cred) async {
          // Es carrega l'usuari de Firestore
          final user = await firestoreService.loadUser(cred.user!.uid);
          if (user == null) {
            return Either.left(SwardenException.userNotFound());
          }

          // No es pot desbloquejar la bóveda, ja que cal la contrasenya
          // que introduirà l'usuari a la pantalla /unlock-vault

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
      // Es bloqueja la bóveda abans de tancar sessió
      cryptoService.lock();

      // Tanca sessió a Firebase Auth
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
      final currentFirebaseUser = firebaseAuthService.currentUser;

      if (currentFirebaseUser == null) {
        return Either.left(SwardenException.noCredentials());
      }

      // Es carrega l'usuari de Firestore
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

      // Es bloqueja la bóveda abans d'eliminar el compte
      cryptoService.lock();

      // Esborra l'usuari de Firebase Auth
      final authDeleted = await firebaseAuthService.deleteUserAccount();
      if (!authDeleted) return false;
      // Esborra l'usuari de Firestore si s'ha esborrat de Firebase Auth
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
