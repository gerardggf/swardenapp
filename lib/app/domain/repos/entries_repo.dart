import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swardenapp/app/core/typedefs.dart';
import 'package:swardenapp/app/data/repo_impl/entries_repo_impl.dart';
import 'package:swardenapp/app/data/services/crypto_service.dart';
import 'package:swardenapp/app/data/services/firestore_entry_service.dart';
import 'package:swardenapp/app/domain/models/entry_model.dart';

final entriesRepoProvider = Provider<EntriesRepo>(
  (ref) => EntriesRepoImpl(
    cryptoService: ref.watch(cryptoServiceProvider),
    firestoreEntryService: ref.watch(firestoreEntryServiceProvider),
  ),
);

abstract class EntriesRepo {
  /// Obté totes les entrades de l'usuari actual
  AsyncSwardenResult<List<EntryDataModel>> getEntries(String userId);

  /// Afegeix una nova entrada
  Future<bool> addEntry(String userId, EntryDataModel entry);

  /// Actualitza una entrada existent
  Future<bool> updateEntry(String userId, String entryId, EntryDataModel entry);

  /// Elimina una entrada per ID
  Future<bool> deleteEntry(String userId, String entryId);
}
