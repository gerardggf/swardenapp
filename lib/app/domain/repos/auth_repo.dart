import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swardenapp/app/core/typedefs.dart';
import 'package:swardenapp/app/data/repo_impl/auth_repo_impl.dart';
import 'package:swardenapp/app/data/services/crypto_service.dart';
import 'package:swardenapp/app/data/services/firebase_auth_service.dart';
import 'package:swardenapp/app/data/services/firestore_user_service.dart';
import 'package:swardenapp/app/domain/models/user_model.dart';

/// Proveïdor del repositori d'autenticació d'usuaris
final authRepoProvider = Provider<AuthRepo>(
  (ref) => AuthRepoImpl(
    firebaseAuthService: ref.watch(firebaseAuthServiceProvider),
    firestoreService: ref.watch(firestoreUserServiceProvider),
    cryptoService: ref.watch(cryptoServiceProvider),
  ),
);

/// Repositori per a l'autenticació d'usuaris
abstract class AuthRepo {
  /// Inicia sessió amb correu electrònic i contrasenya
  AsyncSwardenResult<UserModel?> signIn(String email, String password);

  /// Tanca la sessió de l'usuari actual
  Future<bool> signOut();

  /// Registra un nou usuari amb correu electrònic, contrasenya i contrasenya de la bóveda
  AsyncSwardenResult<UserModel?> register(
    String email,
    String password,
    String vaultPassword,
  );

  /// Obté l'usuari actual
  AsyncSwardenResult<UserModel?> getCurrentUser();

  /// Reautentica l'usuari amb la contrasenya
  Future<bool> reauthenticate(String password);

  /// Elimina el compte de l'usuari actual
  Future<bool> deleteAccount();
}
