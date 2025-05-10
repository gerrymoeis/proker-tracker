import 'package:uuid/uuid.dart';

import '../models/user_model.dart';
import 'database_service.dart';
import 'storage_service.dart';

class AuthService {
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();
  static const String _userIdKey = 'userId';

  // Register a new user
  Future<User?> register(String name, String email, String password, String department, String position) async {
    try {
      // Check if user with email already exists
      User? existingUser = await _databaseService.getUserByEmail(email);
      if (existingUser != null) {
        return null; // User already exists
      }

      // Create a new user
      final String userId = const Uuid().v4();
      final User newUser = User(
        id: userId,
        name: name,
        email: email,
        role: 'member', // Default role
        department: department,
        position: position,
      );

      // Insert user into database
      await _databaseService.insertUser(newUser);

      // Save user credentials (in a real app, you would hash the password)
      await _storageService.saveValue('${email}_password', password);

      return newUser;
    } catch (e) {
      print('Error during registration: $e');
      return null;
    }
  }

  // Login user
  Future<User?> login(String email, String password) async {
    try {
      // Get user by email
      User? user = await _databaseService.getUserByEmail(email);
      if (user == null) {
        return null; // User not found
      }

      // Check password (in a real app, you would compare hashed passwords)
      final savedPassword = await _storageService.getValue('${email}_password');
      if (savedPassword != password) {
        return null; // Incorrect password
      }

      // Save user session
      await _storageService.saveValue(_userIdKey, user.id);

      return user;
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  // Check if user is logged in
  Future<User?> getCurrentUser() async {
    try {
      final userId = await _storageService.getValue(_userIdKey);
      if (userId == null) {
        return null; // No user logged in
      }

      return await _databaseService.getUser(userId);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Logout user
  Future<bool> logout() async {
    try {
      await _storageService.removeValue(_userIdKey);
      return true;
    } catch (e) {
      print('Error during logout: $e');
      return false;
    }
  }
  
  // Update current user
  Future<bool> updateCurrentUser(User user) async {
    try {
      // Update user in database
      await _databaseService.updateUser(user);
      return true;
    } catch (e) {
      print('Error updating current user: $e');
      return false;
    }
  }
}
