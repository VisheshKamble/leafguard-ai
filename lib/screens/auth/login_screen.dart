import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(_emailController.text.trim(), _passwordController.text);
    if (success && mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppConstants.space32),
              Text('Welcome back', style: AppTextStyles.headline),
              const SizedBox(height: AppConstants.space4),
              Text(
                'Sign in to sync your scan history across devices.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: AppConstants.space32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'Email'),
              ),
              const SizedBox(height: AppConstants.space12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Password'),
              ),
              if (auth.errorMessage != null) ...[
                const SizedBox(height: AppConstants.space12),
                Text(auth.errorMessage!, style: AppTextStyles.body.copyWith(color: AppColors.error)),
              ],
              const SizedBox(height: AppConstants.space24),
              PrimaryButton(label: 'Sign in', onPressed: _submit, isLoading: auth.isLoading),
              const SizedBox(height: AppConstants.space16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  ),
                  child: Text(
                    "Don't have an account? Sign up",
                    style: AppTextStyles.body.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.space8),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Continue without an account', style: AppTextStyles.caption),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
