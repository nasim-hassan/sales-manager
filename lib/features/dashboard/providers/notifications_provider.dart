import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sales_manager/core/models/notification_model.dart';
import 'package:sales_manager/core/constants/app_constants.dart';

class NotificationsProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  RealtimeChannel? _subscription;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  int get unreadCount => unreadNotifications.length;

  NotificationsProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchNotifications();
    _setupRealtimeSubscription();
  }

  /// Fetch notifications from Supabase
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _error = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _supabase
          .from(AppConstants.notificationsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _notifications = (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      print('✅ Loaded ${_notifications.length} notifications from Supabase');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load notifications: $e';
      print('❌ Error fetching notifications: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Setup real-time subscription for new notifications
  void _setupRealtimeSubscription() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Remove existing subscription if any
    _subscription?.unsubscribe();

    // Subscribe to notifications for current user
    _subscription = _supabase
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: AppConstants.notificationsTable,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            print('🔔 New notification received: ${payload.newRecord}');
            final newNotification =
                NotificationModel.fromJson(payload.newRecord);
            _notifications.insert(0, newNotification);
            notifyListeners();
          },
        )
        .subscribe();

    print('✅ Real-time notifications subscription active');
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from(AppConstants.notificationsTable)
          .update({'is_read': true})
          .eq('id', notificationId);

      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }

      notifyListeners();
      print('✅ Notification marked as read: $notificationId');
      return true;
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase
          .from(AppConstants.notificationsTable)
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);

      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }

      notifyListeners();
      print('✅ All notifications marked as read');
      return true;
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from(AppConstants.notificationsTable)
          .delete()
          .eq('id', notificationId);

      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
      print('✅ Notification deleted: $notificationId');
      return true;
    } catch (e) {
      print('❌ Error deleting notification: $e');
      return false;
    }
  }

  /// Delete all notifications
  Future<bool> deleteAllNotifications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase
          .from(AppConstants.notificationsTable)
          .delete()
          .eq('user_id', userId);

      _notifications.clear();
      notifyListeners();
      print('✅ All notifications deleted');
      return true;
    } catch (e) {
      print('❌ Error deleting all notifications: $e');
      return false;
    }
  }

  /// Get notifications by type
  List<NotificationModel> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Get unread notifications
  List<NotificationModel> getUnreadNotifications() {
    return unreadNotifications;
  }

  /// Get recent notifications
  List<NotificationModel> getRecentNotifications(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _notifications
        .where((n) => n.createdAt.isAfter(cutoffDate))
        .toList();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }
}
