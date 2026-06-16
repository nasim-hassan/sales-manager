import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:customer_relationship_management/core/models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  GoTrueClient get authClient => Supabase.instance.client.auth;

  void initialize() {
    try {
      // Ensure Supabase is initialized
      final supabase = Supabase.instance.client;
      print(
        '✅ AuthService initialized. Auth client available: ${supabase.auth}',
      );
    } catch (e) {
      print('❌ AuthService initialization error: $e');
    }
  }

  User? get currentUser {
    try {
      return Supabase.instance.client.auth.currentUser;
    } catch (e) {
      print('❌ CurrentUser error: $e');
      return null;
    }
  }

  bool get isLoggedIn => currentUser != null;

  Future<bool> login(String email, String password) async {
    try {
      print('🔑 Attempting login for: $email');
      final response = await authClient.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('✅ Login successful for: $email');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Login Error: $e');
      print('Email: $email');
      rethrow; // Throw error to provider so it can show to user
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
      final authResponse = await authClient.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        return false;
      }

      // Create user record in the users table
      try {
        await Supabase.instance.client.from('users').insert({
          'id': authResponse.user!.id,
          'email': email,
          'name': name,
          'phone': phone,
          'role': role,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('✅ Signup: User record created in users table');
        return true;
      } catch (dbError) {
        print('❌ Signup: Failed to create user record: $dbError');
        return false;
      }
    } catch (e) {
      print('❌ Signup Error: $e');
      return false;
    }
  }

  /// Create a new account without logging out the current user
  /// Also creates the user record in the users table
  /// Returns the created user ID
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
      print('🔑 Creating account for: $email');

      // Use existing Supabase client instead of creating a temporary one
      final supabase = Supabase.instance.client;

      // Step 1: Create Auth account
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userId = response.user!.id;
        print('✅ Account created in Auth: $userId');

        // Step 2: Create user record in users table
        try {
          await supabase.from('users').insert({
            'id': userId,
            'email': email,
            'name': name ?? email.split('@')[0],
            'phone': phone ?? '',
            'role': role ?? 'salesperson',
            'is_active': true,
            'created_by': createdBy,
            'reporting_manager': reportingManager,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
          print('✅ User record created in users table: $userId');
        } catch (dbError) {
          print('❌ Failed to create user record: $dbError');
          // If user record creation fails, it's a critical error
          throw Exception(
            'User Auth created but failed to create user record: $dbError',
          );
        }

        return userId;
      }

      throw Exception('Supabase Auth returned no user');
    } catch (e) {
      print('❌ Create Account Error: $e');

      // If user already exists, try to sign in to get ID
      if (e.toString().contains('already registered') ||
          e.toString().contains('User already exists')) {
        print('⚠️ User exists, attempting to fetch ID via login...');
        try {
          final supabase = Supabase.instance.client;
          final loginResponse = await supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );
          if (loginResponse.user != null) {
            print('✅ Existing user found: ${loginResponse.user!.id}');
            return loginResponse.user!.id;
          }
        } catch (loginError) {
          print('❌ Login fallback failed: $loginError');
          throw Exception(
            'User exists but login failed: ${loginError.toString()}',
          );
        }
      }

      throw e; // Rethrow original error to be caught by provider
    }
  }

  Future<UserModel?> getCurrentUserDetails() async {
    if (!isLoggedIn) {
      print('❌ getCurrentUserDetails: User not logged in');
      return null;
    }

    try {
      final user = currentUser!;
      print('🔍 Fetching user details for: ${user.id}');
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      print('✅ User data fetched: $response');
      final userModel = UserModel.fromJson(response);
      print('✅ User model created: role=${userModel.role}');
      return userModel;
    } catch (e) {
      print('❌ GetCurrentUserDetails Error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await authClient.signOut();
      print('✅ Logout successful');
    } catch (e) {
      print('❌ Logout Error: $e');
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await authClient.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      print('❌ ResetPassword Error: $e');
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      await authClient.updateUser(UserAttributes(password: newPassword));
      return true;
    } catch (e) {
      print('❌ UpdatePassword Error: $e');
      return false;
    }
  }

  Stream<AuthState> onAuthStateChanged() {
    return authClient.onAuthStateChange;
  }
}
