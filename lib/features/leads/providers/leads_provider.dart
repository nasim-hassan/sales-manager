import 'package:flutter/material.dart';
import 'package:sales_manager/core/models/lead_model.dart';
import 'package:sales_manager/core/models/user_model.dart';
import 'package:sales_manager/core/constants/app_constants.dart';
import 'package:sales_manager/core/services/supabase_service.dart';

class LeadsProvider extends ChangeNotifier {
  final _supabaseService = SupabaseService();
  final _supabase = SupabaseService();

  List<LeadModel> _leads = [];
  bool _isLoading = false;
  String? _error;

  // Callback when a lead is won (for auto-customer creation)
  Function(LeadModel)? onLeadWon;

  List<LeadModel> get leads => _leads;
  bool get isLoading => _isLoading;
  String? get error => _error;

  LeadsProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchLeads();
  }

  /// Fetch all leads from Supabase
  Future<void> fetchLeads() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from(AppConstants.leadsTable)
          .select()
          .order('created_at', ascending: false);

      _leads = (response as List)
          .map((json) => LeadModel.fromJson(json))
          .toList();

      print('✅ Loaded ${_leads.length} leads from Supabase');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load leads: $e';
      print('❌ Error fetching leads: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get visible leads based on user role and team
  List<LeadModel> getVisibleLeads(UserModel currentUser) {
    if (currentUser.role == 'admin') {
      return _leads;
    } else if (currentUser.role == 'manager') {
      // Managers see their own leads and team leads
      return _leads
          .where(
            (lead) =>
                lead.assignedTo == currentUser.id ||
                lead.createdBy == currentUser.id,
          )
          .toList();
    } else {
      // Salespeople see only their assigned leads
      return _leads.where((lead) => lead.assignedTo == currentUser.id).toList();
    }
  }

  /// Add new lead to Supabase
  Future<bool> addLead(LeadModel lead) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final leadData = {
        'name': lead.name,
        'email': lead.email,
        'phone': lead.phone,
        'company': lead.company,
        'stage': lead.stage,
        'value': lead.value,
        'notes': lead.notes,
        'assigned_to': lead.assignedTo,
        'created_by': lead.createdBy,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from(AppConstants.leadsTable)
          .insert(leadData)
          .select()
          .single();

      final newLead = LeadModel.fromJson(response);
      _leads.insert(0, newLead);
      _isLoading = false;
      notifyListeners();
      print('✅ Lead added: ${lead.name}');
      return true;
    } catch (e) {
      _error = 'Failed to add lead: $e';
      print('❌ Error adding lead: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update lead in Supabase
  Future<bool> updateLead(LeadModel lead) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final leadData = {
        'name': lead.name,
        'email': lead.email,
        'phone': lead.phone,
        'company': lead.company,
        'stage': lead.stage,
        'value': lead.value,
        'notes': lead.notes,
        'assigned_to': lead.assignedTo,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from(AppConstants.leadsTable)
          .update(leadData)
          .eq('id', lead.id);

      final index = _leads.indexWhere((l) => l.id == lead.id);
      if (index != -1) {
        final oldLead = _leads[index];
        _leads[index] = lead;

        // Check if lead stage changed to "Closed Won"
        if (oldLead.stage != 'Closed Won' && lead.stage == 'Closed Won') {
          _onLeadWon(lead);
        }
      }

      _isLoading = false;
      notifyListeners();
      print('✅ Lead updated: ${lead.name}');
      return true;
    } catch (e) {
      _error = 'Failed to update lead: $e';
      print('❌ Error updating lead: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete lead from Supabase
  Future<bool> deleteLead(String leadId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabaseService.from(AppConstants.leadsTable).delete().eq('id', leadId);

      _leads.removeWhere((l) => l.id == leadId);
      _isLoading = false;
      notifyListeners();
      print('✅ Lead deleted: $leadId');
      return true;
    } catch (e) {
      _error = 'Failed to delete lead: $e';
      print('❌ Error deleting lead: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get leads by stage
  List<LeadModel> getLeadsByStage(String stage) {
    return _leads.where((l) => l.stage == stage).toList();
  }

  /// Search leads
  List<LeadModel> searchLeads(String query) {
    return _leads
        .where(
          (lead) =>
              lead.name.toLowerCase().contains(query.toLowerCase()) ||
              lead.email.toLowerCase().contains(query.toLowerCase()) ||
              lead.company.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  /// Get lead by ID
  LeadModel? getLeadById(String leadId) {
    try {
      return _leads.firstWhere((l) => l.id == leadId);
    } catch (e) {
      return null;
    }
  }

  /// Get leads for a specific person
  List<LeadModel> getLeadsForUser(String userId) {
    return _leads.where((l) => l.assignedTo == userId).toList();
  }

  void _onLeadWon(LeadModel lead) {
    if (onLeadWon != null) {
      onLeadWon!(lead);
    }
  }

  /// Check if manager can assign lead to a user
  bool canAssignLead(
    UserModel manager,
    String targetUserId,
    List<UserModel> allUsers,
  ) {
    if (manager.role != 'manager') return false;

    final targetUser = allUsers.firstWhere(
      (u) => u.id == targetUserId,
      orElse: () => UserModel(
        id: '',
        email: '',
        name: '',
        phone: '',
        role: '',
        isActive: true,
        createdAt: DateTime.now(),
      ),
    );

    // Can only assign to themselves or their team
    return targetUserId == manager.id ||
        targetUser.reportingManager == manager.id;
  }
}
