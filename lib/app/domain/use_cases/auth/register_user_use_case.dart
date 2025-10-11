import 'package:swardenapp/app/core/utils/either/either.dart';
import 'package:swardenapp/app/domain/models/user_model.dart';
import 'package:swardenapp/app/domain/repos/auth_repo.dart';
import 'package:swardenapp/app/core/utils/swarden_exceptions/swarden_exceptions.dart';
import 'package:swardenapp/app/domain/use_cases/base_use_case.dart';

/// Cas d'ús per registrar un nou usuari
class RegisterUserUseCase implements UseCase<UserModel?, RegisterUserParams> {
  final AuthRepo authRepo;

  RegisterUserUseCase(this.authRepo);

  @override
  Future<Either<SwardenException, UserModel?>> call(
    RegisterUserParams params,
  ) async {
    return await authRepo.register(
      params.email,
      params.password,
      params.vaultPassword,
    );
  }
}

class RegisterUserParams {
  final String email;
  final String password;
  final String vaultPassword;

  const RegisterUserParams({
    required this.email,
    required this.password,
    required this.vaultPassword,
  });
}
