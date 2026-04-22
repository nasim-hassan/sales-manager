class TaskModel {
  final String id;
  final String title;
  final String description;
  final String? relatedTo; // lead or customer id
  final String? relatedType; // 'lead' or 'customer'
  final String status;
  final String priority;
  final String assignedTo;
  final String createdBy; // who created the task
  final DateTime dueDate;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    this.relatedTo,
    this.relatedType,
    required this.status,
    required this.priority,
    required this.assignedTo,
    required this.createdBy,
    required this.dueDate,
    this.completedAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      relatedTo: json['related_to'],
      relatedType: json['related_type'],
      status: json['status'] ?? 'Pending',
      priority: json['priority'] ?? 'Medium',
      assignedTo: json['assigned_to'] ?? '',
      createdBy: json['created_by'] ?? '',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'related_to': relatedTo,
      'related_type': relatedType,
      'status': status,
      'priority': priority,
      'assigned_to': assignedTo,
      'created_by': createdBy,
      'due_date': dueDate.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? relatedTo,
    String? relatedType,
    String? status,
    String? priority,
    String? assignedTo,
    String? createdBy,
    DateTime? dueDate,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      relatedTo: relatedTo ?? this.relatedTo,
      relatedType: relatedType ?? this.relatedType,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
