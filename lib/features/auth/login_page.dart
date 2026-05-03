import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/auth_provider.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_input.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool obscurePassword = true;
  String? errorMessage;

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    setState(() => errorMessage = null);
    final auth = context.read<AuthProvider>();
    final error = await auth.login(emailCtrl.text, passwordCtrl.text);
    if (error != null && mounted) {
      setState(() => errorMessage = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isDark = cs.brightness == Brightness.dark;

    if (auth.isLoading && !auth.isAuthenticated) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF13131F) : const Color(0xFFF3F4F6),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF13131F) : const Color(0xFFF3F4F6),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo & branding
                _buildLogo(context, cs, theme),
                const SizedBox(height: 40),
                // Card
                _buildLoginCard(context, cs, theme, isDark, auth),
              ]
                  .animate(interval: 80.ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.1, end: 0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context, ColorScheme cs, ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primary, cs.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.blur_on, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 16),
        Text(
          'FuzzyBoard',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sign in to your workspace',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurface.withOpacity(0.55),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(
    BuildContext context,
    ColorScheme cs,
    ThemeData theme,
    bool isDark,
    AuthProvider auth,
  ) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome back',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter your credentials to continue',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withOpacity(0.55),
            ),
          ),
          const SizedBox(height: 24),
          AppInput(
            label: 'Email',
            hint: 'you@example.com',
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            prefix: Icon(Icons.email_outlined, size: 18, color: cs.onSurface.withOpacity(0.4)),
          ),
          const SizedBox(height: 16),
          AppInput(
            label: 'Password',
            hint: '••••••••',
            controller: passwordCtrl,
            obscureText: obscurePassword,
            prefix: Icon(Icons.lock_outlined, size: 18, color: cs.onSurface.withOpacity(0.4)),
            suffix: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 18,
                color: cs.onSurface.withOpacity(0.4),
              ),
              onPressed: () => setState(() => obscurePassword = !obscurePassword),
            ),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 16, color: Color(0xFFEF4444)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFFEF4444)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          AppButton(
            label: 'Sign In',
            loading: auth.isLoading,
            fullWidth: true,
            size: AppButtonSize.lg,
            onPressed: auth.isLoading ? null : handleLogin,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withOpacity(0.55),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SignupPage()),
                ),
                child: Text(
                  'Sign up',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
