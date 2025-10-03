import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swardenapp/app/data/repo_impl/auth_repo_impl.dart';
import 'package:swardenapp/app/data/services/crypto_service.dart';
import 'package:swardenapp/app/data/services/firebase_auth_service.dart';
import 'package:swardenapp/app/data/services/firestore_service.dart';
import 'package:swardenapp/app/domain/models/user_model.dart';

final authRepoProvider = Provider<AuthRepo>(
  (ref) => AuthRepoImpl(
    firebaseAuthService: ref.watch(firebaseAuthServiceProvider),
    firestoreService: ref.watch(firestoreServiceProvider),
    cryptoService: ref.watch(cryptoServiceProvider),
  ),
);

abstract class AuthRepo {
  Future<UserModel?> signIn(String email, String password);
  Future<void> signOut();
  Future<UserModel?> register(String email, String password);
}
