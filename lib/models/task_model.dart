import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String status; // 'not_started', 'in_progress', 'completed'
  final String prokerId;
  final String assigneeId;
  final String creatorId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    String? id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.prokerId,
    required this.assigneeId,
    required this.creatorId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  // Convert Task object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'status': status,
      'prokerId': prokerId,
      'assigneeId': assigneeId,
      'creatorId': creatorId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create a Task object from a Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate']),
      status: map['status'],
      prokerId: map['prokerId'],
      assigneeId: map['assigneeId'],
      creatorId: map['creatorId'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  // Create a copy of the Task with updated fields
  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    String? status,
    String? assigneeId,
  }) {
    return Task(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      prokerId: this.prokerId,
      assigneeId: assigneeId ?? this.assigneeId,
      creatorId: this.creatorId,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
