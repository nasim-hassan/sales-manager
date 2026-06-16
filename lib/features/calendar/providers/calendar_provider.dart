import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:customer_relationship_management/core/models/meeting_model.dart';
import 'package:customer_relationship_management/core/models/user_model.dart';
import 'package:customer_relationship_management/core/constants/app_constants.dart';

class CalendarEvent {
  final String id;
  final String title;
  final DateTime dateTime;
  final String? description;
  final String type; // 'meeting', 'task', etc.
  final String? relatedTo; // lead or customer id
  final String? relatedType; // 'lead' or 'customer'

  CalendarEvent({
    required this.id,
    required this.title,
    required this.dateTime,
    this.description,
    required this.type,
    this.relatedTo,
    this.relatedType,
  });
}

class CalendarProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<CalendarEvent> _events = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();

  List<CalendarEvent> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;

  // Get events for selected date
  List<CalendarEvent> get eventsForSelectedDate {
    return getEventsForDate(_selectedDate);
  }

  // Get upcoming events (next 7 days)
  List<CalendarEvent> get upcomingEvents {
    final now = DateTime.now();
    final inAWeek = now.add(const Duration(days: 7));
    return getEventsInRange(now, inAWeek);
  }

  CalendarProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchEvents();
  }

  /// Fetch all meetings and convert to calendar events
  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from(AppConstants.meetingsTable)
          .select()
          .order('scheduled_at', ascending: true);

      _events = (response as List).map((json) {
        final meeting = MeetingModel.fromJson(json);
        return CalendarEvent(
          id: meeting.id,
          title: meeting.title,
          dateTime: meeting.scheduledAt,
          description: meeting.description,
          type: 'meeting',
          relatedTo: meeting.relatedId,
          relatedType: meeting.relatedType,
        );
      }).toList();

      print('✅ Loaded ${_events.length} calendar events from Supabase');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load calendar events: $e';
      print('❌ Error fetching calendar events: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get visible events based on user role
  List<CalendarEvent> getVisibleEvents(UserModel currentUser) {
    // First get user's meetings
    if (currentUser.role == 'admin') {
      return _events;
    } else {
      // For non-admin users, we need to filter by their team
      // This would typically involve looking up which meetings they created or attend
      return _events;
    }
  }

  /// Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Get events for a specific date
  List<CalendarEvent> getEventsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _events
        .where(
          (event) =>
              event.dateTime.isAfter(startOfDay) &&
              event.dateTime.isBefore(endOfDay),
        )
        .toList();
  }

  /// Get events in a date range
  List<CalendarEvent> getEventsInRange(DateTime start, DateTime end) {
    return _events
        .where(
          (event) =>
              event.dateTime.isAfter(start) && event.dateTime.isBefore(end),
        )
        .toList();
  }

  /// Get events for a specific month
  List<CalendarEvent> getEventsForMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(
      date.year,
      date.month + 1,
      1,
    ).subtract(const Duration(days: 1));

    return getEventsInRange(firstDay, lastDay);
  }

  /// Get event by ID
  CalendarEvent? getEventById(String eventId) {
    try {
      return _events.firstWhere((e) => e.id == eventId);
    } catch (e) {
      return null;
    }
  }

  /// Get events for a specific lead
  List<CalendarEvent> getEventsForLead(String leadId) {
    return _events
        .where((e) => e.relatedTo == leadId && e.relatedType == 'lead')
        .toList();
  }

  /// Get events by type
  List<CalendarEvent> getEventsByType(String type) {
    return _events.where((e) => e.type == type).toList();
  }

  /// Search events
  List<CalendarEvent> searchEvents(String query) {
    return _events
        .where(
          (event) =>
              event.title.toLowerCase().contains(query.toLowerCase()) ||
              (event.description?.toLowerCase().contains(query.toLowerCase()) ??
                  false),
        )
        .toList();
  }

  /// Check if a date has events
  bool hasEventsOnDate(DateTime date) {
    return getEventsForDate(date).isNotEmpty;
  }

  /// Get count of events for a date
  int getEventCountForDate(DateTime date) {
    return getEventsForDate(date).length;
  }

  /// Get the next event from now
  CalendarEvent? getNextEvent() {
    final now = DateTime.now();
    final futureEvents = _events.where((e) => e.dateTime.isAfter(now)).toList();
    if (futureEvents.isEmpty) return null;
    futureEvents.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return futureEvents.first;
  }

  /// Get all day events (meetings with 0 or full day duration)
  List<CalendarEvent> getAllDayEvents() {
    return _events.where((e) => e.type == 'all-day').toList();
  }

  /// Refresh calendar events
  Future<void> refreshEvents() async {
    await fetchEvents();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
