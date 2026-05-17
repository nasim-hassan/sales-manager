import 'dart:async';
import 'package:sales_manager/core/models/user_model.dart';

// Top-level global to access SupabaseService mirroring the real Supabase client
final _supabase = SupabaseService();

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  // In-memory table structure
  final Map<String, List<Map<String, dynamic>>> _db = {};
  
  // Mock auth service
  late final MockAuth auth;

  SupabaseService._internal() {
    auth = MockAuth(this);
    _initializeData();
  }

  factory SupabaseService() {
    return _instance;
  }

  Future<void> initialize() async {
    print('✅ Mock SupabaseService initialized (no network connection needed)');
  }

  // Mimic the from() method from real Supabase client
  MockQueryBuilder from(String table) {
    return MockQueryBuilder(this, table);
  }

  // Mimic the channel() method from real Supabase client
  RealtimeChannel channel(String channelId) {
    return RealtimeChannel();
  }

  // Legacy helper methods for backward compatibility
  Future<UserModel?> getUserById(String userId) async {
    final users = _db['users'] ?? [];
    final userJson = users.firstWhere((u) => u['id'] == userId, orElse: () => {});
    if (userJson.isEmpty) return null;
    return UserModel.fromJson(userJson);
  }

  Future<List<UserModel>> getAllUsers() async {
    final users = _db['users'] ?? [];
    return users.map((u) => UserModel.fromJson(u)).toList();
  }

  Future<bool> insertUser(UserModel user) async {
    final users = _db['users'] ?? [];
    users.add(user.toJson());
    _db['users'] = users;
    return true;
  }

  Future<bool> updateUser(UserModel user) async {
    final users = _db['users'] ?? [];
    final idx = users.indexWhere((u) => u['id'] == user.id);
    if (idx != -1) {
      users[idx] = user.toJson();
      _db['users'] = users;
      return true;
    }
    return false;
  }

  Future<bool> deleteUser(String userId) async {
    final users = _db['users'] ?? [];
    final originalLength = users.length;
    users.removeWhere((u) => u['id'] == userId);
    _db['users'] = users;
    return users.length < originalLength;
  }

  void _initializeData() {
    print('🚀 Pre-populating in-memory database with Bangladeshi mock data...');
    
    // 1. Initial Users
    _db['users'] = [
      {
        'id': 'user_001',
        'email': 'nasim@salesmanager.com',
        'name': 'Nasim Hassan',
        'phone': '+880-1700-000001',
        'role': 'admin',
        'is_active': true,
        'created_at': DateTime(2024, 1, 1).toIso8601String(),
      },
      {
        'id': 'user_002',
        'email': 'ramim@salesmanager.com',
        'name': 'Ramim Rashid',
        'phone': '+880-1700-000002',
        'role': 'manager',
        'is_active': true,
        'reporting_manager': 'user_001',
        'created_at': DateTime(2024, 1, 5).toIso8601String(),
      },
      {
        'id': 'user_003',
        'email': 'emon@salesmanager.com',
        'name': 'Emon Khan',
        'phone': '+880-1700-000003',
        'role': 'salesperson',
        'is_active': true,
        'reporting_manager': 'user_002',
        'created_at': DateTime(2024, 1, 10).toIso8601String(),
      },
      {
        'id': 'user_004',
        'email': 'lamia@salesmanager.com',
        'name': 'Lamia Akter',
        'phone': '+880-1700-000004',
        'role': 'salesperson',
        'is_active': true,
        'reporting_manager': 'user_002',
        'created_at': DateTime(2024, 1, 15).toIso8601String(),
      },
    ];

    // 2. Initial Leads
    _db['leads'] = [
      {
        'id': 'lead_001',
        'name': 'Rahim Islam',
        'email': 'rahim@walton.com',
        'phone': '+880-1811-111111',
        'company': 'Walton Group',
        'stage': 'New',
        'value': 50000.0,
        'assigned_to': 'user_003',
        'created_by': 'user_003',
        'created_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'updated_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      },
      {
        'id': 'lead_002',
        'name': 'Karim Ahmed',
        'email': 'karim@pathao.com',
        'phone': '+880-1822-222222',
        'company': 'Pathao',
        'stage': 'Contacted',
        'value': 120000.0,
        'assigned_to': 'user_003',
        'created_by': 'user_003',
        'created_at': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        'updated_at': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
      },
      {
        'id': 'lead_003',
        'name': 'Sultana Begum',
        'email': 'sultana@bkash.com',
        'phone': '+880-1833-333333',
        'company': 'bKash Limited',
        'stage': 'Proposal',
        'value': 250000.0,
        'assigned_to': 'user_004',
        'created_by': 'user_002',
        'created_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'updated_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      },
      {
        'id': 'lead_004',
        'name': 'Tanvir Hasan',
        'email': 'tanvir@chaldal.com',
        'phone': '+880-1844-444444',
        'company': 'Chaldal',
        'stage': 'Negotiation',
        'value': 80000.0,
        'assigned_to': 'user_004',
        'created_by': 'user_004',
        'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'updated_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      },
      {
        'id': 'lead_005',
        'name': 'Jamil Chowdhury',
        'email': 'jamil@akij.com',
        'phone': '+880-1855-555555',
        'company': 'Akij Group',
        'stage': 'Closed Won',
        'value': 450000.0,
        'assigned_to': 'user_003',
        'created_by': 'user_003',
        'created_at': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        'updated_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'id': 'lead_006',
        'name': 'Nusrat Jahan',
        'email': 'nusrat@daraz.com',
        'phone': '+880-1866-666666',
        'company': 'Daraz Bangladesh',
        'stage': 'Closed Lost',
        'value': 60000.0,
        'assigned_to': 'user_004',
        'created_by': 'user_004',
        'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'updated_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
    ];

    // 3. Initial Proposals
    _db['proposals'] = [
      {
        'id': 'prop_001',
        'lead_id': 'lead_003',
        'title': 'Enterprise ERP Solution for bKash',
        'description': 'Full CRM and HRMS integration for bKash operations.',
        'amount': 250000.0,
        'status': 'sent',
        'valid_until': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'assigned_to': 'user_004',
        'created_by': 'user_002',
        'created_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'updated_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      },
      {
        'id': 'prop_002',
        'lead_id': 'lead_004',
        'title': 'Custom CRM for Chaldal Logistics',
        'description': 'Custom customer management tool with map and tracking.',
        'amount': 80000.0,
        'status': 'under review',
        'valid_until': DateTime.now().add(const Duration(days: 15)).toIso8601String(),
        'assigned_to': 'user_004',
        'created_by': 'user_004',
        'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'updated_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      },
      {
        'id': 'prop_003',
        'lead_id': 'lead_005',
        'title': 'Supply Chain ERP Walton',
        'description': 'Supply chain tracking system for Walton Group.',
        'amount': 450000.0,
        'status': 'accepted',
        'valid_until': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        'assigned_to': 'user_003',
        'created_by': 'user_003',
        'created_at': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        'updated_at': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      },
    ];

    // 4. Initial Customers
    _db['customers'] = [
      {
        'id': 'cust_001',
        'name': 'Jamil Chowdhury',
        'email': 'jamil@akij.com',
        'phone': '+880-1855-555555',
        'company': 'Akij Group',
        'created_by': 'user_003',
        'lead_id': 'lead_005',
        'created_at': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      },
      {
        'id': 'cust_002',
        'name': 'Rahim Islam',
        'email': 'rahim@walton.com',
        'phone': '+880-1811-111111',
        'company': 'Walton Group',
        'created_by': 'user_003',
        'lead_id': 'lead_001',
        'created_at': DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
      },
      {
        'id': 'cust_003',
        'name': 'Karim Ahmed',
        'email': 'karim@pathao.com',
        'phone': '+880-1822-222222',
        'company': 'Pathao Bangladesh',
        'created_by': 'user_003',
        'lead_id': 'lead_002',
        'created_at': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
      },
      {
        'id': 'cust_004',
        'name': 'Sultana Begum',
        'email': 'sultana@bkash.com',
        'phone': '+880-1833-333333',
        'company': 'bKash Limited',
        'created_by': 'user_002',
        'lead_id': 'lead_003',
        'created_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      },
      {
        'id': 'cust_005',
        'name': 'Nusrat Jahan',
        'email': 'nusrat@daraz.com',
        'phone': '+880-1866-666666',
        'company': 'Daraz Bangladesh',
        'created_by': 'user_004',
        'lead_id': 'lead_006',
        'created_at': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
      },
      {
        'id': 'cust_006',
        'name': 'Farhan Zaman',
        'email': 'farhan@grameenphone.com',
        'phone': '+880-1711-000005',
        'company': 'Grameenphone Ltd.',
        'created_by': 'user_001',
        'lead_id': null,
        'created_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      },
      {
        'id': 'cust_007',
        'name': 'Sadia Islam',
        'email': 'sadia@pranrfl.com',
        'phone': '+880-1722-000006',
        'company': 'PRAN-RFL Group',
        'created_by': 'user_001',
        'lead_id': null,
        'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      },
    ];

    // 5. Initial Meetings
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final nextWeek = DateTime.now().add(const Duration(days: 7));
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));

    _db['meetings'] = [
      {
        'id': 'meet_001',
        'title': 'Walton ERP Requirement Discussion',
        'description': 'Requirements gathering session with Walton tech team.',
        'scheduled_at': DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0).toIso8601String(),
        'duration': 60,
        'status': 'scheduled',
        'related_id': 'lead_001',
        'related_type': 'lead',
        'assigned_to': 'user_003',
        'created_by': 'user_003',
        'created_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'updated_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      },
      {
        'id': 'meet_002',
        'title': 'Pathao Integration Demo',
        'description': 'Demo of CRM capability to Pathao managers.',
        'scheduled_at': DateTime(nextWeek.year, nextWeek.month, nextWeek.day, 14, 0).toIso8601String(),
        'duration': 45,
        'status': 'scheduled',
        'related_id': 'lead_002',
        'related_type': 'lead',
        'assigned_to': 'user_003',
        'created_by': 'user_003',
        'created_at': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        'updated_at': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
      },
      {
        'id': 'meet_003',
        'title': 'bKash Proposal Final Review',
        'description': 'Final price negotiation meeting with bKash finance director.',
        'scheduled_at': DateTime(yesterday.year, yesterday.month, yesterday.day, 11, 0).toIso8601String(),
        'duration': 90,
        'status': 'completed',
        'related_id': 'lead_003',
        'related_type': 'lead',
        'assigned_to': 'user_004',
        'created_by': 'user_002',
        'created_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'updated_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      },
      {
        'id': 'meet_004',
        'title': 'Akij Group Kickoff Meeting',
        'description': 'Kickoff of the Supply Chain ERP project.',
        'scheduled_at': DateTime(threeDaysAgo.year, threeDaysAgo.month, threeDaysAgo.day, 16, 0).toIso8601String(),
        'duration': 60,
        'status': 'completed',
        'related_id': 'lead_005',
        'related_type': 'lead',
        'assigned_to': 'user_003',
        'created_by': 'user_003',
        'created_at': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        'updated_at': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      },
    ];

    // 6. Initial Notifications
    _db['notifications'] = [
      {
        'id': 'notif_001',
        'user_id': 'user_001',
        'title': 'New Lead Assigned',
        'message': 'A new lead Walton Group has been registered.',
        'type': 'lead',
        'is_read': false,
        'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': 'notif_002',
        'user_id': 'user_001',
        'title': 'Meeting Tomorrow',
        'message': 'You have a scheduled meeting "Walton ERP Requirement Discussion" tomorrow.',
        'type': 'meeting',
        'is_read': false,
        'created_at': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
      },
      {
        'id': 'notif_003',
        'user_id': 'user_001',
        'title': 'Lead Won!',
        'message': 'Lead Akij Group has been successfully Closed Won!',
        'type': 'lead',
        'is_read': false,
        'created_at': DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
      },
      {
        'id': 'notif_004',
        'user_id': 'user_001',
        'title': 'Proposal Approved',
        'message': 'The CRM integration proposal for Pathao has been approved by the client.',
        'type': 'proposal',
        'is_read': false,
        'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'id': 'notif_005',
        'user_id': 'user_001',
        'title': 'System Maintenance',
        'message': 'Sales Manager offline mode has been successfully synchronized and loaded.',
        'type': 'system',
        'is_read': true,
        'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      },
    ];
  }
}

enum MockQueryType { select, insert, update, delete }

class MockQueryBuilder implements Future<dynamic> {
  final SupabaseService _service;
  final String _table;
  
  // Accumulated filter operations
  final List<bool Function(Map<String, dynamic>)> _filters = [];
  String? _orderByColumn;
  bool _orderByAscending = true;
  
  MockQueryType _type = MockQueryType.select;
  dynamic _insertData;
  Map<String, dynamic>? _updateData;
  
  // Future state representation executing in-memory operations
  Future<dynamic> get _future {
    return Future.delayed(const Duration(milliseconds: 5), () {
      final list = _service._db[_table] ?? [];
      
      if (_type == MockQueryType.select) {
        // Apply filters
        var filtered = list.toList();
        for (final filter in _filters) {
          filtered = filtered.where(filter).toList();
        }
        
        // Apply order
        if (_orderByColumn != null) {
          filtered.sort((a, b) {
            final valA = a[_orderByColumn];
            final valB = b[_orderByColumn];
            if (valA == null && valB == null) return 0;
            if (valA == null) return _orderByAscending ? -1 : 1;
            if (valB == null) return _orderByAscending ? 1 : -1;
            if (valA is String && valB is String) {
              return _orderByAscending ? valA.compareTo(valB) : valB.compareTo(valA);
            }
            if (valA is num && valB is num) {
              return _orderByAscending ? valA.compareTo(valB) : valB.compareTo(valA);
            }
            return 0;
          });
        }
        return filtered;
      }
      
      else if (_type == MockQueryType.insert) {
        final data = _insertData;
        if (data is Map<String, dynamic>) {
          final record = Map<String, dynamic>.from(data);
          if (!record.containsKey('id') || record['id'] == null || record['id'] == '') {
            record['id'] = '${_table.substring(0, 3)}_${DateTime.now().millisecondsSinceEpoch}';
          }
          list.add(record);
          _service._db[_table] = list;
          return record;
        } else if (data is List) {
          final inserted = <Map<String, dynamic>>[];
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              final record = Map<String, dynamic>.from(item);
              if (!record.containsKey('id') || record['id'] == null || record['id'] == '') {
                record['id'] = '${_table.substring(0, 3)}_${DateTime.now().millisecondsSinceEpoch}_${inserted.length}';
              }
              list.add(record);
              inserted.add(record);
            }
          }
          _service._db[_table] = list;
          return inserted;
        }
        return data;
      }
      
      else if (_type == MockQueryType.update) {
        final data = _updateData ?? {};
        var count = 0;
        final updatedRecords = <Map<String, dynamic>>[];
        for (var i = 0; i < list.length; i++) {
          final item = list[i];
          
          var matches = true;
          for (final filter in _filters) {
            if (!filter(item)) {
              matches = false;
              break;
            }
          }
          
          if (matches) {
            final updated = Map<String, dynamic>.from(item)..addAll(data);
            list[i] = updated;
            updatedRecords.add(updated);
            count++;
          }
        }
        _service._db[_table] = list;
        print('✅ Mock update applied to $count records in $_table');
        return updatedRecords;
      }
      
      else if (_type == MockQueryType.delete) {
        final originalLength = list.length;
        final deletedRecords = <Map<String, dynamic>>[];
        list.removeWhere((item) {
          var matches = true;
          for (final filter in _filters) {
            if (!filter(item)) {
              matches = false;
              break;
            }
          }
          if (matches) {
            deletedRecords.add(item);
          }
          return matches;
        });
        
        _service._db[_table] = list;
        print('✅ Mock delete removed ${originalLength - list.length} records from $_table');
        return deletedRecords;
      }
      
      return [];
    });
  }

  MockQueryBuilder(this._service, this._table);

  MockQueryBuilder select([String columns = '*']) {
    return this;
  }

  MockQueryBuilder order(String column, {bool ascending = true}) {
    _orderByColumn = column;
    _orderByAscending = ascending;
    return this;
  }

  MockQueryBuilder eq(String column, dynamic value) {
    _filters.add((item) => item[column] == value);
    return this;
  }

  MockQueryBuilder neq(String column, dynamic value) {
    _filters.add((item) => item[column] != value);
    return this;
  }

  MockQueryBuilder gt(String column, dynamic value) {
    _filters.add((item) {
      final val = item[column];
      if (val == null) return false;
      if (val is String && value is String) return val.compareTo(value) > 0;
      if (val is num && value is num) return val > value;
      return false;
    });
    return this;
  }

  MockQueryBuilder gte(String column, dynamic value) {
    _filters.add((item) {
      final val = item[column];
      if (val == null) return false;
      if (val is String && value is String) return val.compareTo(value) >= 0;
      if (val is num && value is num) return val >= value;
      return false;
    });
    return this;
  }

  MockQueryBuilder lt(String column, dynamic value) {
    _filters.add((item) {
      final val = item[column];
      if (val == null) return false;
      if (val is String && value is String) return val.compareTo(value) < 0;
      if (val is num && value is num) return val < value;
      return false;
    });
    return this;
  }

  MockQueryBuilder lte(String column, dynamic value) {
    _filters.add((item) {
      final val = item[column];
      if (val == null) return false;
      if (val is String && value is String) return val.compareTo(value) <= 0;
      if (val is num && value is num) return val <= value;
      return false;
    });
    return this;
  }

  // Insert operation
  MockQueryBuilder insert(dynamic data) {
    _type = MockQueryType.insert;
    _insertData = data;
    return this;
  }

  // Update operation
  MockQueryBuilder update(Map<String, dynamic> data) {
    _type = MockQueryType.update;
    _updateData = data;
    return this;
  }

  // Delete operation
  MockQueryBuilder delete() {
    _type = MockQueryType.delete;
    return this;
  }

  // Single record result
  Future<dynamic> single() {
    return _future.then((data) {
      if (data is List) {
        if (data.isNotEmpty) return data.first;
        throw Exception('No records found for single()');
      }
      return data;
    });
  }

  @override
  Stream<dynamic> asStream() => _future.asStream();

  @override
  Future<dynamic> catchError(Function onError, {bool Function(Object error)? test}) =>
      _future.catchError(onError, test: test);

  @override
  Future<R> then<R>(FutureOr<R> Function(dynamic value) onValue, {Function? onError}) =>
      _future.then(onValue, onError: onError);

  @override
  Future<dynamic> timeout(Duration timeLimit, {FutureOr<dynamic> Function()? onTimeout}) =>
      _future.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<dynamic> whenComplete(FutureOr<void> Function() action) =>
      _future.whenComplete(action);
}

class MockAuth {
  final SupabaseService _service;
  
  MockAuth(this._service);

  MockUser? get currentUser {
    final users = _service._db['users'] ?? [];
    if (users.isEmpty) return null;
    final nasim = users.firstWhere((u) => u['id'] == 'user_001', orElse: () => users.first);
    return MockUser(nasim['id'], nasim['email']);
  }
}

class MockUser {
  final String id;
  final String? email;
  MockUser(this.id, this.email);
}

// Mock Realtime classes for Notifications or other realtime providers
class RealtimeChannel {
  void unsubscribe() {}
  RealtimeChannel channel(String channelId) => this;
  RealtimeChannel onPostgresChanges({
    required dynamic event,
    required String schema,
    required String table,
    required dynamic filter,
    required void Function(dynamic payload) callback,
  }) => this;
  RealtimeChannel subscribe() => this;
}

enum PostgresChangeEvent { insert, update, delete, all }

class PostgresChangeFilter {
  final PostgresChangeFilterType type;
  final String column;
  final dynamic value;
  PostgresChangeFilter({required this.type, required this.column, required this.value});
}

enum PostgresChangeFilterType { eq, neq }
