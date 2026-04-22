import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sales_manager/core/theme/app_theme.dart';
import 'package:sales_manager/core/models/lead_model.dart';
import 'package:sales_manager/core/models/meeting_model.dart';
import 'package:sales_manager/features/leads/providers/meetings_provider.dart';

class ScheduleMeetingScreen extends StatefulWidget {
  final LeadModel lead;

  const ScheduleMeetingScreen({super.key, required this.lead});

  @override
  State<ScheduleMeetingScreen> createState() => _ScheduleMeetingScreenState();
}

class _ScheduleMeetingScreenState extends State<ScheduleMeetingScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _attendeesController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  int _durationMinutes = 60;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: 'Meeting with ${widget.lead.company}',
    );
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    _attendeesController = TextEditingController(text: widget.lead.name);
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _attendeesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Meeting'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLeadInfo(),
            const SizedBox(height: AppTheme.spacingXl),
            _buildMeetingForm(),
            const SizedBox(height: AppTheme.spacingXl),
            _buildScheduleButton(),
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
            _buildInfoRow('Phone', widget.lead.phone),
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

  Widget _buildMeetingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meeting Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        _buildTextField(
          label: 'Meeting Title',
          controller: _titleController,
          hint: 'e.g., Initial Discussion',
        ),
        const SizedBox(height: AppTheme.spacingMd),
        _buildTextField(
          label: 'Description',
          controller: _descriptionController,
          hint: 'Add meeting notes or agenda',
          maxLines: 3,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        _buildTextField(
          label: 'Location',
          controller: _locationController,
          hint: 'e.g., Office, Video Call, Client Office',
        ),
        const SizedBox(height: AppTheme.spacingMd),
        _buildTextField(
          label: 'Attendees',
          controller: _attendeesController,
          hint: 'Names of attendees',
          maxLines: 2,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        _buildDateTimePicker(),
        const SizedBox(height: AppTheme.spacingMd),
        _buildDurationDropdown(),
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

  Widget _buildDateTimePicker() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date & Time',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(),
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Date',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            dateFormat.format(_selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: GestureDetector(
                onTap: () => _selectTime(),
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Time',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            timeFormat.format(
                              DateTime(
                                2024,
                                1,
                                1,
                                _selectedTime.hour,
                                _selectedTime.minute,
                              ),
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Duration',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        DropdownButtonFormField<int>(
          value: _durationMinutes,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingMd,
            ),
          ),
          items: [30, 60, 90, 120, 180].map((duration) {
            return DropdownMenuItem(
              value: duration,
              child: Text('${duration} minutes'),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _durationMinutes = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildScheduleButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _scheduleMeeting,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
          backgroundColor: AppTheme.primaryColor,
        ),
        child: const Text(
          'Schedule Meeting',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null) {
      setState(() => _selectedTime = pickedTime);
    }
  }

  void _scheduleMeeting() {
    final meetingsProvider = context.read<MeetingsProvider>();
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error: User not authenticated'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final scheduledDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final meeting = MeetingModel(
      id: '',
      title: _titleController.text,
      description: _descriptionController.text,
      scheduledAt: scheduledDateTime,
      duration: _durationMinutes,
      status: 'scheduled',
      relatedId: widget.lead.id,
      relatedType: 'lead',
      createdBy: currentUserId,
      assignedTo: currentUserId,
      createdAt: DateTime.now(),
    );

    meetingsProvider
        .addMeeting(meeting)
        .then((_) {
          // Refresh meetings list after adding
          meetingsProvider.fetchMeetings();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Meeting scheduled successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          Navigator.pop(context);
        })
        .catchError((e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error scheduling meeting: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        });
  }
}
