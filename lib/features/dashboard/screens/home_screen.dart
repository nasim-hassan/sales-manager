import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_manager/core/theme/app_theme.dart';
import 'package:sales_manager/features/auth/providers/auth_provider.dart';
import 'package:sales_manager/features/admin/screens/users_screen.dart';
import 'package:sales_manager/features/leads/screens/leads_screen.dart';
import 'package:sales_manager/features/leads/screens/proposals_screen.dart';
import 'package:sales_manager/features/leads/screens/meetings_screen.dart';
import 'package:sales_manager/features/leads/providers/leads_provider.dart';
import 'package:sales_manager/features/leads/providers/proposals_provider.dart';
import 'package:sales_manager/features/customers/screens/customers_screen.dart';
import 'package:sales_manager/features/calendar/screens/calendar_screen.dart';
import 'package:sales_manager/features/reports/screens/reports_screen.dart';
import 'package:sales_manager/features/dashboard/screens/notifications_screen.dart';
import 'package:sales_manager/features/dashboard/providers/notifications_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRM Dashboard'),
        elevation: 0,
        actions: [
          Consumer<NotificationsProvider>(
            builder: (context, notificationsProvider, _) {
              final unreadCount = notificationsProvider.unreadCount;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Center(
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return Text(
                    authProvider.currentUser?.name ?? 'User',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      '${authProvider.currentUser?.name} (${authProvider.currentUser?.role})',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppTheme.spacingXl),
            const Text(
              'Key Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Consumer<LeadsProvider>(
              builder: (buildContext, leadsProvider, _) {
                return Consumer<ProposalsProvider>(
                  builder: (buildContext, proposalsProvider, _) {
                    return _buildStatisticsGrid(
                      buildContext,
                      leadsProvider,
                      proposalsProvider,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: AppTheme.spacingXl),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildQuickActionsGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid(
    BuildContext context,
    LeadsProvider leadsProvider,
    ProposalsProvider proposalsProvider,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatisticCard(
            title: 'Leads',
            count: leadsProvider.leads.length.toString(),
            icon: Icons.trending_up,
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeadsScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: _buildStatisticCard(
            title: 'Proposals',
            count: proposalsProvider.proposals.length.toString(),
            icon: Icons.description,
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProposalsScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.people,
                title: 'Leads',
                subtitle: 'Manage leads',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LeadsScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.person,
                title: 'Customers',
                subtitle: 'View customers',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CustomersScreen()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.description,
                title: 'Proposals',
                subtitle: 'Manage proposals',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProposalsScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.event_note,
                title: 'Meetings',
                subtitle: 'View meetings',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MeetingsScreen()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.calendar_today,
                title: 'Calendar',
                subtitle: 'Schedule events',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CalendarScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.show_chart,
                title: 'Reports',
                subtitle: 'View reports',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReportsScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: AppTheme.primaryColor),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return DrawerHeader(
                decoration: const BoxDecoration(color: AppTheme.primaryColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Icon(Icons.person, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    Text(
                      authProvider.currentUser?.name ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      authProvider.currentUser?.email ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.people,
            title: 'Leads',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeadsScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person,
            title: 'Customers',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomersScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.event,
            title: 'Meetings',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MeetingsScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.calendar_today,
            title: 'Calendar',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalendarScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.description,
            title: 'Proposals',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProposalsScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.show_chart,
            title: 'Reports',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportsScreen()),
              );
            },
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              if (authProvider.currentUser?.role == 'admin' ||
                  authProvider.currentUser?.role == 'manager') {
                return _buildDrawerItem(
                  context,
                  icon: Icons.admin_panel_settings,
                  title: 'Users',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UsersScreen()),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      onTap: onTap,
    );
  }
}
