import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_manager/core/models/lead_model.dart';
import 'package:sales_manager/features/leads/providers/leads_provider.dart';
import 'package:sales_manager/features/leads/screens/schedule_meeting_screen.dart';
import 'package:sales_manager/features/leads/screens/send_proposal_screen.dart';

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
    // Set default to empty for simplicity (no user system)
    _selectedAssignedTo = widget.lead?.assignedTo ?? '';
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
    final value = double.tryParse(_valueController.text) ?? 0;

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
        createdBy: 'system',
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.person, color: Colors.blue, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lead Created By',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  widget.lead?.createdBy ?? 'System',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
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
                  'Assignment',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  _selectedAssignedTo.isEmpty ? 'Unassigned' : _selectedAssignedTo,
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
  }
}
