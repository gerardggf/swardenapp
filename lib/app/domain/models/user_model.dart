class UserModel {
  // Informació de Firebase Auth
  final String uid;
  final String email;

  final String salt;
  final String dekBox; // DEK xifrada amb KEK

  const UserModel({
    required this.uid,
    required this.email,
    required this.salt,
    required this.dekBox,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? salt,
    String? dekBox,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      salt: salt ?? this.salt,
      dekBox: dekBox ?? this.dekBox,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      salt: map['salt'] ?? '',
      dekBox: map['dekBox'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'uid': uid, 'email': email, 'salt': salt, 'dekBox': dekBox};
  }
}
