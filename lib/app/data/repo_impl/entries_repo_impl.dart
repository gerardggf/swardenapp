import 'package:flutter/foundation.dart';
import 'package:swardenapp/app/core/typedefs.dart';
import 'package:swardenapp/app/data/services/crypto_service.dart';
import 'package:swardenapp/app/data/services/firestore_entry_service.dart';
import 'package:swardenapp/app/domain/either/either.dart';
import 'package:swardenapp/app/domain/models/entry_model.dart';
import 'package:swardenapp/app/domain/repos/entries_repo.dart';
import 'package:swardenapp/app/domain/swarden_exceptions/swarden_exceptions.dart';

class EntriesRepoImpl implements EntriesRepo {
  final FirestoreEntryService firestoreEntryService;
  final CryptoService cryptoService;

  EntriesRepoImpl({
    required this.cryptoService,
    required this.firestoreEntryService,
  });

  @override
  Future<bool> addEntry(String userId, EntryDataModel entry) async {
    try {
      final docId = cryptoService.generateId();
      final encryptedData = cryptoService.encryptEntryData(entry, docId);

      return await firestoreEntryService.createEntry(
        userId: userId,
        entry: encryptedData,
      );
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return false;
    }
  }

  @override
  Future<bool> deleteEntry(String userId, String entryId) async {
    try {
      return await firestoreEntryService.deleteEntry(userId, entryId);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return false;
    }
  }

  @override
  AsyncSwardenResult<List<EntryDataModel>> getEntries(String userId) async {
    try {
      final encryptedResults = await firestoreEntryService.getUserEntries(
        userId,
      );
      final results = encryptedResults.map((e) {
        return cryptoService.decryptEntryData(e);
      }).toList();
      return Either.right(results);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return Either.left(SwardenException.undefined(message: e.toString()));
    }
  }

  @override
  Future<bool> updateEntry(
    String userId,
    String entryId,
    EntryDataModel entry,
  ) async {
    try {
      final encryptedData = cryptoService.encryptEntryData(entry, entryId);

      return await firestoreEntryService.updateEntry(
        userId: userId,
        entry: encryptedData,
      );
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return false;
    }
  }
}
