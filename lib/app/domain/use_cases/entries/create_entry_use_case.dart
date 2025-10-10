import 'package:swardenapp/app/domain/either/either.dart';
import 'package:swardenapp/app/domain/models/entry_model.dart';
import 'package:swardenapp/app/domain/repos/entries_repo.dart';
import 'package:swardenapp/app/domain/swarden_exceptions/swarden_exceptions.dart';
import 'package:swardenapp/app/domain/use_cases/base_use_case.dart';

/// Cas d'ús per crear una nova entrada
class CreateEntryUseCase implements UseCase<bool, CreateEntryParams> {
  final EntriesRepo entriesRepo;

  CreateEntryUseCase(this.entriesRepo);

  @override
  Future<Either<SwardenException, bool>> call(CreateEntryParams params) async {
    try {
      final result = await entriesRepo.addEntry(params.userId, params.entry);
      return Either.right(result);
    } catch (e) {
      return Either.left(SwardenException.undefined(message: e.toString()));
    }
  }
}

class CreateEntryParams {
  final String userId;
  final EntryDataModel entry;

  const CreateEntryParams({required this.userId, required this.entry});
}
