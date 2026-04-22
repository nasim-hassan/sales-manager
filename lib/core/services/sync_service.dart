import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SyncService {
  static final SyncService _instance = SyncService._internal();

  final _connectivity = Connectivity();
  late SharedPreferences _prefs;

  SyncService._internal();

  factory SyncService() {
    return _instance;
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> isOnline() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Stream<bool> onConnectivityChanged() async* {
    await for (final result in _connectivity.onConnectivityChanged) {
      yield result != ConnectivityResult.none;
    }
  }

  Future<void> saveToLocalCache(String key, dynamic value) async {
    try {
      final jsonString = jsonEncode(value);
      await _prefs.setString(key, jsonString);
    } catch (e) {
      print('Error saving to cache: $e');
    }
  }

  dynamic getFromLocalCache(String key) {
    try {
      final jsonString = _prefs.getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString);
    } catch (e) {
      print('Error retrieving from cache: $e');
      return null;
    }
  }

  Future<void> clearLocalCache() async {
    try {
      await _prefs.clear();
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  Future<void> removeFromCache(String key) async {
    try {
      await _prefs.remove(key);
    } catch (e) {
      print('Error removing from cache: $e');
    }
  }

  List<String> getAllCacheKeys() {
    return _prefs.getKeys().toList();
  }
}
