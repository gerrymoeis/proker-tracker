import 'package:sqflite/sqflite.dart';

import '../models/user_model.dart';
import '../models/proker_model.dart';
import '../models/task_model.dart';
import 'storage_service.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();
  
  final StorageService _storageService = StorageService();

  Future<Database> get database async {
    return await _storageService.database;
  }

  // User CRUD Operations
  Future<int> insertUser(User user) async {
    Database db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUser(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<int> updateUser(User user) async {
    Database db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(String id) async {
    Database db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Proker CRUD Operations
  Future<int> insertProker(Proker proker) async {
    Database db = await database;
    return await db.insert('prokers', proker.toMap());
  }

  Future<Proker?> getProker(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'prokers',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Proker.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Proker>> getAllProkers() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('prokers');
    return List.generate(maps.length, (i) => Proker.fromMap(maps[i]));
  }

  Future<List<Proker>> getProkersByCreator(String creatorId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'prokers',
      where: 'creatorId = ?',
      whereArgs: [creatorId],
    );
    return List.generate(maps.length, (i) => Proker.fromMap(maps[i]));
  }

  Future<int> updateProker(Proker proker) async {
    Database db = await database;
    return await db.update(
      'prokers',
      proker.toMap(),
      where: 'id = ?',
      whereArgs: [proker.id],
    );
  }

  Future<int> deleteProker(String id) async {
    Database db = await database;
    return await db.delete(
      'prokers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Task CRUD Operations
  Future<int> insertTask(Task task) async {
    Database db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<Task?> getTask(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Task>> getAllTasks() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<List<Task>> getTasksByProker(String prokerId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'prokerId = ?',
      whereArgs: [prokerId],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<List<Task>> getTasksByAssignee(String assigneeId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'assigneeId = ?',
      whereArgs: [assigneeId],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<int> updateTask(Task task) async {
    Database db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(String id) async {
    Database db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
