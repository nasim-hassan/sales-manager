import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_manager/core/theme/app_theme.dart';
import 'package:sales_manager/features/admin/providers/users_provider.dart';
import 'package:sales_manager/features/admin/screens/user_edit_screen.dart';

class UserViewScreen extends StatefulWidget {
  final String userId;

  const UserViewScreen({super.key, required this.userId});

  @override
  State<UserViewScreen> createState() => _UserViewScreenState();
}

class _UserViewScreenState extends State<UserViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        elevation: 0,
        actions: [
          Consumer<UsersProvider>(
            builder: (context, usersProvider, _) {
              final user = usersProvider.getUserById(widget.userId);
              if (user != null) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserEditScreen(user: user),
                      ),
                    ).then((_) {
                      setState(() {});
                    });
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: Consumer<UsersProvider>(
        builder: (context, usersProvider, _) {
          if (usersProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = usersProvider.getUserById(widget.userId);

          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'User not found',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Avatar
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.lightTheme()
                            .colorScheme
                            .primary
                            .withOpacity(0.3),
                        child: Text(
                          user.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getRoleColor(user.role).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: _getRoleColor(user.role),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingSm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: user.isActive
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.isActive ? 'ACTIVE' : 'INACTIVE',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: user.isActive
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),

                // Contact Information
                _buildSection(context, 'Contact Information', [
                  _buildDetailRow(context, 'Email', user.email, Icons.email),
                  const SizedBox(height: AppTheme.spacingMd),
                  _buildDetailRow(context, 'Phone', user.phone, Icons.phone),
                ]),
                const SizedBox(height: AppTheme.spacingLg),

                // Account Information
                _buildSection(context, 'Account Information', [
                  _buildDetailRow(
                    context,
                    'User ID',
                    user.id,
                    Icons.fingerprint,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  _buildDetailRow(
                    context,
                    'Created',
                    _formatDate(user.createdAt),
                    Icons.calendar_today,
                  ),
                  if (user.updatedAt != null) ...[
                    const SizedBox(height: AppTheme.spacingMd),
                    _buildDetailRow(
                      context,
                      'Last Updated',
                      _formatDate(user.updatedAt!),
                      Icons.update,
                    ),
                  ],
                ]),
                const SizedBox(height: AppTheme.spacingLg),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserEditScreen(user: user),
                            ),
                          ).then((_) {
                            setState(() {});
                          });
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDeleteDialog(context, user.id),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<UsersProvider>().deleteUser(userId);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User deleted successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'manager':
        return Colors.orange;
      case 'salesperson':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
