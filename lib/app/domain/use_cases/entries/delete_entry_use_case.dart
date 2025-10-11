import 'package:swardenapp/app/core/utils/either/either.dart';
import 'package:swardenapp/app/domain/repos/entries_repo.dart';
import 'package:swardenapp/app/core/utils/swarden_exceptions/swarden_exceptions.dart';
import 'package:swardenapp/app/domain/use_cases/base_use_case.dart';

/// Cas d'ús per eliminar una entrada
class DeleteEntryUseCase implements UseCase<bool, DeleteEntryParams> {
  final EntriesRepo entriesRepo;

  DeleteEntryUseCase(this.entriesRepo);

  @override
  Future<Either<SwardenException, bool>> call(DeleteEntryParams params) async {
    try {
      final result = await entriesRepo.deleteEntry(
        params.userId,
        params.entryId,
      );
      return Either.right(result);
    } catch (e) {
      return Either.left(SwardenException.undefined(message: e.toString()));
    }
  }
}

class DeleteEntryParams {
  final String userId;
  final String entryId;

  const DeleteEntryParams({required this.userId, required this.entryId});
}
