import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_manager/core/theme/app_theme.dart';
import 'package:sales_manager/core/constants/role_permissions.dart';
import 'package:sales_manager/features/auth/providers/auth_provider.dart';
import 'package:sales_manager/features/admin/providers/user_management_provider.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRole = 'salesperson';
  bool _showCreateForm = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<UserManagementProvider>().fetchAllUsers();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
    _phoneController.clear();
    setState(() {
      _selectedRole = 'salesperson';
      _showCreateForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management'), elevation: 0),
      body: Consumer2<AuthProvider, UserManagementProvider>(
        builder: (context, authProvider, userProvider, _) {
          final creatableRoles = userProvider.getCreatableRoles(
            authProvider.currentUser?.role ?? 'salesperson',
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Create User Button
                if (creatableRoles.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showCreateForm = !_showCreateForm;
                          });
                        },
                        icon: Icon(_showCreateForm ? Icons.close : Icons.add),
                        label: Text(
                          _showCreateForm ? 'Cancel' : 'Create New User',
                        ),
                      ),
                    ),
                  ),

                // Create User Form
                if (_showCreateForm && creatableRoles.isNotEmpty)
                  _buildCreateUserForm(
                    context,
                    userProvider,
                    creatableRoles,
                    authProvider,
                  ),

                const SizedBox(height: AppTheme.spacingLg),

                // Users List
                const Text(
                  'All Users',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppTheme.spacingMd),

                if (userProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (userProvider.users.isEmpty)
                  const Center(child: Text('No users found'))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userProvider.users.length,
                    itemBuilder: (context, index) {
                      final user = userProvider.users[index];
                      final canModify =
                          authProvider.currentUser?.role == 'admin' ||
                          (authProvider.currentUser?.role == 'manager' &&
                              user.role == 'salesperson');

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: AppTheme.spacingMd,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingMd),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: AppTheme.spacingSm,
                                        ),
                                        Text(
                                          user.email,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppTheme.spacingSm,
                                          vertical: AppTheme.spacingSm,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor,
                                          borderRadius: BorderRadius.circular(
                                            AppTheme.radiusMd,
                                          ),
                                        ),
                                        child: Text(
                                          RolePermissions.getRoleDisplayName(
                                            user.role,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: AppTheme.spacingSm,
                                      ),
                                      Text(
                                        user.isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: user.isActive
                                              ? AppTheme.secondaryColor
                                              : AppTheme.dangerColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (canModify) ...[
                                const SizedBox(height: AppTheme.spacingMd),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (!user.isActive)
                                      OutlinedButton.icon(
                                        onPressed: () async {
                                          final success = await userProvider
                                              .activateUser(user.id);
                                          if (mounted && success) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'User activated successfully',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.check),
                                        label: const Text('Activate'),
                                      )
                                    else
                                      OutlinedButton.icon(
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text(
                                                  'Deactivate User',
                                                ),
                                                content: const Text(
                                                  'Are you sure you want to deactivate this user?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    child: const Text(
                                                      'Deactivate',
                                                      style: TextStyle(
                                                        color: AppTheme
                                                            .dangerColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (confirm ?? false) {
                                            final success = await userProvider
                                                .deactivateUser(user.id);
                                            if (mounted && success) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'User deactivated successfully',
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        icon: const Icon(Icons.close),
                                        label: const Text('Deactivate'),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreateUserForm(
    BuildContext context,
    UserManagementProvider userProvider,
    List<String> creatableRoles,
    AuthProvider authProvider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create New User',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              items: creatableRoles.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(RolePermissions.getRoleDisplayName(role)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRole = value;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
              ),
            ),
            if (userProvider.error != null) ...[
              const SizedBox(height: AppTheme.spacingMd),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: AppTheme.dangerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.dangerColor),
                ),
                child: Text(
                  userProvider.error!,
                  style: const TextStyle(color: AppTheme.dangerColor),
                ),
              ),
            ],
            const SizedBox(height: AppTheme.spacingLg),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: userProvider.isLoading
                    ? null
                    : () async {
                        final success = await userProvider.createUser(
                          _emailController.text,
                          _passwordController.text,
                          _nameController.text,
                          _phoneController.text,
                          _selectedRole,
                          createdBy: authProvider.currentUser?.id,
                        );

                        if (mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('User created successfully'),
                              ),
                            );
                            _clearForm();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  userProvider.error ?? 'Failed to create user',
                                ),
                              ),
                            );
                          }
                        }
                      },
                child: userProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Create User'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
