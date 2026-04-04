enum UserRole { ADMIN, PASSENGER, GUEST }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Determine the role string from JSON
    final roleString = json['role']?.toString().toUpperCase() ?? 'GUEST';

    return UserModel(
      // Handles 'userId' (from signup/login) or 'tempId' (from guest)
      id: (json['userId'] ?? json['tempId'] ?? '').toString(),
      name: json['name'] ?? 'Guest',
      email: json['email'] ?? '',
      // Safe role parsing
      role: UserRole.values.firstWhere(
            (e) => e.name == roleString,
        orElse: () => UserRole.GUEST,
      ),
    );
  }
}