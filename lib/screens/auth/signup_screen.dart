import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/locale_provider.dart';
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
      appBar: AppBar(title: Text(context.tr('createAccount'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('signupIntro'),
                style: AppTextStyles.body,
              ),
              const SizedBox(height: AppConstants.space24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: context.tr('emailHint')),
              ),
              const SizedBox(height: AppConstants.space12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(hintText: context.tr('passwordHint')),
              ),
              if (auth.errorMessage != null) ...[
                const SizedBox(height: AppConstants.space12),
                Text(auth.errorMessage!, style: AppTextStyles.body.copyWith(color: AppColors.error)),
              ],
              const SizedBox(height: AppConstants.space24),
              PrimaryButton(label: context.tr('createAccount'), onPressed: _submit, isLoading: auth.isLoading),
            ],
          ),
        ),
      ),
    );
  }
}
