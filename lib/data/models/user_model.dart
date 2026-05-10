/**
 * 🏷️ USER ROLES:
 * Defines what type of user is logged in.
 * - ADMIN: Can manage lines/buses.
 * - PASSENGER: A regular user with a saved account.
 * - GUEST: Someone using the app without signing up.
 */
enum UserRole { PASSENGER, GUEST }

/**
 * 👤 THE USER MODEL:
 * This class stores the profile data for the current user.
 */
class UserModel {
  final String id;    // The unique ID (from DB or temporary)
  final String name;  // Display name
  final String email; // User's email address
  final UserRole role; // Their permission level
  final String? token; // 🚀 ADDED: The JWT token for secure sessions

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token, // 🚀 ADDED
  });

  /**
   * 🏗️ THE FACTORY (Smart Parsing):
   * This handles the differences between a real login and a guest login.
   */
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // 🔍 Step 1: Identify the role
    // Gets the role string (like "PASSENGER") and makes it Uppercase.
    final roleString = json['role']?.toString().toUpperCase() ?? 'GUEST';

    return UserModel(
      // 🆔 Step 2: Extract the ID
      id: (json['id'] ?? json['userId'] ?? json['tempId'] ?? '').toString(),

      name: json['name'] ?? 'Guest',
      email: json['email'] ?? '',

      // 🚀 Step 3: Extract the JWT Token
      token: json['token'],

      // 🛂 Step 4: Safe Role Conversion
      role: UserRole.values.firstWhere(
            (e) => e.name == roleString,
        orElse: () => UserRole.GUEST,
      ),
    );
  }
}