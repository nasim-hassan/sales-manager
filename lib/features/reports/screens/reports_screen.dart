import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_manager/core/theme/app_theme.dart';
import 'package:sales_manager/features/leads/providers/leads_provider.dart';
import 'package:sales_manager/features/leads/providers/proposals_provider.dart';
import 'package:sales_manager/features/leads/providers/meetings_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRM Reports'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall Statistics',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spacingXl),
            _buildStatisticsGrid(context),
            const SizedBox(height: AppTheme.spacingXl),
            const Text(
              'Stage Breakdown',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildStageBreakdown(context),
            const SizedBox(height: AppTheme.spacingXl),
            const Text(
              'Proposal Status Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildProposalSummary(context),
            const SizedBox(height: AppTheme.spacingXl),
            const Text(
              'Meeting Schedule',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildMeetingSummary(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid(BuildContext context) {
    return Consumer3<LeadsProvider, ProposalsProvider, MeetingsProvider>(
      builder:
          (context, leadsProvider, proposalsProvider, meetingsProvider, _) {
            final totalLeads = leadsProvider.leads.length;
            final totalProposals = proposalsProvider.proposals.length;

            return Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Leads',
                    value: totalLeads.toString(),
                    icon: Icons.trending_up,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: _buildStatCard(
                    title: 'Proposals',
                    value: totalProposals.toString(),
                    icon: Icons.description,
                    color: Colors.orange,
                  ),
                ),
              ],
            );
          },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
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
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildStageBreakdown(BuildContext context) {
    return Consumer<LeadsProvider>(
      builder: (context, leadsProvider, _) {
        final stages = [
          'New',
          'Contacted',
          'Qualified',
          'Proposal',
          'Negotiation',
          'Closed Won',
          'Closed Lost',
        ];
        final stageCounts = <String, int>{};

        for (final stage in stages) {
          stageCounts[stage] = leadsProvider.leads
              .where((l) => l.stage == stage)
              .length;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              children: [
                ...stages.map((stage) {
                  final count = stageCounts[stage] ?? 0;
                  final color = _getStageColor(stage);
                  final percentage = leadsProvider.leads.isEmpty
                      ? 0.0
                      : (count / leadsProvider.leads.length) * 100;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: AppTheme.spacingSm),
                                Text(
                                  stage,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '$count (${percentage.toStringAsFixed(1)}%)',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingSm),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProposalSummary(BuildContext context) {
    return Consumer<ProposalsProvider>(
      builder: (context, proposalsProvider, _) {
        final statuses = ['draft', 'sent', 'accepted', 'rejected', 'expired'];
        final statusCounts = <String, int>{};

        for (final status in statuses) {
          statusCounts[status] = proposalsProvider.proposals
              .where((p) => p.status == status)
              .length;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              children: [
                ...statuses.map((status) {
                  final count = statusCounts[status] ?? 0;
                  final color = _getProposalStatusColor(status);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          count.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMeetingSummary(BuildContext context) {
    return Consumer<MeetingsProvider>(
      builder: (context, meetingsProvider, _) {
        final upcoming = meetingsProvider.meetings
            .where(
              (m) =>
                  m.scheduledAt.isAfter(DateTime.now()) &&
                  m.status != 'cancelled',
            )
            .length;
        final completed = meetingsProvider.meetings
            .where((m) => m.status == 'completed')
            .length;
        final cancelled = meetingsProvider.meetings
            .where((m) => m.status == 'cancelled')
            .length;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              children: [
                _buildMeetingInfoRow('Upcoming', upcoming, Colors.blue),
                _buildMeetingInfoRow('Completed', completed, Colors.green),
                _buildMeetingInfoRow('Cancelled', cancelled, Colors.red),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMeetingInfoRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          Text(
            count.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getStageColor(String stage) {
    switch (stage.toLowerCase()) {
      case 'new':
        return Colors.blue;
      case 'contacted':
        return Colors.cyan;
      case 'qualified':
        return Colors.amber;
      case 'proposal':
        return Colors.orange;
      case 'negotiation':
        return Colors.deepOrange;
      case 'closed won':
        return Colors.green;
      case 'closed lost':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getProposalStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.grey;
      case 'sent':
        return Colors.blue;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'expired':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
