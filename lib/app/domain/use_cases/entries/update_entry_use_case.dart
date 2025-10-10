import 'package:swardenapp/app/domain/either/either.dart';
import 'package:swardenapp/app/domain/models/entry_model.dart';
import 'package:swardenapp/app/domain/repos/entries_repo.dart';
import 'package:swardenapp/app/domain/swarden_exceptions/swarden_exceptions.dart';
import 'package:swardenapp/app/domain/use_cases/base_use_case.dart';

/// Cas d'ús per actualitzar una entrada existent
class UpdateEntryUseCase implements UseCase<bool, UpdateEntryParams> {
  final EntriesRepo entriesRepo;

  UpdateEntryUseCase(this.entriesRepo);

  @override
  Future<Either<SwardenException, bool>> call(UpdateEntryParams params) async {
    try {
      final result = await entriesRepo.updateEntry(
        params.userId,
        params.entryId,
        params.entry,
      );
      return Either.right(result);
    } catch (e) {
      return Either.left(SwardenException.undefined(message: e.toString()));
    }
  }
}

class UpdateEntryParams {
  final String userId;
  final String entryId;
  final EntryDataModel entry;

  const UpdateEntryParams({
    required this.userId,
    required this.entryId,
    required this.entry,
  });
}
