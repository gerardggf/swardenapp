# 🔐 Model Zero-Knowledge per Swardenapp

## Descripció

Implementació d'un sistema de gestió de contrasenyes amb **model zero-knowledge** que garanteix que el servidor mai veu les dades en clar.

## 🏗️ Arquitectura

### Dues Sessions Separades

1. **Auth Session (Firebase)**: Només identitat i permisos (uid)
2. **Vault Session**: Data Encryption Key (DEK) en memòria RAM

### Components Principals

- **KEK (Key Encryption Key)**: Derivada de la contrasenya amb Argon2id
- **DEK (Data Encryption Key)**: Clau aleatòria per xifrar les dades
- **AEAD**: Xifrat autenticat amb AES-GCM
- **Salt**: Únic per usuari, evita atacs rainbow table

## 🔄 Flux Complet

### 1. Registre (Un cop)

```
Usuari posa email + contrasenya
    ↓
Firebase Auth crea compte → uid
    ↓
Dispositiu genera salt + DEK aleatòria
    ↓
KEK = Argon2id(contrasenya, salt)
    ↓
dekBox = AEAD(KEK, DEK) → Base64(nonce||ct||tag)
    ↓
Es desa a Firestore: users/{uid} = { v, salt, dekBox }
```

### 2. Login/Desbloqueig

```
Login Firebase (email+pwd) → obté uid
    ↓
Llegeix { salt, dekBox } de Firestore
    ↓
KEK = Argon2id(contrasenya, salt)
    ↓
DEK = AEAD⁻¹(KEK, dekBox) → DEK queda en memòria
```

### 3. Crear Entrada

```
box = AEAD(DEK, plaintext, nonce)
    ↓
Es desa a Firestore: entries/{id} = { v, box }
```

### 4. Llegir Entrada

```
Baixa { v, box } de Firestore
    ↓
plaintext = AEAD⁻¹(DEK, box)
```

## 🔒 Per què és Zero-Knowledge

1. **La contrasenya** només s'usa localment per derivar la KEK
2. **El servidor** només emmagatzema: `salt`, `dekBox` i `box` (tot xifrat)
3. **Integritat garantida** pel tag d'autenticació AEAD
4. **La DEK mai surt** del dispositiu en clar

## 🛡️ Seguretat

### Algorithmes Utilitzats

- **Argon2id**: Derivació robusta de claus (resistent a GPU/ASIC)
- **AES-256-GCM**: Xifrat autenticat (confidencialitat + integritat)
- **Random.secure()**: Generació criptogràficament segura

### Paràmetres de Seguretat

```dart
Argon2id:
- Iteracions: 3
- Memòria: 64MB  
- Paral·lelisme: 1
- Salt: 32 bytes
- Clau: 32 bytes (256 bits)

AES-GCM:
- Clau: 32 bytes (256 bits)
- Nonce: 12 bytes
- Tag: 16 bytes
```

## 💻 Ús del CryptoService

### Registre Nou Usuari

```dart
final crypto = CryptoService();

// Crear bòvada amb contrasenya
final vault = crypto.createUserVault("contrasenya123");

// Desar a Firestore
await firestore.collection('users').doc(uid).set(vault.toJson());
```

### Login i Desbloqueig

```dart
// Carregar bòvada de l'usuari
final doc = await firestore.collection('users').doc(uid).get();
final vault = UserVault.fromJson(doc.data()!);

// Desbloquejar amb contrasenya
final success = crypto.unlockVault("contrasenya123", vault);
if (success) {
  // Bòvada desbloquejada - DEK disponible en memòria
}
```

### Gestió d'Entrades

```dart
// Crear entrada xifrada
final entry = crypto.encryptEntry("password_secret");
await firestore.collection('entries').doc(entryId).set(entry.toJson());

// Llegir entrada
final doc = await firestore.collection('entries').doc(entryId).get();
final entry = EntryBox.fromJson(doc.data()!);
final plaintext = crypto.decryptEntry(entry);
```

### Bloqueig de Seguretat

```dart
// Bloquejar bòvada (esborra DEK de memòria)
crypto.lockVault();

// Comprovar estat
if (crypto.isVaultUnlocked) {
  // Bòvada disponible
} else {
  // Cal desbloquejar
}
```

## 🚨 Gestió d'Errors

```dart
try {
  final entry = crypto.encryptEntry("data");
} on VaultLockedException {
  // La bòvada està bloquejada
  print("Cal desbloquejar la bòvada primer");
} on CryptoException catch (e) {
  // Error de xifrat/desxifrat
  print("Error criptogràfic: ${e.message}");
}
```

## 📦 Models de Dades

### UserVault
```dart
class UserVault {
  final int version;    // Versió del format
  final String salt;    // Salt únic per usuari
  final String dekBox;  // DEK xifrada amb KEK
}
```

### EntryBox
```dart
class EntryBox {
  final int version;    // Versió del format  
  final String box;     // Dades xifrades amb DEK
}
```

### VaultSession
```dart
class VaultSession {
  // DEK en memòria (només accessible si no està bloquejada)
  // Gestió d'estat de bloqueig/desbloqueig
}
```

## ⚡ Característiques Avançades

- **Sessions temporitzades**: Pot afegir auto-bloqueig per temps
- **Suport AAD**: Associated Additional Data per més context
- **Gestió d'errors robusta**: Excepcions específiques per cada cas
- **Neteja de memòria**: Dispose automàtic de dades sensibles

## 🔮 Futures Millores

1. **Suport biometria**: Desar DEK al Keychain/Keystore
2. **Backup segur**: Exportació xifrada de la bòvada
3. **Rotació de claus**: Canvi periòdic de la DEK
4. **Auditoria**: Log de tentatives d'accés fallides

---

**Nota**: Aquest model garanteix que fins i tot si el servidor és compromès, les dades romanen xifrades i inaccessibles sense la contrasenya de l'usuari.