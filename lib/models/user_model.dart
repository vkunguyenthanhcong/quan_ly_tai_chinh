class UserModel {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String email;

  UserModel({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    required this.email,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      fullName: map['full_name'],
      avatarUrl: map['avatar_url'],
      email: map['email'],
    );
  }
}
