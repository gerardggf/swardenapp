import 'package:flutter_riverpod/legacy.dart';
import 'package:swardenapp/app/domain/either/either.dart';
import 'package:swardenapp/app/domain/swarden_exceptions/swarden_exceptions.dart';
import 'package:swardenapp/app/domain/use_cases/use_case_providers.dart';
import 'package:swardenapp/app/domain/use_cases/auth/sign_in_use_case.dart';
import 'package:swardenapp/app/domain/use_cases/auth/register_user_use_case.dart';
import 'package:swardenapp/app/domain/use_cases/auth/sign_out_use_case.dart';
import 'package:swardenapp/app/domain/use_cases/auth/get_current_user_use_case.dart';
import 'package:swardenapp/app/domain/use_cases/auth/delete_account_use_case.dart';
import '../../domain/models/user_model.dart';

final sessionControllerProvider =
    StateNotifierProvider<SessionController, UserModel?>(
      (ref) => SessionController(
        null,
        ref.watch(signInUseCaseProvider),
        ref.watch(registerUserUseCaseProvider),
        ref.watch(signOutUseCaseProvider),
        ref.watch(getCurrentUserUseCaseProvider),
        ref.watch(deleteAccountUseCaseProvider),
      ),
    );

class SessionController extends StateNotifier<UserModel?> {
  final SignInUseCase signInUseCase;
  final RegisterUserUseCase registerUserUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;

  SessionController(
    super.state,
    this.signInUseCase,
    this.registerUserUseCase,
    this.signOutUseCase,
    this.getCurrentUserUseCase,
    this.deleteAccountUseCase,
  );

  Future<Either<SwardenException, UserModel?>> register(
    String email,
    String password,
    String vaultPassword,
  ) async {
    final user = await registerUserUseCase(
      RegisterUserParams(
        email: email,
        password: password,
        vaultPassword: vaultPassword,
      ),
    );

    state = user.when(left: (_) => null, right: (r) => r);
    return user;
  }

  Future<Either<SwardenException, UserModel?>> signIn(
    String email,
    String password,
  ) async {
    final user = await signInUseCase(
      SignInParams(email: email, password: password),
    );

    state = user.when(left: (_) => null, right: (r) => r);
    return user;
  }

  Future<Either<SwardenException, UserModel?>> restoreSession() async {
    final userResult = await getCurrentUserUseCase();

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

  void setUser(UserModel? user) {
    state = user;
  }

  Future<void> signOut() async {
    await signOutUseCase();
    state = null;
  }

  Future<void> deleteAccount() async {
    await deleteAccountUseCase();
    state = null;
  }
}
