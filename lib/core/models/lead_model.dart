class LeadModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String company;
  final String stage;
  final String assignedTo;
  final String createdBy; // Who created the lead (user id)
  final double value;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  LeadModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.company,
    required this.stage,
    required this.assignedTo,
    required this.createdBy,
    required this.value,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      company: json['company'] ?? '',
      stage: json['stage'] ?? 'New',
      assignedTo: json['assigned_to'] ?? '',
      createdBy: json['created_by'] ?? 'admin',
      value: (json['value'] ?? 0.0).toDouble(),
      notes: json['notes'],
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
      'name': name,
      'email': email,
      'phone': phone,
      'company': company,
      'stage': stage,
      'assigned_to': assignedTo,
      'created_by': createdBy,
      'value': value,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  LeadModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? company,
    String? stage,
    String? assignedTo,
    String? createdBy,
    double? value,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LeadModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      stage: stage ?? this.stage,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      value: value ?? this.value,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
