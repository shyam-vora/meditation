import 'dart:convert';

class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final bool isAdmin;
  final String? profilePicture;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.isAdmin = false,
    this.profilePicture,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? password,
    int? id,
    bool? isAdmin,
    String? profilePicture,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      isAdmin: isAdmin ?? this.isAdmin,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': name,
      'email': email,
      'password': password,
      'is_admin': isAdmin ? 1 : 0,
      'profile_picture': profilePicture,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int,
      name: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      isAdmin: map['is_admin'] == 1,
      profilePicture: map['profile_picture'] as String?,
    );
  }

  @override
  String toString() =>
      'UserModel(name: $name, email: $email, password: $password, isAdmin: $isAdmin, profilePicture: $profilePicture)';

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.email == email &&
        other.password == password &&
        other.isAdmin == isAdmin &&
        other.profilePicture == profilePicture;
  }

  @override
  int get hashCode =>
      name.hashCode ^
      email.hashCode ^
      password.hashCode ^
      isAdmin.hashCode ^
      profilePicture.hashCode;

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
