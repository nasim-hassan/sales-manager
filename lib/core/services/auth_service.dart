import 'package:sales_manager/core/models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  
  // Mock current user - logged in by default
  UserModel? _currentUser = UserModel(
    id: 'user_001',
    email: 'nasim@salesmanager.com',
    name: 'Nasim Hassan',
    phone: '+880-1700-000001',
    role: 'admin',
    isActive: true,
    createdBy: null,
    reportingManager: null,
    createdAt: DateTime(2024, 1, 1),
  );

  AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  void initialize() {
    // Keep for compatibility but it's already set
    print('✅ AuthService initialized with mock user: ${_currentUser?.name}');
  }

  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  Future<bool> login(String email, String password) async {
    try {
      print('🔑 Mock Login attempt for: $email');
      // Simulate login delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock users database
      final mockUsers = _getMockUsers();
      final user = mockUsers.firstWhere(
        (u) => u.email == email,
        orElse: () => throw Exception('User not found'),
      );

      _currentUser = user;
      print('✅ Mock Login successful for: $email (${user.name})');
      return true;
    } catch (e) {
      print('❌ Mock Login Error: $e');
      rethrow;
    }
  }

  Future<bool> signup(
    String email,
    String password,
    String name,
    String phone,
    String role,
  ) async {
    try {
      print('🔑 Mock Signup for: $email, $name');
      // Simulate signup delay
      await Future.delayed(const Duration(milliseconds: 500));

      _currentUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        phone: phone,
        role: role,
        isActive: true,
        createdAt: DateTime.now(),
      );
      print('✅ Mock Signup successful: $name');
      return true;
    } catch (e) {
      print('❌ Mock Signup Error: $e');
      return false;
    }
  }

  Future<String> createAccount(
    String email,
    String password, {
    String? name,
    String? phone,
    String? role,
    String? createdBy,
    String? reportingManager,
  }) async {
    try {
      print('🔑 Mock Creating account for: $email');
      // Simulate account creation delay
      await Future.delayed(const Duration(milliseconds: 500));

      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _currentUser = UserModel(
        id: userId,
        email: email,
        name: name ?? email.split('@')[0],
        phone: phone ?? '',
        role: role ?? 'salesperson',
        isActive: true,
        createdBy: createdBy,
        reportingManager: reportingManager,
        createdAt: DateTime.now(),
      );
      print('✅ Mock Account created: $userId');
      return userId;
    } catch (e) {
      print('❌ Mock CreateAccount Error: $e');
      rethrow;
    }
  }

  Future<UserModel?> getCurrentUserDetails() async {
    if (_currentUser == null) {
      print('❌ No current user to fetch details for');
      return null;
    }

    try {
      print('🔍 Getting mock user details for: ${_currentUser?.name}');
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 200));
      print('✅ Mock user details fetched: ${_currentUser?.name}');
      return _currentUser;
    } catch (e) {
      print('❌ GetCurrentUserDetails Error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      print('🚪 Mock Logout');
      _currentUser = null;
      print('✅ Mock Logout successful');
    } catch (e) {
      print('❌ Mock Logout Error: $e');
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      print('🔑 Mock ResetPassword for: $email');
      // Simulate email sending
      await Future.delayed(const Duration(milliseconds: 500));
      print('✅ Mock ResetPassword email sent to: $email');
      return true;
    } catch (e) {
      print('❌ Mock ResetPassword Error: $e');
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      print('🔑 Mock UpdatePassword');
      // Simulate password update
      await Future.delayed(const Duration(milliseconds: 500));
      print('✅ Mock Password updated');
      return true;
    } catch (e) {
      print('❌ Mock UpdatePassword Error: $e');
      return false;
    }
  }

  // Mock users database
  List<UserModel> _getMockUsers() {
    return [
      UserModel(
        id: 'user_001',
        email: 'nasim@salesmanager.com',
        name: 'Nasim Hassan',
        phone: '+880-1700-000001',
        role: 'admin',
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
      ),
      UserModel(
        id: 'user_002',
        email: 'ramim@salesmanager.com',
        name: 'Ramim Rashid',
        phone: '+880-1700-000002',
        role: 'manager',
        isActive: true,
        createdAt: DateTime(2024, 1, 5),
      ),
      UserModel(
        id: 'user_003',
        email: 'emon@salesmanager.com',
        name: 'Emon Khan',
        phone: '+880-1700-000003',
        role: 'salesperson',
        isActive: true,
        createdAt: DateTime(2024, 1, 10),
      ),
      UserModel(
        id: 'user_004',
        email: 'lamia@salesmanager.com',
        name: 'Lamia Akter',
        phone: '+880-1700-000004',
        role: 'salesperson',
        isActive: true,
        createdAt: DateTime(2024, 1, 15),
      ),
    ];
  }
}
