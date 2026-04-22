import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sales_manager/core/models/customer_model.dart';
import 'package:sales_manager/core/models/user_model.dart';
import 'package:sales_manager/core/models/lead_model.dart';
import 'package:sales_manager/core/constants/app_constants.dart';

class CustomersProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<CustomerModel> _customers = [];
  bool _isLoading = false;
  String? _error;

  List<CustomerModel> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CustomersProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchCustomers();
  }

  /// Fetch all customers from Supabase
  Future<void> fetchCustomers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from(AppConstants.customersTable)
          .select()
          .order('created_at', ascending: false);

      _customers = (response as List)
          .map((json) => CustomerModel.fromJson(json))
          .toList();

      print('✅ Loaded ${_customers.length} customers from Supabase');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load customers: $e';
      print('❌ Error fetching customers: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get visible customers based on user role
  List<CustomerModel> getVisibleCustomers(UserModel currentUser) {
    if (currentUser.role == 'admin') {
      return _customers;
    } else if (currentUser.role == 'manager') {
      // Managers see customers created by themselves or their team
      return _customers.where((c) => c.createdBy == currentUser.id).toList();
    } else {
      // Salespeople see only their customers
      return _customers.where((c) => c.createdBy == currentUser.id).toList();
    }
  }

  /// Add new customer to Supabase
  Future<bool> addCustomer(CustomerModel customer) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final customerData = {
        'name': customer.name,
        'email': customer.email,
        'phone': customer.phone,
        'company': customer.company,
        'created_by': customer.createdBy,
        'lead_id': customer.leadId,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from(AppConstants.customersTable)
          .insert(customerData)
          .select()
          .single();

      final newCustomer = CustomerModel.fromJson(response);
      _customers.insert(0, newCustomer);
      _isLoading = false;
      notifyListeners();
      print('✅ Customer added: ${customer.name}');
      return true;
    } catch (e) {
      _error = 'Failed to add customer: $e';
      print('❌ Error adding customer: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update customer in Supabase
  Future<bool> updateCustomer(CustomerModel customer) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final customerData = {
        'name': customer.name,
        'email': customer.email,
        'phone': customer.phone,
        'company': customer.company,
      };

      await _supabase
          .from(AppConstants.customersTable)
          .update(customerData)
          .eq('id', customer.id);

      final index = _customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _customers[index] = customer;
      }

      _isLoading = false;
      notifyListeners();
      print('✅ Customer updated: ${customer.name}');
      return true;
    } catch (e) {
      _error = 'Failed to update customer: $e';
      print('❌ Error updating customer: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete customer from Supabase
  Future<bool> deleteCustomer(String customerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase
          .from(AppConstants.customersTable)
          .delete()
          .eq('id', customerId);

      _customers.removeWhere((c) => c.id == customerId);
      _isLoading = false;
      notifyListeners();
      print('✅ Customer deleted: $customerId');
      return true;
    } catch (e) {
      _error = 'Failed to delete customer: $e';
      print('❌ Error deleting customer: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Create customer from a won lead
  Future<bool> createCustomerFromLead(LeadModel lead, String userId) async {
    final customer = CustomerModel(
      id: '',
      name: lead.name,
      email: lead.email,
      phone: lead.phone,
      company: lead.company,
      createdBy: userId,
      leadId: lead.id,
      createdAt: DateTime.now(),
    );

    return addCustomer(customer);
  }

  /// Get customers created by a specific user
  List<CustomerModel> getCustomersForUser(String userId) {
    return _customers.where((c) => c.createdBy == userId).toList();
  }

  /// Get customer by lead ID
  CustomerModel? getCustomerByLeadId(String leadId) {
    try {
      return _customers.firstWhere((c) => c.leadId == leadId);
    } catch (e) {
      return null;
    }
  }

  /// Search customers
  List<CustomerModel> searchCustomers(String query) {
    return _customers
        .where(
          (customer) =>
              customer.name.toLowerCase().contains(query.toLowerCase()) ||
              customer.email.toLowerCase().contains(query.toLowerCase()) ||
              (customer.company?.toLowerCase().contains(query.toLowerCase()) ??
                  false) ||
              customer.phone.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  /// Get customer by ID
  CustomerModel? getCustomerById(String customerId) {
    try {
      return _customers.firstWhere((c) => c.id == customerId);
    } catch (e) {
      return null;
    }
  }

  /// Get customers for a company
  List<CustomerModel> getCustomersForCompany(String company) {
    return _customers
        .where((c) => (c.company?.toLowerCase() ?? '') == company.toLowerCase())
        .toList();
  }
}
