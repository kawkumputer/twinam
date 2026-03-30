import 'package:uuid/uuid.dart';

enum TaskStatus {
  todo,
  inProgress,
  done,
}

enum TaskPriority {
  low,
  medium,
  high,
}

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? linkedCounterId;

  Task({
    String? id,
    required this.title,
    required this.description,
    required this.deadline,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    DateTime? createdAt,
    this.completedAt,
    this.linkedCounterId,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  bool get isOverdue => deadline.isBefore(DateTime.now()) && status != TaskStatus.done;
  bool get isDueToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDay = DateTime(deadline.year, deadline.month, deadline.day);
    return deadlineDay.isAtSameMomentAs(today) && status != TaskStatus.done;
  }

  bool get isDueSoon {
    final now = DateTime.now();
    final diff = deadline.difference(now);
    return diff.inHours <= 24 && diff.inHours > 0 && status != TaskStatus.done;
  }

  Duration get timeUntilDeadline => deadline.difference(DateTime.now());
  Duration? get timeToComplete => completedAt?.difference(createdAt);

  Task copyWith({
    String? title,
    String? description,
    DateTime? deadline,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? completedAt,
    String? linkedCounterId,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      linkedCounterId: linkedCounterId ?? this.linkedCounterId,
    );
  }

  Task markAsDone() {
    return copyWith(
      status: TaskStatus.done,
      completedAt: DateTime.now(),
    );
  }

  Task markAsInProgress() {
    return copyWith(status: TaskStatus.inProgress);
  }

  Task markAsTodo() {
    return copyWith(status: TaskStatus.todo, completedAt: null);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'status': status.index,
      'priority': priority.index,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'linkedCounterId': linkedCounterId,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      status: TaskStatus.values[json['status'] as int],
      priority: TaskPriority.values[json['priority'] as int],
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      linkedCounterId: json['linkedCounterId'] as String?,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: $status, deadline: $deadline)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
