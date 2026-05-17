import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_manager/core/theme/app_theme.dart';
import 'package:sales_manager/features/auth/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              _buildHeader(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              _buildForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          ),
          child: const Icon(Icons.business, size: 40, color: Colors.white),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        const Text(
          'CRM',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        const Text(
          'Welcome Back',
          style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Column(
          children: [
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildPasswordField(),
            const SizedBox(height: AppTheme.spacingSm),
            _buildForgotPasswordButton(context),
            const SizedBox(height: AppTheme.spacingMd),
            if (authProvider.error != null)
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: AppTheme.dangerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.dangerColor),
                ),
                child: Text(
                  authProvider.error!,
                  style: const TextStyle(color: AppTheme.dangerColor),
                ),
              ),
            const SizedBox(height: AppTheme.spacingLg),
            _buildSubmitButton(context, authProvider),
            const SizedBox(height: AppTheme.spacingMd),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock, color: AppTheme.primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: AppTheme.primaryColor,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => _showResetPasswordDialog(context),
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context) {
    final resetEmailController = TextEditingController();
    final resetEmailFocus = FocusNode();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your email address and we\'ll send you a password reset link.',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              TextField(
                controller: resetEmailController,
                focusNode: resetEmailFocus,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(
                    Icons.email,
                    color: AppTheme.primaryColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return ElevatedButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                          final email = resetEmailController.text.trim();
                          if (email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter your email'),
                              ),
                            );
                            return;
                          }

                          final success = await authProvider.resetPassword(
                            email,
                          );
                          if (!mounted) return;

                          Navigator.pop(dialogContext);

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Password reset email sent! Check your inbox.',
                                ),
                                backgroundColor: Colors.green[600],
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to send reset email'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: authProvider.isLoading
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
                      : const Text('Send Reset Link'),
                );
              },
            ),
          ],
        );
      },
    ).then((_) {
      resetEmailController.dispose();
      resetEmailFocus.dispose();
    });
  }

  Widget _buildSubmitButton(BuildContext context, AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: authProvider.isLoading
            ? null
            : () async {
                // Validate input
                if (_emailController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter email')),
                  );
                  return;
                }
                if (_passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter password')),
                  );
                  return;
                }

                await authProvider.login(
                  _emailController.text.trim(),
                  _passwordController.text,
                );
              },
        child: authProvider.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Login'),
      ),
    );
  }
}
