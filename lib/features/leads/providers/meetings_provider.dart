import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:customer_relationship_management/core/models/meeting_model.dart';
import 'package:customer_relationship_management/core/models/user_model.dart';
import 'package:customer_relationship_management/core/constants/app_constants.dart';

class MeetingsProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<MeetingModel> _meetings = [];
  bool _isLoading = false;
  String? _error;

  List<MeetingModel> get meetings => _meetings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  MeetingsProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchMeetings();
  }

  /// Fetch all meetings from Supabase
  Future<void> fetchMeetings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from(AppConstants.meetingsTable)
          .select()
          .order('scheduled_at', ascending: true);

      _meetings = (response as List)
          .map((json) => MeetingModel.fromJson(json))
          .toList();

      print('✅ Loaded ${_meetings.length} meetings from Supabase');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load meetings: $e';
      print('❌ Error fetching meetings: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get visible meetings based on user role
  List<MeetingModel> getVisibleMeetings(UserModel currentUser) {
    if (currentUser.role == 'admin') {
      return _meetings;
    } else if (currentUser.role == 'manager') {
      // Managers see meetings they created or assigned to them
      return _meetings
          .where(
            (m) =>
                m.createdBy == currentUser.id || m.assignedTo == currentUser.id,
          )
          .toList();
    } else {
      // Salespeople see only their meetings
      return _meetings
          .where(
            (m) =>
                m.createdBy == currentUser.id || m.assignedTo == currentUser.id,
          )
          .toList();
    }
  }

  /// Add new meeting to Supabase
  Future<bool> addMeeting(MeetingModel meeting) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final meetingData = {
        'title': meeting.title,
        'description': meeting.description,
        'scheduled_at': meeting.scheduledAt.toIso8601String(),
        'duration': meeting.duration,
        'status': meeting.status,
        'related_id': meeting.relatedId,
        'related_type': meeting.relatedType,
        'assigned_to': meeting.assignedTo,
        'created_by': meeting.createdBy,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from(AppConstants.meetingsTable)
          .insert(meetingData)
          .select()
          .single();

      final newMeeting = MeetingModel.fromJson(response);
      _meetings.add(newMeeting);
      _meetings.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      _isLoading = false;
      notifyListeners();
      print('✅ Meeting added: ${meeting.title}');
      return true;
    } catch (e) {
      _error = 'Failed to add meeting: $e';
      print('❌ Error adding meeting: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update meeting in Supabase
  Future<bool> updateMeeting(MeetingModel meeting) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final meetingData = {
        'title': meeting.title,
        'description': meeting.description,
        'scheduled_at': meeting.scheduledAt.toIso8601String(),
        'duration': meeting.duration,
        'status': meeting.status,
        'related_id': meeting.relatedId,
        'related_type': meeting.relatedType,
        'assigned_to': meeting.assignedTo,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from(AppConstants.meetingsTable)
          .update(meetingData)
          .eq('id', meeting.id);

      final index = _meetings.indexWhere((m) => m.id == meeting.id);
      if (index != -1) {
        _meetings[index] = meeting;
        _meetings.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      }

      _isLoading = false;
      notifyListeners();
      print('✅ Meeting updated: ${meeting.title}');
      return true;
    } catch (e) {
      _error = 'Failed to update meeting: $e';
      print('❌ Error updating meeting: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete meeting from Supabase
  Future<bool> deleteMeeting(String meetingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase
          .from(AppConstants.meetingsTable)
          .delete()
          .eq('id', meetingId);

      _meetings.removeWhere((m) => m.id == meetingId);
      _isLoading = false;
      notifyListeners();
      print('✅ Meeting deleted: $meetingId');
      return true;
    } catch (e) {
      _error = 'Failed to delete meeting: $e';
      print('❌ Error deleting meeting: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get meetings for a specific lead
  List<MeetingModel> getMeetingsForLead(String leadId) {
    return _meetings
        .where((m) => m.relatedId == leadId && m.relatedType == 'lead')
        .toList();
  }

  /// Get meetings for a specific user (as organizer or attendee)
  List<MeetingModel> getMeetingsForUser(String userId) {
    return _meetings
        .where((m) => m.createdBy == userId || m.assignedTo == userId)
        .toList();
  }

  /// Get upcoming meetings (from now onwards)
  List<MeetingModel> getUpcomingMeetings() {
    final now = DateTime.now();
    return _meetings.where((m) => m.scheduledAt.isAfter(now)).toList();
  }

  /// Get meetings for a specific date
  List<MeetingModel> getMeetingsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _meetings
        .where(
          (m) =>
              m.scheduledAt.isAfter(startOfDay) &&
              m.scheduledAt.isBefore(endOfDay),
        )
        .toList();
  }

  /// Get meetings in a date range
  List<MeetingModel> getMeetingsInRange(DateTime start, DateTime end) {
    return _meetings
        .where(
          (m) => m.scheduledAt.isAfter(start) && m.scheduledAt.isBefore(end),
        )
        .toList();
  }

  /// Get meetings by status
  List<MeetingModel> getMeetingsByStatus(String status) {
    return _meetings.where((m) => m.status == status).toList();
  }

  /// Mark meeting as completed
  Future<bool> completeMeeting(String meetingId) async {
    final meeting = _meetings.firstWhere((m) => m.id == meetingId);
    final updatedMeeting = meeting.copyWith(status: 'completed');
    return updateMeeting(updatedMeeting);
  }

  /// Search meetings
  List<MeetingModel> searchMeetings(String query) {
    return _meetings
        .where(
          (meeting) =>
              meeting.title.toLowerCase().contains(query.toLowerCase()) ||
              (meeting.description?.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
                  false),
        )
        .toList();
  }
}
