class ProposalModel {
  final String id;
  final String title;
  final String description;
  final String leadId;
  final double amount;
  final String status; // draft, sent, accepted, rejected
  final DateTime validUntil;
  final String createdBy; // who created the proposal
  final String assignedTo; // who it's assigned to
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProposalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.leadId,
    required this.amount,
    required this.status,
    required this.validUntil,
    required this.createdBy,
    required this.assignedTo,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProposalModel.fromJson(Map<String, dynamic> json) {
    return ProposalModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      leadId: json['lead_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'draft',
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'])
          : DateTime.now().add(const Duration(days: 30)),
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
      'lead_id': leadId,
      'amount': amount,
      'status': status,
      'valid_until': validUntil.toIso8601String(),
      'created_by': createdBy,
      'assigned_to': assignedTo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ProposalModel copyWith({
    String? id,
    String? title,
    String? description,
    String? leadId,
    double? amount,
    String? status,
    DateTime? validUntil,
    String? createdBy,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProposalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      leadId: leadId ?? this.leadId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      validUntil: validUntil ?? this.validUntil,
      createdBy: createdBy ?? this.createdBy,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
