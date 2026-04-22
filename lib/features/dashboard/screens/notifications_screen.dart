import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sales_manager/core/theme/app_theme.dart';
import 'package:sales_manager/core/models/notification_model.dart';
import 'package:sales_manager/features/dashboard/providers/notifications_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _filterType =
      'all'; // all, unread, lead, proposal, meeting, customer, system

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        actions: [
          Consumer<NotificationsProvider>(
            builder: (context, provider, _) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'mark_all_read') {
                    provider.markAllAsRead();
                  } else if (value == 'clear_all') {
                    _showClearAllDialog(context, provider);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'mark_all_read',
                    child: Row(
                      children: [
                        Icon(Icons.done_all, size: 20),
                        SizedBox(width: AppTheme.spacingSm),
                        Text('Mark all as read'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.delete_sweep, size: 20, color: Colors.red),
                        SizedBox(width: AppTheme.spacingSm),
                        Text('Clear all', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(child: _buildNotificationsList()),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      'all',
      'unread',
      'lead',
      'proposal',
      'meeting',
      'customer',
      'system',
    ];
    final labels = [
      'All',
      'Unread',
      'Leads',
      'Proposals',
      'Meetings',
      'Customers',
      'System',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Row(
        children: List.generate(filters.length, (index) {
          final filter = filters[index];
          final label = labels[index];
          final isSelected = _filterType == filter;

          return Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacingSm),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filterType = filter;
                });
              },
              backgroundColor: Colors.transparent,
              selectedColor: AppTheme.primaryColor.withOpacity(0.3),
              side: BorderSide(
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.borderColor,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return Consumer<NotificationsProvider>(
      builder: (context, provider, _) {
        List<dynamic> notifications;

        if (_filterType == 'all') {
          notifications = provider.notifications;
        } else if (_filterType == 'unread') {
          notifications = provider.getUnreadNotifications();
        } else {
          notifications = provider.getNotificationsByType(_filterType);
        }

        // Sort by date, newest first
        notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 48,
                  color: AppTheme.textTertiary,
                ),
                const SizedBox(height: AppTheme.spacingMd),
                Text(
                  _filterType == 'all'
                      ? 'No notifications'
                      : 'No notifications in this category',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _buildNotificationCard(notification, context, provider);
          },
        );
      },
    );
  }

  Widget _buildNotificationCard(
    NotificationModel notification,
    BuildContext context,
    NotificationsProvider provider,
  ) {
    final typeIcon = _getTypeIcon(notification.type);
    final typeColor = _getTypeColor(notification.type);
    final timeAgo = _formatTimeAgo(notification.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 24),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.accentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'mark_read') {
                      if (!notification.isRead) {
                        provider.markAsRead(notification.id);
                      }
                    } else if (value == 'delete') {
                      provider.deleteNotification(notification.id);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    if (!notification.isRead)
                      const PopupMenuItem<String>(
                        value: 'mark_read',
                        child: Row(
                          children: [
                            Icon(Icons.done, size: 20),
                            SizedBox(width: AppTheme.spacingSm),
                            Text('Mark as read'),
                          ],
                        ),
                      ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: AppTheme.spacingSm),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'lead':
        return Icons.trending_up;
      case 'proposal':
        return Icons.description;
      case 'meeting':
        return Icons.event;
      case 'customer':
        return Icons.person;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'lead':
        return Colors.blue;
      case 'proposal':
        return Colors.orange;
      case 'meeting':
        return Colors.green;
      case 'customer':
        return Colors.purple;
      case 'system':
        return AppTheme.infoColor;
      default:
        return AppTheme.infoColor;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }

  void _showClearAllDialog(
    BuildContext context,
    NotificationsProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text(
          'Are you sure you want to delete all notifications?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteAllNotifications();
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
