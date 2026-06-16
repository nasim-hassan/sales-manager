import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:customer_relationship_management/core/models/proposal_model.dart';
import 'package:customer_relationship_management/core/models/user_model.dart';
import 'package:customer_relationship_management/core/constants/app_constants.dart';

class ProposalsProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<ProposalModel> _proposals = [];
  bool _isLoading = false;
  String? _error;

  List<ProposalModel> get proposals => _proposals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProposalsProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchProposals();
  }

  /// Fetch all proposals from Supabase
  Future<void> fetchProposals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from(AppConstants.proposalsTable)
          .select()
          .order('created_at', ascending: false);

      _proposals = (response as List)
          .map((json) => ProposalModel.fromJson(json))
          .toList();

      print('✅ Loaded ${_proposals.length} proposals from Supabase');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load proposals: $e';
      print('❌ Error fetching proposals: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get visible proposals based on user role
  List<ProposalModel> getVisibleProposals(UserModel currentUser) {
    if (currentUser.role == 'admin') {
      return _proposals;
    } else if (currentUser.role == 'manager') {
      // Managers see proposals they created or assigned to them
      return _proposals
          .where(
            (p) =>
                p.createdBy == currentUser.id || p.assignedTo == currentUser.id,
          )
          .toList();
    } else {
      // Salespeople see only their assigned proposals
      return _proposals.where((p) => p.assignedTo == currentUser.id).toList();
    }
  }

  /// Add new proposal to Supabase
  Future<ProposalModel?> addProposal(ProposalModel proposal) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final proposalData = {
        'lead_id': proposal.leadId,
        'title': proposal.title,
        'description': proposal.description,
        'amount': proposal.amount,
        'status': proposal.status,
        'valid_until': proposal.validUntil.toIso8601String(),
        'assigned_to': proposal.assignedTo,
        'created_by': proposal.createdBy,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from(AppConstants.proposalsTable)
          .insert(proposalData)
          .select()
          .single();

      final newProposal = ProposalModel.fromJson(response);
      _proposals.insert(0, newProposal);
      _isLoading = false;
      notifyListeners();
      print('✅ Proposal added: ${proposal.title}');
      return newProposal;
    } catch (e) {
      _error = 'Failed to add proposal: $e';
      print('❌ Error adding proposal: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update proposal in Supabase
  Future<bool> updateProposal(ProposalModel proposal) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final proposalData = {
        'title': proposal.title,
        'description': proposal.description,
        'amount': proposal.amount,
        'status': proposal.status,
        'valid_until': proposal.validUntil.toIso8601String(),
        'assigned_to': proposal.assignedTo,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from(AppConstants.proposalsTable)
          .update(proposalData)
          .eq('id', proposal.id);

      final index = _proposals.indexWhere((p) => p.id == proposal.id);
      if (index != -1) {
        _proposals[index] = proposal;
      }

      _isLoading = false;
      notifyListeners();
      print('✅ Proposal updated: ${proposal.title}');
      return true;
    } catch (e) {
      _error = 'Failed to update proposal: $e';
      print('❌ Error updating proposal: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete proposal from Supabase
  Future<bool> deleteProposal(String proposalId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase
          .from(AppConstants.proposalsTable)
          .delete()
          .eq('id', proposalId);

      _proposals.removeWhere((p) => p.id == proposalId);
      _isLoading = false;
      notifyListeners();
      print('✅ Proposal deleted: $proposalId');
      return true;
    } catch (e) {
      _error = 'Failed to delete proposal: $e';
      print('❌ Error deleting proposal: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get proposals for a specific lead
  List<ProposalModel> getProposalsForLead(String leadId) {
    return _proposals.where((p) => p.leadId == leadId).toList();
  }

  /// Get proposals by status
  List<ProposalModel> getProposalsByStatus(String status) {
    return _proposals.where((p) => p.status == status).toList();
  }

  /// Get proposals created by user
  List<ProposalModel> getProposalsByUser(String userId) {
    return _proposals.where((p) => p.createdBy == userId).toList();
  }

  /// Calculate total proposal value
  double calculateTotalValue(List<ProposalModel> proposalsList) {
    return proposalsList.fold(0, (sum, p) => sum + p.amount);
  }

  /// Get the highest value proposal
  ProposalModel? getHighestValueProposal() {
    if (_proposals.isEmpty) return null;
    return _proposals.reduce((a, b) => a.amount > b.amount ? a : b);
  }

  /// Search proposals
  List<ProposalModel> searchProposals(String query) {
    return _proposals
        .where(
          (proposal) =>
              proposal.title.toLowerCase().contains(query.toLowerCase()) ||
              proposal.description.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
