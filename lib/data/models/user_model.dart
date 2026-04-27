/**
 * 🏷️ USER ROLES:
 * Defines what type of user is logged in.
 * - ADMIN: Can manage lines/buses.
 * - PASSENGER: A regular user with a saved account.
 * - GUEST: Someone using the app without signing up.
 */
enum UserRole { ADMIN, PASSENGER, GUEST }

/**
 * 👤 THE USER MODEL:
 * This class stores the profile data for the current user.
 */
class UserModel {
  final String id;    // The unique ID (from DB or temporary)
  final String name;  // Display name
  final String email; // User's email address
  final UserRole role; // Their permission level

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role
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
      // Your backend sends 'userId' for members, but 'tempId' for guests.
      // This line checks both so the app doesn't crash.
      id: (json['userId'] ?? json['tempId'] ?? '').toString(),

      name: json['name'] ?? 'Guest',
      email: json['email'] ?? '',

      // 🛂 Step 3: Safe Role Conversion
      // It looks through the UserRole enum to find a match.
      // If it doesn't find a match, it defaults to GUEST for safety.
      role: UserRole.values.firstWhere(
            (e) => e.name == roleString,
        orElse: () => UserRole.GUEST,
      ),
    );
  }
}