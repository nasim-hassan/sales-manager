import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_manager/core/theme/app_theme.dart';
import 'package:sales_manager/core/constants/app_constants.dart';
import 'package:sales_manager/core/services/sync_service.dart';
import 'package:sales_manager/features/auth/providers/auth_provider.dart';
import 'package:sales_manager/features/admin/providers/user_management_provider.dart';
import 'package:sales_manager/features/admin/providers/users_provider.dart';
import 'package:sales_manager/features/leads/providers/leads_provider.dart';
import 'package:sales_manager/features/leads/providers/proposals_provider.dart';
import 'package:sales_manager/features/leads/providers/meetings_provider.dart';
import 'package:sales_manager/features/customers/providers/customers_provider.dart';
import 'package:sales_manager/features/calendar/providers/calendar_provider.dart';
import 'package:sales_manager/features/reports/providers/reports_provider.dart';
import 'package:sales_manager/features/dashboard/providers/notifications_provider.dart';
import 'package:sales_manager/features/auth/screens/login_screen.dart';
import 'package:sales_manager/features/dashboard/screens/home_screen.dart';

// Development flag - Set to true to skip login and use mock data
const bool _developmentMode = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
