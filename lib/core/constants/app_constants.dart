class AppConstants {
  // App Info
  static const String appName = 'Sales Manager';
  static const String appVersion = '1.0.0';

  // Default Admin - Set up via Supabase Auth & Admin panel
  static const String defaultAdminEmail = 'nasimhassannahid@gmail.com';

  // Supabase Config (REPLACE WITH YOUR ACTUAL CREDENTIALS)
  static const String supabaseUrl = 'https://vmavqknhtkdxexqlofrw.supabase.co';
  static const String supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZtYXZxa25odGtkeGV4cWxvZnJ3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgwMjMzMDMsImV4cCI6MjA4MzU5OTMwM30.bhvqIKgAlCDl_Ch-xM9MOWFCgFeWcQ53OiakAOE7A54';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration syncInterval = Duration(minutes: 5);

  // Database Tables
  static const String usersTable = 'users';
  static const String leadsTable = 'leads';
  static const String proposalsTable = 'proposals';
  static const String customersTable = 'customers';
  static const String meetingsTable = 'meetings';
  static const String notificationsTable = 'notifications';
  static const String dealsTable = 'deals';

  // Pipeline Stages
  static const List<String> pipelineStages = [
    'New',
    'Contacted',
    'Qualified',
    'Proposal',
    'Negotiation',
    'Closed Won',
    'Closed Lost',
  ];

  // Error Messages
  static const String loginError = 'Failed to login. Please try again.';
  static const String registrationError =
      'Failed to register. Please try again.';
  static const String networkError =
      'Network error. Please check your connection.';
  static const String unknownError = 'An unexpected error occurred.';
  static const String noDataError = 'No data available.';
}
