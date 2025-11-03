import 'package:flutter_test/flutter_test.dart';
import 'package:swardenapp/app/data/services/crypto_service.dart';
import 'package:swardenapp/app/domain/models/entry_model.dart';

void main() {
  group('CryptoService Tests', () {
    late CryptoService cryptoService;

    setUp(() {
      cryptoService = CryptoService();
    });

    // Assegura que la bóveda està bloquejada abans de cada test
    tearDown(() {
      cryptoService.lock();
    });

    test('Crear i desbloquejar bóveda', () {
      const password = 'testPassword123';

      final (salt, dekBox) = cryptoService.createUserVault(password);

      expect(salt, isNotEmpty);
      expect(dekBox, isNotEmpty);

      final unlockResult = cryptoService.unlock(password, salt, dekBox);

      expect(unlockResult, isTrue);
      expect(cryptoService.isVaultUnlocked, isTrue);
    });

    test('Fallar amb contrasenya incorrecta', () {
      const correctPassword = 'testPassword123';
      const wrongPassword = 'wrongPassword456';

      final (salt, dekBox) = cryptoService.createUserVault(correctPassword);
      final unlockResult = cryptoService.unlock(wrongPassword, salt, dekBox);

      expect(unlockResult, isFalse);
      expect(cryptoService.isVaultUnlocked, isFalse);
    });

    test('Encriptar i desencriptar entrada', () {
      const password = 'testPassword123';
      final (salt, dekBox) = cryptoService.createUserVault(password);
      cryptoService.unlock(password, salt, dekBox);

      const entryId = 'testEntry123';
      final originalEntry = EntryDataModel(
        title: 'Test Title',
        username: 'testuser',
        password: 'testpass',
        createdAt: DateTime(2024, 1, 1),
      );

      final encryptedEntry = cryptoService.encryptEntryData(
        originalEntry,
        entryId,
      );
      final decryptedEntry = cryptoService.decryptEntryData(encryptedEntry);

      expect(decryptedEntry.id, equals(entryId));
      expect(decryptedEntry.title, equals(originalEntry.title));
      expect(decryptedEntry.username, equals(originalEntry.username));
      expect(decryptedEntry.password, equals(originalEntry.password));
    });

    test('Fallar encriptar amb bóveda sense desbloquejar', () {
      final entry = EntryDataModel(
        title: 'Test Title',
        username: 'testuser',
        password: 'testpass',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(
        () => cryptoService.encryptEntryData(entry, 'testId'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
