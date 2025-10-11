import 'package:swardenapp/app/core/utils/either/either.dart';
import 'package:swardenapp/app/domain/models/entry_model.dart';
import 'package:swardenapp/app/domain/repos/entries_repo.dart';
import 'package:swardenapp/app/core/utils/swarden_exceptions/swarden_exceptions.dart';
import 'package:swardenapp/app/domain/use_cases/base_use_case.dart';

/// Cas d'ús per obtenir totes les entrades d'un usuari
class GetUserEntriesUseCase
    implements UseCase<List<EntryDataModel>, GetUserEntriesParams> {
  final EntriesRepo entriesRepo;

  GetUserEntriesUseCase(this.entriesRepo);

  @override
  Future<Either<SwardenException, List<EntryDataModel>>> call(
    GetUserEntriesParams params,
  ) async {
    return await entriesRepo.getEntries(params.userId);
  }
}

class GetUserEntriesParams {
  final String userId;

  const GetUserEntriesParams({required this.userId});
}
