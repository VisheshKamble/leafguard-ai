import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/leaf_motif.dart';
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.space24,
                  AppConstants.space48,
                  AppConstants.space24,
                  AppConstants.space32,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDeep],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    const Positioned.fill(child: LeafPatternBackground(color: Color(0x1AFFFFFF))),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('welcomeBack'),
                          style: AppTextStyles.headline.copyWith(color: AppColors.textOnPrimary),
                        ),
                        const SizedBox(height: AppConstants.space4),
                        Text(
                          context.tr('signInSubtitle'),
                          style: AppTextStyles.body.copyWith(color: AppColors.textOnPrimary.withOpacity(0.85)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppConstants.space24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    PrimaryButton(label: context.tr('signIn'), onPressed: _submit, isLoading: auth.isLoading),
                    const SizedBox(height: AppConstants.space16),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SignupScreen()),
                        ),
                        child: Text(
                          context.tr('noAccountSignUp'),
                          style: AppTextStyles.body.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.space8),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(context.tr('continueWithoutAccount'), style: AppTextStyles.caption),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
