import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sales_manager/core/constants/app_constants.dart';
import 'package:sales_manager/core/models/user_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  late SupabaseClient _client;

  SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseClient get client => _client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseKey,
    );
    _client = Supabase.instance.client;
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _client
          .from(AppConstants.usersTable)
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _client.from(AppConstants.usersTable).select();

      return (response as List)
          .map((user) => UserModel.fromJson(user))
          .toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  Future<bool> insertUser(UserModel user) async {
    try {
      await _client.from(AppConstants.usersTable).insert(user.toJson());
      return true;
    } catch (e) {
      print('Error inserting user: $e');
      return false;
    }
  }

  Future<bool> updateUser(UserModel user) async {
    try {
      await _client
          .from(AppConstants.usersTable)
          .update(user.toJson())
          .eq('id', user.id);
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await _client.from(AppConstants.usersTable).delete().eq('id', userId);
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }
}
