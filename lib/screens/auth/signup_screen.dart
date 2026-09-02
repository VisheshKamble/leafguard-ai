import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signUp(_emailController.text.trim(), _passwordController.text);
    if (success && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
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
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your scans stay on this device either way -- an account just lets you sync and recover them.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: AppConstants.space24),
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
              PrimaryButton(label: 'Create account', onPressed: _submit, isLoading: auth.isLoading),
            ],
          ),
        ),
      ),
    );
  }
}
