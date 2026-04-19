import 'package:flutter/material.dart';
import 'package:korateem/ui/modern_components.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import 'signup_screen.dart';
import '../core/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _passwordVisible = false;

  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            title: const Text('تسجيل الدخول'),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/images/image.png', fit: BoxFit.cover),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.65),
                          Colors.black.withOpacity(0.28),
                          Theme.of(context).scaffoldBackgroundColor,
                        ],
                        stops: const [0, 0.6, 1],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 72),
                        child: FadeTransition(
                          opacity: _fade,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.92, end: 1),
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.elasticOut,
                                builder: (context, t, child) =>
                                    Transform.scale(scale: t, child: child),
                                child: Container(
                                  width: 78,
                                  height: 78,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.12),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/image.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.sports_soccer,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'كورة تيم',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'احجز ملعبك وشكّل فريقك بسرعة',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.white70),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fade,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ModernCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'مرحباً بعودتك',
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'سجّل دخولك لمتابعة الحجز والمنشورات.',
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 16),
                            _AuthTextField(
                              controller: emailController,
                              label: 'البريد الإلكتروني',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: Validators.validateEmail,
                            ),
                            const SizedBox(height: 12),
                            _AuthTextField(
                              controller: passwordController,
                              label: 'كلمة المرور',
                              icon: Icons.lock_outline,
                              obscureText: !_passwordVisible,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _isLoading ? null : _login(),
                              validator: Validators.validatePassword,
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => _passwordVisible = !_passwordVisible,
                                ),
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _isLoading ? null : _showResetPasswordDialog,
                                child: const Text('هل نسيت كلمة المرور؟'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _PrimaryButton(
                              label: 'تسجيل الدخول',
                              isLoading: _isLoading,
                              onPressed: _isLoading ? null : _login,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(
                                    color: Color(0xFF2A2A2A),
                                    height: 1,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'أو',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(
                                    color: Color(0xFF2A2A2A),
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            OutlinedButton.icon(
                              onPressed: _isLoading ? null : _googleLogin,
                              icon: const Icon(Icons.g_mobiledata_rounded),
                              label: const Text('تسجيل الدخول عبر Google'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ModernCard(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_add_alt_1,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'لا تملك حساب؟',
                                  style: Theme.of(context).textTheme.titleMedium,
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'أنشئ حساباً جديداً خلال دقيقة',
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_back_ios_new,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.signInWithEmail(
      emailController.text.trim(),
      passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (user != null) {
      _showSuccess('تم تسجيل الدخول بنجاح!');
      await Future.delayed(const Duration(milliseconds: 900));
    } else {
      _showError(authService.errorMessage ?? 'خطأ في تسجيل الدخول');
    }
  }

  void _googleLogin() async {
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.signInWithGoogle();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (user != null) {
      _showSuccess('تم تسجيل الدخول بنجاح!');
      await Future.delayed(const Duration(milliseconds: 900));
    } else {
      _showError(authService.errorMessage ?? 'خطأ في تسجيل الدخول عبر Google');
    }
  }

  void _showResetPasswordDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return _ResetPasswordDialog(
          initialEmail: emailController.text.trim(),
          onSuccess: () => _showSuccess(
            'تم إرسال رابط استعادة كلمة المرور إلى بريدك.',
          ),
          onError: _showError,
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message, textDirection: TextDirection.rtl)),
          ],
        ),
        backgroundColor: const Color(0xFFCF6679),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message, textDirection: TextDirection.rtl)),
          ],
        ),
        backgroundColor: const Color(0xFF43A047),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;

  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.suffixIcon,
    this.onSubmitted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      textDirection: TextDirection.rtl,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}

class _ResetPasswordDialog extends StatefulWidget {
  final String initialEmail;
  final VoidCallback onSuccess;
  final ValueChanged<String> onError;

  const _ResetPasswordDialog({
    required this.initialEmail,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<_ResetPasswordDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialEmail);
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _controller.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      widget.onError('الرجاء إدخال بريد إلكتروني صحيح');
      return;
    }
    if (_sending) return;

    setState(() => _sending = true);
    try {
      await context.read<AuthService>().sendPasswordResetEmail(email);
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      widget.onError('حدث خطأ: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Dialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'استعادة كلمة المرور',
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                'اكتب بريدك الإلكتروني وسنرسل لك رابط تغيير كلمة المرور.',
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              _AuthTextField(
                controller: _controller,
                label: 'البريد الإلكتروني',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _sending ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(140, 46),
                    ),
                    child: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('إرسال الرابط'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
