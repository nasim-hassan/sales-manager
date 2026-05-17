import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sales_manager/core/services/supabase_service.dart';
import 'package:sales_manager/core/theme/app_theme.dart';
import 'package:sales_manager/core/models/lead_model.dart';
import 'package:sales_manager/core/models/proposal_model.dart';
import 'package:sales_manager/features/leads/providers/proposals_provider.dart';

class SendProposalScreen extends StatefulWidget {
  final LeadModel lead;

  const SendProposalScreen({super.key, required this.lead});

  @override
  State<SendProposalScreen> createState() => _SendProposalScreenState();
}

class _SendProposalScreenState extends State<SendProposalScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late DateTime _validUntil;
  String _selectedStatus = 'draft';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: '${widget.lead.company} - Proposal',
    );
    _descriptionController = TextEditingController();
    _amountController = TextEditingController(
      text: widget.lead.value.toStringAsFixed(2),
    );
    _validUntil = DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Proposal'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLeadInfo(),
            const SizedBox(height: AppTheme.spacingXl),
            _buildProposalForm(),
            const SizedBox(height: AppTheme.spacingXl),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lead Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildInfoRow('Company', widget.lead.company),
            _buildInfoRow('Contact', widget.lead.name),
            _buildInfoRow('Email', widget.lead.email),
            _buildInfoRow('Stage', widget.lead.stage),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Proposal Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        _buildTextField(
          label: 'Proposal Title',
          controller: _titleController,
          hint: 'e.g., Web Development Services',
        ),
        const SizedBox(height: AppTheme.spacingMd),
        _buildTextField(
          label: 'Description',
          controller: _descriptionController,
          hint: 'Proposal details and scope of work',
          maxLines: 4,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Proposal Amount',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '0.00',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.all(AppTheme.spacingMd),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                        vertical: AppTheme.spacingMd,
                      ),
                    ),
                    items: ['draft', 'sent', 'accepted', 'rejected'].map((
                      status,
                    ) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(_capitalizeStatus(status)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedStatus = value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMd),
        _buildValidUntilPicker(),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.all(AppTheme.spacingMd),
          ),
          maxLines: maxLines,
        ),
      ],
    );
  }

  Widget _buildValidUntilPicker() {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Valid Until',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        GestureDetector(
          onTap: () => _selectValidUntilDate(),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Expires on',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        dateFormat.format(_validUntil),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _sendProposal,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
          backgroundColor: AppTheme.primaryColor,
        ),
        child: const Text(
          'Send Proposal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _selectValidUntilDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _validUntil,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() => _validUntil = pickedDate);
    }
  }

  void _sendProposal() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final proposalsProvider = context.read<ProposalsProvider>();
    final currentUserId = SupabaseService().auth.currentUser?.id;

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: User not authenticated'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final proposal = ProposalModel(
      id: '',
      title: _titleController.text,
      description: _descriptionController.text,
      leadId: widget.lead.id,
      amount: double.parse(_amountController.text),
      status: _selectedStatus,
      validUntil: _validUntil,
      createdBy: currentUserId,
      assignedTo: currentUserId,
      createdAt: DateTime.now(),
    );

    proposalsProvider
        .addProposal(proposal)
        .then((createdProposal) async {
          if (createdProposal == null) {
            throw Exception('Failed to create proposal');
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Proposal "${_titleController.text}" saved successfully!',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          Navigator.pop(context);
        })
        .catchError((e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving proposal: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        });
  }

  String _capitalizeStatus(String status) {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'sent':
        return 'Sent';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }
}

class DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.borderColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 5;
    const dashSpace = 3;
    double startX = 0;

    // Top border
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }

    // Right border
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width, startY),
        Offset(size.width, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }

    // Bottom border
    startX = size.width;
    while (startX > 0) {
      canvas.drawLine(
        Offset(startX, size.height),
        Offset(startX - dashWidth, size.height),
        paint,
      );
      startX -= dashWidth + dashSpace;
    }

    // Left border
    startY = size.height;
    while (startY > 0) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY - dashWidth), paint);
      startY -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(DottedBorderPainter oldDelegate) => false;
}
