import 'package:uuid/uuid.dart';

class Proker {
  final String id;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'not_started', 'in_progress', 'completed'
  final String creatorId;
  final String department;
  final List<String> taskIds;
  final List<String> memberIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Proker({
    String? id,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.creatorId,
    required this.department,
    List<String>? taskIds,
    List<String>? memberIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    id = id ?? const Uuid().v4(),
    taskIds = taskIds ?? [],
    memberIds = memberIds ?? [],
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  // Convert Proker object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'status': status,
      'creatorId': creatorId,
      'department': department,
      'taskIds': taskIds.join(','),
      'memberIds': memberIds.join(','),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create a Proker object from a Map
  factory Proker.fromMap(Map<String, dynamic> map) {
    return Proker(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate']),
      status: map['status'],
      creatorId: map['creatorId'],
      department: map['department'],
      taskIds: map['taskIds']?.split(',') ?? [],
      memberIds: map['memberIds']?.split(',') ?? [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  // Create a copy of the Proker with updated fields
  Proker copyWith({
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? department,
    List<String>? taskIds,
    List<String>? memberIds,
  }) {
    return Proker(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      creatorId: this.creatorId,
      department: department ?? this.department,
      taskIds: taskIds ?? this.taskIds,
      memberIds: memberIds ?? this.memberIds,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
