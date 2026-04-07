import 'package:flutter/material.dart';
import 'package:korateem/services/auth_service.dart';
import 'package:korateem/ui/modern_components.dart';
import 'package:provider/provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _sending = false;
  bool _checking = false;

  Future<void> _resend() async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      await context.read<AuthService>().sendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال رابط التحقق إلى بريدك الإلكتروني.'),
          backgroundColor: Color(0xFF43A047),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e', textDirection: TextDirection.rtl),
          backgroundColor: const Color(0xFFCF6679),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _check() async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      final auth = context.read<AuthService>();
      await auth.reloadCurrentUser();
      final verified = auth.currentUser?.emailVerified ?? false;
      if (!mounted) return;
      if (!verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لم يتم التحقق بعد. افحص بريدك ثم حاول مرة أخرى.'),
            backgroundColor: Color(0xFFCF6679),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final email = auth.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ModernCard.glass(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'تحقق من بريدك الإلكتروني',
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أرسلنا رسالة تحقق إلى بريدك. افتحها واضغط على رابط التفعيل ثم ارجع هنا واضغط "تم التحقق".',
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (email.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        email,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: _checking ? null : _check,
                      child: _checking
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('تم التحقق'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: _sending ? null : _resend,
                      child: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('إعادة إرسال رابط التحقق'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => context.read<AuthService>().signOut(),
                      child: const Text('تسجيل الخروج'),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ملاحظة: قد تجد الرسالة في "الرسائل غير المرغوبة".',
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

