/// Model per emmagatzemar entrades xifrades a Firestore
class EntryModel {
  final String id;
  final String data;

  const EntryModel({required this.id, required this.data});

  factory EntryModel.fromJson(Map<String, dynamic> json) =>
      EntryModel(id: json['id'] ?? '', data: json['data'] ?? '');

  Map<String, dynamic> toJson() => {'id': id, 'data': data};
}

/// Model per les dades reals de l'entrada que seràn xifrades
class EntryDataModel {
  final String title;
  final String username;
  final String password;
  final DateTime createdAt;

  /// Només s'utilitza per poder passar l'ID a EditEntryView i modificar una entrada
  /// No es troba disponible el mètode toJson ni fromJson per a aquest atribut
  final String? id;

  EntryDataModel({
    required this.title,
    required this.username,
    required this.password,
    DateTime? createdAt,
    this.id,
  }) : createdAt = createdAt ?? DateTime.now();

  EntryDataModel copyWith({
    String? title,
    String? username,
    String? password,
    DateTime? createdAt,
    String? id,
  }) {
    return EntryDataModel(
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
    );
  }

  factory EntryDataModel.fromJson(Map<String, dynamic> json) {
    return EntryDataModel(
      title: json['title'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'username': username,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
