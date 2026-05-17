import 'package:flutter/material.dart';
import 'package:sales_manager/core/services/supabase_service.dart';
import 'package:sales_manager/core/services/auth_service.dart';
import 'package:sales_manager/core/models/user_model.dart';

class UserManagementProvider extends ChangeNotifier {
  final _supabaseService = SupabaseService();
  final _authService = AuthService();

  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAllUsers() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _users = await _supabaseService.getAllUsers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load users: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser(
    String email,
    String password,
    String name,
    String phone,
    String role, {
    String? createdBy,
    String? reportingManager,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await _authService.createAccount(
        email,
        password,
        name: name,
        phone: phone,
        role: role,
        createdBy: createdBy,
        reportingManager: reportingManager,
      );

      // createAccount returns the userId if successful
      if (success.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 500));
        await fetchAllUsers();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to create user';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error creating user: $e';
      print('❌ Error creating user: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deactivateUser(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _users.firstWhere((u) => u.id == userId);
      final updatedUser = user.copyWith(isActive: false);

      final success = await _supabaseService.updateUser(updatedUser);

      if (success) {
        await fetchAllUsers();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to deactivate user';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error deactivating user: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> activateUser(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _users.firstWhere((u) => u.id == userId);
      final updatedUser = user.copyWith(isActive: true);

      final success = await _supabaseService.updateUser(updatedUser);

      if (success) {
        await fetchAllUsers();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to activate user';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error activating user: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<String> getCreatableRoles(String currentUserRole) {
    switch (currentUserRole) {
      case 'admin':
        return ['admin', 'manager', 'salesperson'];
      case 'manager':
        return ['manager', 'salesperson'];
      case 'salesperson':
      default:
        return [];
    }
  }

  bool canManageUsers(String userRole) {
    return userRole == 'admin' || userRole == 'manager';
  }
}
