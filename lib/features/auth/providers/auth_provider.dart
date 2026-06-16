import 'package:flutter/material.dart';
import 'package:customer_relationship_management/core/services/auth_service.dart';
import 'package:customer_relationship_management/core/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _authService.isLoggedIn;

  Future<void> initialize() async {
    _authService.initialize();
    await _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await _authService.getCurrentUserDetails();
      print(
        '✅ AuthProvider: User loaded - name=${_currentUser?.name}, role=${_currentUser?.role}',
      );
    } catch (e) {
      print('❌ AuthProvider: Error loading user - $e');
      _currentUser = null;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await _authService.login(email, password);

      if (success) {
        await _loadCurrentUser();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Parse Supabase error messages
      String errorMessage = e.toString();
      if (errorMessage.contains('Invalid login credentials')) {
        _error = 'Invalid email or password';
      } else if (errorMessage.contains('Email not confirmed')) {
        _error = 'Please confirm your email before logging in';
      } else if (errorMessage.contains('Network')) {
        _error = 'Network error. Check your connection';
      } else {
        _error = 'Login failed: $errorMessage';
      }
      print('❌ Login Exception: $e');
      _isLoading = false;
      notifyListeners();
      return false;
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
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await _authService.signup(
        email,
        password,
        name,
        phone,
        role,
      );

      if (success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to signup';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.logout();
      _currentUser = null;
      _error = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await _authService.updatePassword(newPassword);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
