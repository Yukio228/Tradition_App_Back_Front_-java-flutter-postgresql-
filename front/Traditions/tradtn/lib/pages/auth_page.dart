import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_controller.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_icon_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_text_field.dart';
import 'home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  bool loading = false;
  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool showErrors = false;

  final username = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  String? errorMessage;

  bool _isEmailOrPhone(String value) {
    final v = value.trim();
    if (v.isEmpty) return false;
    final emailOk = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v);
    final phoneOk = RegExp(r'^\+?[0-9][0-9\s\-\(\)]{7,}$').hasMatch(v);
    return emailOk || phoneOk;
  }

  bool get _isUsernameValid => _isEmailOrPhone(username.text);
  bool get _isPasswordValid => password.text.length >= 6;
  bool get _isConfirmValid =>
      confirm.text.isNotEmpty && confirm.text == password.text;

  bool get _canSubmit =>
      !loading &&
      _isUsernameValid &&
      _isPasswordValid &&
      (isLogin || _isConfirmValid);

  String? get _usernameError {
    if (!showErrors) return null;
    if (username.text.trim().isEmpty) return 'Enter your email or phone';
    if (!_isUsernameValid) return 'Use a valid email or phone';
    return null;
  }

  String? get _passwordError {
    if (!showErrors) return null;
    if (password.text.isEmpty) return 'Enter your password';
    if (!_isPasswordValid) return 'Minimum 6 characters';
    return null;
  }

  String? get _confirmError {
    if (isLogin || !showErrors) return null;
    if (confirm.text.isEmpty) return 'Confirm your password';
    if (!_isConfirmValid) return 'Passwords do not match';
    return null;
  }

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      setState(() => showErrors = true);
      return;
    }

    setState(() {
      loading = true;
      errorMessage = null;
      showErrors = true;
    });

    String? res;
    if (isLogin) {
      res = await ApiService.login(
        username.text.trim(),
        password.text,
      );
    } else {
      res = await ApiService.register(
        username.text.trim(),
        password.text,
      );
    }

    if (!mounted) return;

    if (res != null) {
      setState(() {
        errorMessage = res;
        loading = false;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? 'USER';
    await widget.themeController.load();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          role == 'ADMIN'
              ? 'Signed in as Admin'
              : 'Signed in as User',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(themeController: widget.themeController),
      ),
    );
  }

  void _toggleMode() {
    setState(() {
      isLogin = !isLogin;
      errorMessage = null;
      showErrors = false;
      confirm.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return AppScaffold(
      safeArea: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (Navigator.canPop(context))
                  AppIconButton(
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Back',
                  ),
                const Spacer(),
                AppIconButton(
                  icon: theme.brightness == Brightness.dark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  onPressed: widget.themeController.toggle,
                  tooltip: 'Toggle theme',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              isLogin ? 'Welcome back' : 'Create your account',
              style: textTheme.displayLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isLogin
                  ? 'Sign in to explore Kazakh traditions.'
                  : 'Join the community and share traditions.',
              style: textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: username,
                    label: 'Email or phone',
                    hintText: 'name@example.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.alternate_email_rounded,
                    errorText: _usernameError,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: password,
                    label: 'Password',
                    hintText: '********',
                    obscureText: obscurePassword,
                    textInputAction:
                        isLogin ? TextInputAction.done : TextInputAction.next,
                    prefixIcon: Icons.lock_rounded,
                    errorText: _passwordError,
                    onChanged: (_) => setState(() {}),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                      ),
                      onPressed: () {
                        setState(() => obscurePassword = !obscurePassword);
                      },
                    ),
                  ),
                  if (!isLogin) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: confirm,
                      label: 'Confirm password',
                      hintText: '********',
                      obscureText: obscureConfirm,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.verified_user_rounded,
                      errorText: _confirmError,
                      onChanged: (_) => setState(() {}),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirm
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                        onPressed: () {
                          setState(() => obscureConfirm = !obscureConfirm);
                        },
                      ),
                    ),
                  ],
                  if (errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      errorMessage!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: isLogin ? 'Sign in' : 'Create account',
                    loading: loading,
                    onPressed: _canSubmit ? _submit : null,
                    icon: Icons.arrow_forward_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: TextButton(
                      onPressed: _toggleMode,
                      child: Text(
                        isLogin
                            ? 'New here? Create an account'
                            : 'Already have an account? Sign in',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
