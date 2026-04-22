class MeetingModel {
  final String id;
  final String title;
  final String? description;
  final String? relatedId; // lead or customer id (renamed from relatedTo)
  final String? relatedType; // 'lead' or 'customer'
  final DateTime scheduledAt;
  final int duration; // in minutes
  final String status; // scheduled, completed, cancelled
  final String createdBy; // who created the meeting
  final String assignedTo; // who it's assigned to
  final DateTime createdAt;
  final DateTime? updatedAt;

  MeetingModel({
    required this.id,
    required this.title,
    this.description,
    this.relatedId,
    this.relatedType,
    required this.scheduledAt,
    required this.duration,
    required this.status,
    required this.createdBy,
    required this.assignedTo,
    required this.createdAt,
    this.updatedAt,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      relatedId: json['related_id'],
      relatedType: json['related_type'],
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'])
          : DateTime.now(),
      duration: json['duration'] ?? 30,
      status: json['status'] ?? 'scheduled',
      createdBy: json['created_by'] ?? '',
      assignedTo: json['assigned_to'] ?? '',
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
      'related_id': relatedId,
      'related_type': relatedType,
      'scheduled_at': scheduledAt.toIso8601String(),
      'duration': duration,
      'status': status,
      'created_by': createdBy,
      'assigned_to': assignedTo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  MeetingModel copyWith({
    String? id,
    String? title,
    String? description,
    String? relatedId,
    String? relatedType,
    DateTime? scheduledAt,
    int? duration,
    String? status,
    String? createdBy,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MeetingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
