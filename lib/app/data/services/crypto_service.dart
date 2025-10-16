import 'dart:typed_data';
import 'dart:math';
import 'dart:convert';

import 'package:pointycastle/export.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swardenapp/app/core/constants/crypto.dart';
import 'package:swardenapp/app/core/exceptions/crypto_exception.dart';
import 'package:swardenapp/app/core/exceptions/locked_exception.dart';
import 'package:swardenapp/app/domain/models/entry_model.dart';
import 'package:swardenapp/app/presentation/controllers/vault_session.dart';

final cryptoServiceProvider = Provider<CryptoService>((ref) => CryptoService());

class CryptoService {
  VaultSession? _vaultSession;

  /// Genera un ID únic de document al crear una nova entrada
  String generateId() {
    final random = Random.secure();
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
      20,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Genera un salt únic per usuari (només al crear la bóveda)
  String generateUserSalt() {
    final random = Random.secure();
    final bytes = Uint8List(32);
    for (int i = 0; i < bytes.length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return base64Encode(bytes);
  }

  /// Genera un nonce únic per cada entrada
  String generateNonce() {
    final random = Random.secure();
    final bytes = Uint8List(Crypto.nonceLength);
    for (int i = 0; i < bytes.length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return base64Encode(bytes);
  }

  /// Genera una Data Encryption Key (DEK) aleatòria
  Key _generateDEK() {
    final random = Random.secure();
    final bytes = Uint8List(Crypto.keyLength);
    for (int i = 0; i < bytes.length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return Key(bytes);
  }

  /// Deriva la Key Encryption Key (KEK) usant Argon2id
  Key _deriveKEK(String password, String salt) {
    try {
      final passwordBytes = utf8.encode(password);
      final saltBytes = base64Decode(salt);

      final argon2 = Argon2BytesGenerator()
        ..init(
          Argon2Parameters(
            Argon2Parameters.ARGON2_id,
            saltBytes,
            iterations: Crypto.argon2Iterations,
            memory: Crypto.argon2Memory,
            lanes: Crypto.argon2Parallelism,
            desiredKeyLength: Crypto.keyLength,
          ),
        );

      final keyBytes = argon2.process(Uint8List.fromList(passwordBytes));
      return Key(keyBytes);
    } catch (e) {
      throw CryptoException('Error derivant KEK amb Argon2id: $e');
    }
  }

  /// Crea una nova bóveda d'usuari. Retorna el salt i el dekBox
  (String, String) createUserVault(String password) {
    try {
      if (password.isEmpty) {
        throw CryptoException('La contrasenya és requerida');
      }

      // 1. Genera salt únic per l'usuari
      final salt = generateUserSalt();

      // 2. Genera DEK aleatòria
      final dek = _generateDEK();

      // 3. Deriva KEK amb Argon2id
      final kek = _deriveKEK(password, salt);

      // 4. Xifra la DEK amb la KEK (AEAD)
      final nonce = generateNonce();
      final dekBox = _encryptAEAD(base64Encode(dek.bytes), kek, nonce);

      return (salt, dekBox);
    } catch (e) {
      throw CryptoException('Error creant bóveda d\'usuari: $e');
    }
  }

  /// Desbloqueja les entrades amb la contrasenya de la bóveda
  bool unlock(String password, String userSalt, String dekBox) {
    try {
      if (password.isEmpty) {
        throw CryptoException('La contrasenya és requerida');
      }

      // 1. Deriva KEK amb la contrasenya i salt de l'usuari
      final kek = _deriveKEK(password, userSalt);

      // 2. Desxifra la DEK
      final dekBase64 = _decryptAEAD(dekBox, kek);
      final dekBytes = base64Decode(dekBase64);
      final dek = Key(dekBytes);

      // 3. Crea sessió de bóveda amb la DEK en memòria
      _vaultSession = VaultSession.create(dek);

      return true;
    } catch (e) {
      _vaultSession = null;
      return false;
    }
  }

  /// Comprova si la bóveda està desblocada
  bool get isVaultUnlocked => _vaultSession != null && !_vaultSession!.isLocked;

  /// Bloqueja la bóveda (esborra la DEK de la memòria)
  void lock() {
    _vaultSession?.lock();
    _vaultSession = null;
  }

  /// Xifra EntryDataModel i retorna EntryModel
  EntryModel encryptEntryData(EntryDataModel entryData, String entryId) {
    if (!isVaultUnlocked) {
      throw LockedException();
    }

    try {
      // Converteix EntryDataModel a JSON string
      final plaintext = _entryDataToJson(entryData.toJson());

      // Xifra el contingut
      final nonce = generateNonce();
      final box = _encryptAEAD(plaintext, _vaultSession!.dek, nonce);

      return EntryModel(id: entryId, data: box);
    } catch (e) {
      throw CryptoException('Error xifrant EntryDataModel: $e');
    }
  }

  /// Desxifra EntryModel i retorna  EntryDataModel
  EntryDataModel decryptEntryData(EntryModel entryModel) {
    if (!isVaultUnlocked) {
      throw LockedException();
    }

    try {
      // Desxifra el contingut
      final plaintext = _decryptAEAD(entryModel.data, _vaultSession!.dek);

      // Converteix de JSON string a Map
      final dataMap = _entryDataFromJson(plaintext);

      // Retorna EntryDataModel
      return EntryDataModel.fromJson(dataMap).copyWith(id: entryModel.id);
    } catch (e) {
      throw CryptoException('Error desxifrant EntryModel: $e');
    }
  }

  /// Converteix JSON a string
  String _entryDataToJson(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.write('title=${data['title'] ?? ''}\n');
    buffer.write('username=${data['username'] ?? ''}\n');
    buffer.write('password=${data['password'] ?? ''}\n');
    buffer.write(
      'createdAt=${data['createdAt'] ?? DateTime.now().toIso8601String()}',
    );
    return buffer.toString();
  }

  /// Converteix string a JSON
  Map<String, dynamic> _entryDataFromJson(String plaintext) {
    final lines = plaintext.split('\n');
    final data = <String, dynamic>{};

    for (final line in lines) {
      final parts = line.split('=');
      if (parts.length >= 2) {
        final key = parts[0];
        final value = parts.sublist(1).join('='); // Per si el valor conté '='
        data[key] = value;
      }
    }

    return data;
  }

  /// Operació AEAD interna: xifra amb AES-GCM
  String _encryptAEAD(String plaintext, Key key, String nonce) {
    try {
      final nonceBytes = base64Decode(nonce);
      final iv = IV(nonceBytes);

      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));

      final encrypted = encrypter.encrypt(plaintext, iv: iv);

      // Retorna: nonce||ciphertext||tag en Base64
      final combined = Uint8List.fromList([...nonceBytes, ...encrypted.bytes]);

      return base64Encode(combined);
    } catch (e) {
      throw CryptoException('Error en AEAD encrypt: $e');
    }
  }

  /// Operació AEAD interna: desxifra amb AES-GCM
  String _decryptAEAD(String encryptedData, Key key) {
    try {
      final combined = base64Decode(encryptedData);

      // Separa: nonce||ciphertext||tag
      final nonceBytes = combined.sublist(0, Crypto.nonceLength);
      final encryptedBytes = combined.sublist(Crypto.nonceLength);

      final iv = IV(nonceBytes);
      final encrypted = Encrypted(encryptedBytes);

      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));

      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw CryptoException('Error en AEAD decrypt: $e');
    }
  }

  /// Neteja la sessió de memòria
  void dispose() {
    lock();
  }
}
