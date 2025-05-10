import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

/// A service to handle storage operations with platform-specific implementations
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static Database? _database;
  static const String dbName = 'proker_tracker.db';

  /// Get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database based on the platform
  Future<Database> _initDatabase() async {
    String path;
    
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      // Mobile platforms
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, dbName);
    } else {
      // Web or desktop platforms
      path = dbName;
    }
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  /// Create database tables
  Future<void> _createDatabase(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        role TEXT NOT NULL,
        profileImageUrl TEXT,
        department TEXT,
        position TEXT
      )
    ''');

    // Create prokers table
    await db.execute('''
      CREATE TABLE prokers(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        startDate INTEGER NOT NULL,
        endDate INTEGER NOT NULL,
        status TEXT NOT NULL,
        creatorId TEXT NOT NULL,
        department TEXT,
        taskIds TEXT,
        memberIds TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        FOREIGN KEY (creatorId) REFERENCES users (id)
      )
    ''');

    // Create tasks table
    await db.execute('''
      CREATE TABLE tasks(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        dueDate INTEGER NOT NULL,
        status TEXT NOT NULL,
        prokerId TEXT NOT NULL,
        assigneeId TEXT NOT NULL,
        creatorId TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        FOREIGN KEY (prokerId) REFERENCES prokers (id),
        FOREIGN KEY (assigneeId) REFERENCES users (id),
        FOREIGN KEY (creatorId) REFERENCES users (id)
      )
    ''');
  }

  /// Save a value to shared preferences
  Future<bool> saveValue(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(key, value);
  }

  /// Get a value from shared preferences
  Future<String?> getValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  /// Remove a value from shared preferences
  Future<bool> removeValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(key);
  }
}
