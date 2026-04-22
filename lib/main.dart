import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sales_manager/core/theme/app_theme.dart';
import 'package:sales_manager/core/constants/app_constants.dart';
import 'package:sales_manager/core/services/sync_service.dart';
import 'package:sales_manager/features/leads/providers/leads_provider.dart';
import 'package:sales_manager/features/leads/providers/proposals_provider.dart';
import 'package:sales_manager/features/leads/providers/meetings_provider.dart';
import 'package:sales_manager/features/customers/providers/customers_provider.dart';
import 'package:sales_manager/features/dashboard/providers/notifications_provider.dart';
import 'package:sales_manager/features/dashboard/screens/home_screen.dart';

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
        ChangeNotifierProvider(create: (_) => LeadsProvider()),
        ChangeNotifierProvider(create: (_) => ProposalsProvider()),
        ChangeNotifierProvider(create: (_) => MeetingsProvider()),
        ChangeNotifierProvider(create: (_) => CustomersProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}
