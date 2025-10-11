import 'package:swardenapp/app/core/utils/either/either.dart';
import 'package:swardenapp/app/domain/repos/entries_repo.dart';
import 'package:swardenapp/app/core/utils/swarden_exceptions/swarden_exceptions.dart';
import 'package:swardenapp/app/domain/use_cases/base_use_case.dart';

/// Cas d'ús per desbloquejar la bóveda
class UnlockVaultUseCase implements SyncUseCase<bool, UnlockVaultParams> {
  final EntriesRepo entriesRepo;

  UnlockVaultUseCase(this.entriesRepo);

  @override
  Either<SwardenException, bool> call(UnlockVaultParams params) {
    try {
      final success = entriesRepo.unlockVault(
        params.vaultPassword,
        params.userSalt,
        params.dekBox,
      );

      if (!success) {
        return Either.left(SwardenException.wrongPassword());
      }

      return Either.right(true);
    } catch (e) {
      return Either.left(SwardenException.undefined(message: e.toString()));
    }
  }
}

class UnlockVaultParams {
  final String vaultPassword;
  final String userSalt;
  final String dekBox;

  const UnlockVaultParams({
    required this.vaultPassword,
    required this.userSalt,
    required this.dekBox,
  });
}
