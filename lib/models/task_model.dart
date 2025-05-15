import 'dart:convert';

class Task {
  final int? id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdDate;
  final DateTime? dueDate;
  final int priority;
  final String category;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    DateTime? createdDate,
    this.dueDate,
    this.priority = 2,
    this.category = 'Personal',
  }) : createdDate = createdDate ?? DateTime.now();

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdDate,
    DateTime? dueDate,
    int? priority,
    String? category,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdDate: createdDate ?? this.createdDate,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'createdDate': createdDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'category': category,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
      createdDate: DateTime.parse(map['createdDate']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      priority: map['priority'],
      category: map['category'] ?? 'Personal',
    );
  }

  String toJson() => json.encode(toMap());

  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Task(id: $id, title: $title, description: $description, isCompleted: $isCompleted, createdDate: $createdDate, dueDate: $dueDate, priority: $priority, category: $category)';
  }
}