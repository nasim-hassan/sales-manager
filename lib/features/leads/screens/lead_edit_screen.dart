import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_manager/core/models/lead_model.dart';
import 'package:sales_manager/features/leads/providers/leads_provider.dart';
import 'package:sales_manager/features/leads/screens/schedule_meeting_screen.dart';
import 'package:sales_manager/features/leads/screens/send_proposal_screen.dart';
import 'package:sales_manager/features/auth/providers/auth_provider.dart';
import 'package:sales_manager/features/admin/providers/users_provider.dart';

class LeadEditScreen extends StatefulWidget {
  final LeadModel? lead;

  const LeadEditScreen({super.key, this.lead});

  @override
  State<LeadEditScreen> createState() => _LeadEditScreenState();
}

class _LeadEditScreenState extends State<LeadEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _companyController;
  late TextEditingController _valueController;
  late TextEditingController _notesController;

  late String _selectedStage;
  late String _selectedAssignedTo;
  final _formKey = GlobalKey<FormState>();

  final List<String> _stages = [
    'New',
    'Contacted',
    'Qualified',
    'Proposal',
    'Negotiation',
    'Closed Won',
    'Closed Lost',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.lead?.name ?? '');
    _emailController = TextEditingController(text: widget.lead?.email ?? '');
    _phoneController = TextEditingController(text: widget.lead?.phone ?? '');
    _companyController = TextEditingController(
      text: widget.lead?.company ?? '',
    );
    _valueController = TextEditingController(
      text: widget.lead?.value.toString() ?? '',
    );
    _notesController = TextEditingController(text: widget.lead?.notes ?? '');
    _selectedStage = widget.lead?.stage ?? 'New';
    // Default to current user if creating new lead
    final authProvider = context.read<AuthProvider>();
    _selectedAssignedTo =
        widget.lead?.assignedTo ?? authProvider.currentUser?.id ?? '';

    // Fetch users to populate assignment dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final usersProvider = context.read<UsersProvider>();
      usersProvider.fetchUsers();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveLead() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final leadsProvider = context.read<LeadsProvider>();
    final authProvider = context.read<AuthProvider>();
    final value = double.tryParse(_valueController.text) ?? 0;
    final currentUserId = authProvider.currentUser?.id ?? 'admin';

    if (widget.lead == null) {
      // Create new lead
      final newLead = LeadModel(
        id: '',
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        company: _companyController.text,
        stage: _selectedStage,
        assignedTo: _selectedAssignedTo,
        createdBy: currentUserId,
        value: value,
        notes: _notesController.text,
        createdAt: DateTime.now(),
      );
      leadsProvider.addLead(newLead);
    } else {
      // Update existing lead
      final updatedLead = LeadModel(
        id: widget.lead!.id,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        company: _companyController.text,
        stage: _selectedStage,
        assignedTo: widget.lead!.assignedTo,
        createdBy: widget.lead!.createdBy,
        value: value,
        notes: _notesController.text,
        createdAt: widget.lead!.createdAt,
      );
      leadsProvider.updateLead(updatedLead);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.lead == null ? 'Lead created' : 'Lead updated'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lead == null ? 'Create Lead' : 'Edit Lead'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Lead Name',
                  hintText: 'Enter lead name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lead name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter email address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  hintText: 'Enter phone number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Company
              TextFormField(
                controller: _companyController,
                decoration: InputDecoration(
                  labelText: 'Company',
                  hintText: 'Enter company name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Company is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Stage Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedStage,
                decoration: InputDecoration(
                  labelText: 'Stage',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.flag),
                ),
                items: _stages
                    .map(
                      (stage) =>
                          DropdownMenuItem(value: stage, child: Text(stage)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStage = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Assign To Dropdown (Only for new leads)
              if (widget.lead == null)
                Consumer<UsersProvider>(
                  builder: (context, usersProvider, _) {
                    final users = usersProvider.users;

                    print(
                      '🔍 [Lead Assignment] Total users loaded: ${users.length}',
                    );
                    for (var user in users) {
                      print('   - ${user.name} (${user.role})');
                    }

                    if (users.isEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: Colors.orange.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'No users available. Please create users first.',
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    // Group users by role
                    final Map<String, List<dynamic>> groupedUsers = {};
                    for (var user in users) {
                      if (!groupedUsers.containsKey(user.role)) {
                        groupedUsers[user.role] = [];
                      }
                      groupedUsers[user.role]!.add(user);
                    }

                    // Build dropdown items with parent-child structure
                    final items = <DropdownMenuItem<String>>[];
                    for (var role in groupedUsers.keys) {
                      // Add role header (parent)
                      items.add(
                        DropdownMenuItem<String>(
                          enabled: false,
                          value: '',
                          child: Text(
                            role.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );

                      // Add users under this role (children with indentation)
                      for (var user in groupedUsers[role]!) {
                        items.add(
                          DropdownMenuItem<String>(
                            value: user.id,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 24.0),
                              child: Text(user.name),
                            ),
                          ),
                        );
                      }
                    }

                    return DropdownButtonFormField<String>(
                      value: _selectedAssignedTo,
                      decoration: InputDecoration(
                        labelText: 'Assign To',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person_add),
                      ),
                      items: items,
                      onChanged: (value) {
                        if (value != null && value.isNotEmpty) {
                          setState(() {
                            _selectedAssignedTo = value;
                          });
                        }
                      },
                    );
                  },
                ),
              const SizedBox(height: 16),

              // Lead Value
              TextFormField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Lead Value (\$)',
                  hintText: 'Enter lead value',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.monetization_on),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Add any additional notes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // Assignment Info - Show for all (editing shows creator info, creating shows assigned user)
              if (widget.lead != null)
                _buildAssignmentInfoCard()
              else
                _buildNewLeadAssignmentCard(),
              const SizedBox(height: 16),

              // Action Buttons - Schedule Meeting & Send Proposal
              if (widget.lead != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ScheduleMeetingScreen(lead: widget.lead!),
                            ),
                          );
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Schedule Meeting'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SendProposalScreen(lead: widget.lead!),
                            ),
                          );
                        },
                        icon: const Icon(Icons.description),
                        label: const Text('Send Proposal'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _saveLead,
                  icon: const Icon(Icons.save),
                  label: Text(
                    widget.lead == null ? 'Create Lead' : 'Update Lead',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentInfoCard() {
    final authProvider = context.read<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id;
    final isCreatedByCurrentUser = widget.lead?.createdBy == currentUserId;
    final assignmentLabel = isCreatedByCurrentUser
        ? 'Self Assigned'
        : 'Manager/Admin Assigned';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isCreatedByCurrentUser
                  ? Icons.person
                  : Icons.admin_panel_settings,
              color: isCreatedByCurrentUser ? Colors.blue : Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lead Created By',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  assignmentLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCreatedByCurrentUser ? Colors.blue : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewLeadAssignmentCard() {
    return Consumer<UsersProvider>(
      builder: (context, usersProvider, _) {
        final assignedUser = usersProvider.users
            .where((u) => u.id == _selectedAssignedTo)
            .firstOrNull;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.person_add, color: Colors.green, size: 20),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assigned To',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      assignedUser?.name ?? 'Select User',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
