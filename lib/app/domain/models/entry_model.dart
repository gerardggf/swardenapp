/// Model per emmagatzemar entrades xifrades a Firestore
class EntryModel {
  final String id;
  final int version;
  final String data;

  const EntryModel({
    required this.id,
    required this.version,
    required this.data,
  });

  factory EntryModel.fromJson(Map<String, dynamic> json) => EntryModel(
    id: json['id'] ?? '',
    version: json['v'] ?? 0,
    data: json['box'] ?? '',
  );

  Map<String, dynamic> toJson() => {'id': id, 'v': version, 'box': data};
}
