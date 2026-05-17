import 'package:flutter/material.dart';
import 'package:sales_manager/core/models/user_model.dart';
import 'package:sales_manager/core/constants/app_constants.dart';
import 'package:sales_manager/core/services/auth_service.dart';
import 'package:sales_manager/core/services/supabase_service.dart';

class UsersProvider extends ChangeNotifier {
  final _supabaseService = SupabaseService();
  final _supabase = SupabaseService();

  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UsersProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchUsers();
  }

  /// Fetch all users from Supabase
  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from(AppConstants.usersTable)
          .select()
          .order('created_at', ascending: false);

      _users = (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();

      print('✅ Loaded ${_users.length} users from Supabase');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load users: $e';
      print('❌ Error fetching users: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add new user to Supabase
  Future<bool> addUser(UserModel user, {String? password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String userId = user.id;

      // If creating new user with password, create Auth account + user record together
      if (userId.isEmpty && password != null && password.isNotEmpty) {
        userId = await AuthService().createAccount(
          user.email,
          password,
          name: user.name,
          phone: user.phone,
          role: user.role,
          createdBy: user.createdBy,
          reportingManager: user.reportingManager,
        );
        // Note: createAccount now creates both Auth account AND user record
        // So we need to refresh the users list instead of inserting again
        await Future.delayed(
          const Duration(milliseconds: 500),
        ); // Small delay for consistency
        await fetchUsers();
        _isLoading = false;
        notifyListeners();
        print('✅ User created successfully: ${user.email}');
        return true;
      } else if (userId.isEmpty) {
        // Fallback or error if no password provided for new user
        throw Exception('Password is required to create a new user');
      }

      // If user ID is provided, just insert the record (for existing auth users)
      final userData = {
        'id': userId,
        'email': user.email,
        'name': user.name,
        'phone': user.phone,
        'role': user.role,
        'is_active': user.isActive,
        'created_by': user.createdBy,
        'reporting_manager': user.reportingManager,
        'is_super_admin': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from(AppConstants.usersTable)
          .insert(userData)
          .select()
          .single();

      final createdUser = UserModel.fromJson(response);
      _users.add(createdUser);
      _isLoading = false;
      notifyListeners();
      print('✅ User added: ${createdUser.email} with ID: ${createdUser.id}');
      return true;
    } catch (e) {
      _error = 'Failed to add user: $e';
      print('❌ Error adding user: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update user in Supabase
  Future<bool> updateUser(UserModel user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userData = {
        'name': user.name,
        'phone': user.phone,
        'role': user.role,
        'is_active': user.isActive,
        'reporting_manager': user.reportingManager,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from(AppConstants.usersTable)
          .update(userData)
          .eq('id', user.id);

      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = user.copyWith(updatedAt: DateTime.now());
      }

      _isLoading = false;
      notifyListeners();
      print('✅ User updated: ${user.email}');
      return true;
    } catch (e) {
      _error = 'Failed to update user: $e';
      print('❌ Error updating user: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete user from Supabase
  Future<bool> deleteUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabaseService.from(AppConstants.usersTable).delete().eq('id', userId);

      _users.removeWhere((u) => u.id == userId);
      _isLoading = false;
      notifyListeners();
      print('✅ User deleted: $userId');
      return true;
    } catch (e) {
      _error = 'Failed to delete user: $e';
      print('❌ Error deleting user: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get visible users based on role and team relationships
  List<UserModel> getVisibleUsers(UserModel currentUser) {
    if (currentUser.role == 'admin') {
      return _users;
    } else if (currentUser.role == 'manager') {
      // Managers see themselves and their salespeople
      return _users
          .where(
            (u) =>
                u.id == currentUser.id || u.reportingManager == currentUser.id,
          )
          .toList();
    } else {
      // Salespeople see only themselves
      return _users.where((u) => u.id == currentUser.id).toList();
    }
  }

  /// Get managers only
  List<UserModel> getManagers() {
    return _users.where((u) => u.role == 'manager').toList();
  }

  /// Get salespeople only
  List<UserModel> getSalespeople() {
    return _users.where((u) => u.role == 'salesperson').toList();
  }

  /// Get team members for a manager
  List<UserModel> getTeamMembers(String managerId) {
    return _users.where((u) => u.reportingManager == managerId).toList();
  }

  /// Search users by name or email
  List<UserModel> searchUsers(String query) {
    return _users
        .where(
          (user) =>
              user.name.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  /// Get user by ID
  UserModel? getUserById(String userId) {
    try {
      return _users.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }
}
