import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportsProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  ReportsProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();
    _isLoading = false;
    notifyListeners();
  }

  // Dashboard Summary
  Future<Map<String, dynamic>> getDashboardSummary(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Fetch leads
      final leadsResponse = await _supabase
          .from('leads')
          .select('COUNT(*) as count, value')
          .eq('assigned_to', userId);

      // Fetch customers
      final customersResponse = await _supabase
          .from('customers')
          .select('COUNT(*) as count')
          .eq('created_by', userId);

      // Fetch meetings
      final meetingsResponse = await _supabase
          .from('meetings')
          .select()
          .eq('assigned_to', userId)
          .gt('scheduled_at', DateTime.now().toIso8601String());

      _isLoading = false;
      notifyListeners();

      return {
        'totalLeads': leadsResponse.isNotEmpty
            ? leadsResponse[0]['count'] ?? 0
            : 0,
        'totalCustomers': customersResponse.isNotEmpty
            ? customersResponse[0]['count'] ?? 0
            : 0,
        'totalMeetings': meetingsResponse.isNotEmpty
            ? meetingsResponse.length
            : 0,
        'leadsValue': 0,
        'upcomingMeetings': meetingsResponse.length,
      };
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return {};
    }
  }

  // Lead Performance Report
  Future<Map<String, dynamic>> getLeadPerformanceReport(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase
          .from('leads')
          .select('stage, value, COUNT(*) as count')
          .eq('assigned_to', userId);

      final stageBreakdown = <String, int>{};
      final stageValue = <String, double>{};
      double totalValue = 0;

      for (var item in response) {
        stageBreakdown[item['stage']] = item['count'] ?? 0;
        stageValue[item['stage']] = (item['value'] ?? 0).toDouble();
        totalValue += (item['value'] ?? 0).toDouble();
      }

      _isLoading = false;
      notifyListeners();

      return {
        'totalLeads': response.length,
        'totalValue': totalValue,
        'stageBreakdown': stageBreakdown,
        'stageValue': stageValue,
        'averageLeadValue': response.isNotEmpty
            ? totalValue / response.length
            : 0,
      };
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return {};
    }
  }

  // Sales Pipeline Report
  Future<Map<String, dynamic>> getSalesPipelineReport(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase
          .from('leads')
          .select('*')
          .eq('assigned_to', userId);

      final pipeline = <String, List<Map<String, dynamic>>>{};

      for (var lead in response) {
        final stage = lead['stage'];
        if (!pipeline.containsKey(stage)) {
          pipeline[stage] = [];
        }
        pipeline[stage]!.add(lead);
      }

      _isLoading = false;
      notifyListeners();

      return {
        'pipeline': pipeline,
        'totalStages': pipeline.length,
        'largestStage': pipeline.isNotEmpty
            ? pipeline.entries
                  .reduce((a, b) => a.value.length > b.value.length ? a : b)
                  .key
            : 'N/A',
      };
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return {};
    }
  }

  // Customer Report
  Future<Map<String, dynamic>> getCustomerReport(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase
          .from('customers')
          .select('COUNT(*) as count')
          .eq('created_by', userId);

      _isLoading = false;
      notifyListeners();

      return {
        'totalCustomers': response.isNotEmpty ? response[0]['count'] ?? 0 : 0,
      };
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return {};
    }
  }

  // Sales Performance by User (Admin only)
  Future<Map<String, dynamic>> getSalesPerformanceByUser() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final usersResponse = await _supabase.from('users').select();
      final leadsResponse = await _supabase.from('leads').select();

      final userPerformance = <String, Map<String, dynamic>>{};

      for (var user in usersResponse) {
        final userLeads = leadsResponse
            .where((l) => l['assigned_to'] == user['id'])
            .toList();
        userPerformance[user['name']] = {
          'leadsCount': userLeads.length,
          'closedWonCount': userLeads
              .where((l) => l['stage'] == 'Closed Won')
              .length,
          'totalValue': userLeads.fold(
            0.0,
            (sum, lead) => sum + (lead['value'] ?? 0).toDouble(),
          ),
        };
      }

      _isLoading = false;
      notifyListeners();

      return {'userPerformance': userPerformance};
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return {};
    }
  }
}
