import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:customer_relationship_management/core/theme/app_theme.dart';
import 'package:customer_relationship_management/features/auth/providers/auth_provider.dart';
import 'package:customer_relationship_management/features/admin/screens/users_screen.dart';
import 'package:customer_relationship_management/features/leads/screens/leads_screen.dart';
import 'package:customer_relationship_management/features/leads/screens/proposals_screen.dart';
import 'package:customer_relationship_management/features/leads/screens/meetings_screen.dart';
import 'package:customer_relationship_management/features/leads/providers/leads_provider.dart';
import 'package:customer_relationship_management/features/customers/screens/customers_screen.dart';
import 'package:customer_relationship_management/features/calendar/screens/calendar_screen.dart';
import 'package:customer_relationship_management/features/reports/screens/reports_screen.dart';
import 'package:customer_relationship_management/features/dashboard/screens/notifications_screen.dart';
import 'package:customer_relationship_management/features/dashboard/providers/notifications_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: false,
        elevation: 0,
        actions: [
          Consumer<NotificationsProvider>(
            builder: (context, notificationsProvider, _) {
              final unreadCount = notificationsProvider.unreadCount;
              return IconButton(
                icon: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text(unreadCount > 9 ? '9+' : '$unreadCount'),
                  child: const Icon(Icons.notifications),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
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
            const Text(
              'Key Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Consumer<LeadsProvider>(
              builder: (buildContext, leadsProvider, _) {
                return _buildLeadsLineChart(leadsProvider);
              },
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Consumer<LeadsProvider>(
              builder: (buildContext, leadsProvider, _) {
                return _buildLeadsStageDonutChart(leadsProvider);
              },
            ),
            const SizedBox(height: AppTheme.spacingSm),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            _buildQuickActionsGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadsLineChart(LeadsProvider leadsProvider) {
    // Get leads from the last 30 days
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    // Group leads by day
    final Map<DateTime, int> leadsPerDay = {};
    for (var lead in leadsProvider.leads) {
      if (lead.createdAt.isAfter(thirtyDaysAgo)) {
        final dateOnly = DateTime(lead.createdAt.year, lead.createdAt.month, lead.createdAt.day);
        leadsPerDay[dateOnly] = (leadsPerDay[dateOnly] ?? 0) + 1;
      }
    }
    
    // Create sorted list of last 30 days
    final List<FlSpot> spots = [];
    for (int i = 0; i < 30; i++) {
      final date = thirtyDaysAgo.add(Duration(days: i));
      final dateOnly = DateTime(date.year, date.month, date.day);
      final count = leadsPerDay[dateOnly]?.toDouble() ?? 0;
      spots.add(FlSpot(i.toDouble(), count));
    }
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Leads Onboard Last Month',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= 30) return const SizedBox.shrink();
                          if (index % 5 != 0 && index != 29) return const SizedBox.shrink();
                          final date = thirtyDaysAgo.add(Duration(days: index));
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 4,
                            child: Text(
                              '${date.day}/${date.month}',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 9,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value % 1 != 0) return const SizedBox.shrink();
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 10,
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 9,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppTheme.primaryColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withValues(alpha: 0.2),
                            AppTheme.primaryColor.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadsStageDonutChart(LeadsProvider leadsProvider) {
    // Count leads by stage
    final Map<String, int> stageCounts = {};
    final stages = ['New', 'Contacted', 'Qualified', 'Proposal', 'Negotiation', 'Closed Won', 'Closed Lost'];
    
    for (var stage in stages) {
      stageCounts[stage] = leadsProvider.leads.where((lead) => lead.stage == stage).length;
    }
    
    // Filter out stages with 0 leads
    final filteredStages = stageCounts.entries.where((e) => e.value > 0).toList();
    
    if (filteredStages.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingSm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Lead Stages', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppTheme.spacingSm),
              const SizedBox(height: 150, child: Center(child: Text('No leads yet'))),
            ],
          ),
        ),
      );
    }
    
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red, Colors.teal, Colors.pink];
    
    Widget buildLegendItem(MapEntry<String, int> stage, Color color) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                stage.key,
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${stage.value}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lead Stages', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppTheme.spacingSm),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 150,
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 52,
                        sectionsSpace: 2,
                        sections: List.generate(filteredStages.length, (index) {
                          final stage = filteredStages[index];
                          return PieChartSectionData(
                            value: stage.value.toDouble(),
                            radius: 14,
                            showTitle: false,
                            color: colors[index % colors.length],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingLg),
                Expanded(
                  flex: 6,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            filteredStages.length > 4 ? 4 : filteredStages.length,
                            (index) {
                              final stage = filteredStages[index];
                              return buildLegendItem(stage, colors[index % colors.length]);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            filteredStages.length > 4 ? filteredStages.length - 4 : 0,
                            (index) {
                              final realIndex = index + 4;
                              final stage = filteredStages[realIndex];
                              return buildLegendItem(stage, colors[realIndex % colors.length]);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
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
