class Crypto {
  const Crypto._();

  static const int argon2Iterations = 3; // Argon2id recomanat: 3-4 iteracions
  static const int argon2Memory = 64 * 1024; // 64MB memòria
  static const int argon2Parallelism = 1; // 1 fil per simplicitat
  static const int keyLength = 32; // 256 bits (KEK i DEK)
  static const int nonceLength = 12; // GCM recomanat: 12 bytes
  static const int version = 1; //Versió del protocol
}
