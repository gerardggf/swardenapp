import 'dart:typed_data';
import 'dart:math';
import 'dart:convert';

import 'package:pointycastle/export.dart'; // Per Argon2id robust
import 'package:encrypt/encrypt.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swardenapp/app/core/constants/crypto.dart';
import 'package:swardenapp/app/core/exceptions/crypto_exception.dart';
import 'package:swardenapp/app/core/exceptions/locked_exception.dart';
import 'package:swardenapp/app/domain/models/entry_model.dart';
import 'package:swardenapp/app/domain/models/session_model.dart';
import 'package:swardenapp/app/domain/models/user_model.dart';

final cryptoServiceProvider = Provider<CryptoService>((ref) => CryptoService());

class CryptoService {
  SessionModel? _vaultSession;

  /// Genera un salt únic per usuari (només al crear compte)
  String generateUserSalt() {
    final random = Random.secure();
    final bytes = Uint8List(32);
    for (int i = 0; i < bytes.length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return base64Encode(bytes);
  }

  /// Genera un nonce (IV) únic per cada operació AEAD
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

  /// REGISTRE: Crea una nova bòvada d'usuari
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
      throw CryptoException('Error creant bòvada d\'usuari: $e');
    }
  }

  /// INICI DE SESSIÓ: Desbloqueja la bòvada amb la contrasenya
  bool unlockVault(String password, UserModel userVault) {
    try {
      if (password.isEmpty) {
        throw CryptoException('La contrasenya és requerida');
      }

      // 1. Deriva KEK amb la contrasenya i salt de l'usuari
      final kek = _deriveKEK(password, userVault.salt);

      // 2. Desxifra la DEK
      final dekBase64 = _decryptAEAD(userVault.dekBox, kek);
      final dekBytes = base64Decode(dekBase64);
      final dek = Key(dekBytes);

      // 3. Crea sessió de bòvada amb la DEK en memòria
      _vaultSession = SessionModel.create(dek);

      return true;
    } catch (e) {
      _vaultSession = null;
      return false;
    }
  }

  /// Comprova si la bòvada està desblocada
  bool get isVaultUnlocked => _vaultSession != null && !_vaultSession!.isLocked;

  /// Bloqueja la bòvada (esborra la DEK de la memòria)
  void lockVault() {
    _vaultSession?.lock();
    _vaultSession = null;
  }

  /// CREAR ENTRADA: Xifra una entrada amb la DEK de la sessió
  EntryModel encryptEntry(String plaintext, [String? additionalData]) {
    if (!isVaultUnlocked) {
      throw const LockedException();
    }

    try {
      final nonce = generateNonce();
      final box = _encryptAEAD(
        plaintext,
        _vaultSession!.dek,
        nonce,
        additionalData,
      );

      return EntryModel(id: '', version: Crypto.version, data: box);
    } catch (e) {
      throw CryptoException('Error xifrant entrada: $e');
    }
  }

  /// LLEGIR ENTRADA: Desxifra una entrada amb la DEK de la sessió
  String decryptEntry(EntryModel entryBox, [String? additionalData]) {
    if (!isVaultUnlocked) {
      throw const LockedException();
    }

    try {
      return _decryptAEAD(entryBox.data, _vaultSession!.dek, additionalData);
    } catch (e) {
      throw CryptoException('Error desxifrant entrada: $e');
    }
  }

  /// Operació AEAD interna: xifra amb AES-GCM
  String _encryptAEAD(String plaintext, Key key, String nonce, [String? aad]) {
    try {
      final nonceBytes = base64Decode(nonce);
      final iv = IV(nonceBytes);

      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));

      final encrypted = aad != null
          ? encrypter.encrypt(
              plaintext,
              iv: iv,
              associatedData: utf8.encode(aad),
            )
          : encrypter.encrypt(plaintext, iv: iv);

      // Retorna: nonce||ciphertext||tag en Base64
      final combined = Uint8List.fromList([...nonceBytes, ...encrypted.bytes]);

      return base64Encode(combined);
    } catch (e) {
      throw CryptoException('Error en AEAD encrypt: $e');
    }
  }

  /// Operació AEAD interna: desxifra amb AES-GCM
  String _decryptAEAD(String encryptedData, Key key, [String? aad]) {
    try {
      final combined = base64Decode(encryptedData);

      // Separa: nonce||ciphertext||tag
      final nonceBytes = combined.sublist(0, Crypto.nonceLength);
      final encryptedBytes = combined.sublist(Crypto.nonceLength);

      final iv = IV(nonceBytes);
      final encrypted = Encrypted(encryptedBytes);

      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));

      return aad != null
          ? encrypter.decrypt(
              encrypted,
              iv: iv,
              associatedData: utf8.encode(aad),
            )
          : encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw CryptoException('Error en AEAD decrypt: $e');
    }
  }

  /// Neteja la sessió de memòria
  void dispose() {
    lockVault();
  }
}
