/// Model per emmagatzemar entrades xifrades a Firestore
class EntryModel {
  final int version;
  final String box; // Base64(nonce||ciphertext||tag)

  const EntryModel({required this.version, required this.box});

  Map<String, dynamic> toJson() => {'v': version, 'box': box};

  factory EntryModel.fromJson(Map<String, dynamic> json) =>
      EntryModel(version: json['v'] as int, box: json['box'] as String);
}
