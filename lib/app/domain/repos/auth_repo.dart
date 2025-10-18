import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swardenapp/app/core/typedefs.dart';
import 'package:swardenapp/app/data/repo_impl/auth_repo_impl.dart';
import 'package:swardenapp/app/data/services/crypto_service.dart';
import 'package:swardenapp/app/data/services/firebase_auth_service.dart';
import 'package:swardenapp/app/data/services/firestore_user_service.dart';
import 'package:swardenapp/app/domain/models/user_model.dart';

final authRepoProvider = Provider<AuthRepo>(
  (ref) => AuthRepoImpl(
    firebaseAuthService: ref.watch(firebaseAuthServiceProvider),
    firestoreService: ref.watch(firestoreUserServiceProvider),
    cryptoService: ref.watch(cryptoServiceProvider),
  ),
);

abstract class AuthRepo {
  AsyncSwardenResult<UserModel?> signIn(String email, String password);
  Future<bool> signOut();
  AsyncSwardenResult<UserModel?> register(
    String email,
    String password,
    String vaultPassword,
  );
  AsyncSwardenResult<UserModel?> getCurrentUser();
  Future<bool> reauthenticate(String password);
  Future<bool> deleteAccount();
}
