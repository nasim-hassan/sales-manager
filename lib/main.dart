import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:customer_relationship_management/core/theme/app_theme.dart';
import 'package:customer_relationship_management/core/constants/app_constants.dart';
import 'package:customer_relationship_management/core/services/sync_service.dart';
import 'package:customer_relationship_management/features/auth/providers/auth_provider.dart';
import 'package:customer_relationship_management/features/admin/providers/user_management_provider.dart';
import 'package:customer_relationship_management/features/admin/providers/users_provider.dart';
import 'package:customer_relationship_management/features/leads/providers/leads_provider.dart';
import 'package:customer_relationship_management/features/leads/providers/proposals_provider.dart';
import 'package:customer_relationship_management/features/leads/providers/meetings_provider.dart';
import 'package:customer_relationship_management/features/customers/providers/customers_provider.dart';
import 'package:customer_relationship_management/features/calendar/providers/calendar_provider.dart';
import 'package:customer_relationship_management/features/reports/providers/reports_provider.dart';
import 'package:customer_relationship_management/features/dashboard/providers/notifications_provider.dart';
import 'package:customer_relationship_management/features/auth/screens/login_screen.dart';
import 'package:customer_relationship_management/features/dashboard/screens/home_screen.dart';

// Development flag - Set to false for production
const bool _developmentMode = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseKey,
  );

  // Initialize services
  await SyncService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => UserManagementProvider()),
        ChangeNotifierProvider(create: (_) => UsersProvider()),
        ChangeNotifierProvider(create: (_) => LeadsProvider()),
        ChangeNotifierProvider(create: (_) => ProposalsProvider()),
        ChangeNotifierProvider(create: (_) => MeetingsProvider()),
        ChangeNotifierProvider(create: (_) => CustomersProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme(),
        home: _developmentMode
            ? const HomeScreen() // Bypass auth in development
            : Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  // Only go to home if user is actually logged in
                  if (authProvider.isLoggedIn) {
                    return const HomeScreen();
                  }
                  return const LoginScreen();
                },
              ),
      ),
    );
  }
}
