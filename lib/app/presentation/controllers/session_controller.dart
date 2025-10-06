import 'package:flutter_riverpod/legacy.dart';
import 'package:swardenapp/app/domain/either/either.dart';
import 'package:swardenapp/app/domain/repos/auth_repo.dart';
import 'package:swardenapp/app/domain/swarden_exceptions/swarden_exceptions.dart';
import '../../domain/models/user_model.dart';

final sessionControllerProvider =
    StateNotifierProvider<SessionController, UserModel?>(
      (ref) => SessionController(null, ref.watch(authRepoProvider)),
    );

class SessionController extends StateNotifier<UserModel?> {
  final AuthRepo authRepo;

  SessionController(super.state, this.authRepo);

  /// Registro de nuevo usuario (login activo)
  Future<Either<SwardenException, UserModel?>> register(
    String email,
    String password,
    String vaultPassword,
  ) async {
    final user = await authRepo.register(email, password, vaultPassword);

    state = user.when(left: (_) => null, right: (r) => r);
    return user;
  }

  /// Login con credenciales (login activo)
  Future<Either<SwardenException, UserModel?>> signIn(
    String email,
    String password,
  ) async {
    final user = await authRepo.signIn(email, password);

    state = user.when(left: (_) => null, right: (r) => r);
    return user;
  }

  /// Recuperar usuario existente de sesión persistente (sin credenciales)
  Future<Either<SwardenException, UserModel?>> restoreSession() async {
    final userResult = await authRepo.getCurrentUser();

    return userResult.when(
      left: (exception) {
        state = null;
        return Either.left(exception);
      },
      right: (user) {
        state = user;
        return Either.right(user);
      },
    );
  }

  /// Método auxiliar para actualizar el estado sin lógica de autenticación
  void setUser(UserModel? user) {
    state = user;
  }

  /// Tancar sessió
  Future<void> signOut() async {
    await authRepo.signOut();
    state = null;
  }

  /// Borrar compte
  Future<void> deleteAccount() async {
    await authRepo.deleteAccount();
    state = null;
  }
}
