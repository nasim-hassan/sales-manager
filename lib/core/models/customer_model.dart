class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? company;
  final String createdBy; // who created this customer
  final String? leadId; // which lead was converted to this customer (renamed from convertedFromLeadId)
  final DateTime createdAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.company,
    required this.createdBy,
    this.leadId,
    required this.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      company: json['company'],
      createdBy: json['created_by'] ?? '',
      leadId: json['lead_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'company': company,
      'created_by': createdBy,
      'lead_id': leadId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? company,
    String? createdBy,
    String? leadId,
    DateTime? createdAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      createdBy: createdBy ?? this.createdBy,
      leadId: leadId ?? this.leadId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
