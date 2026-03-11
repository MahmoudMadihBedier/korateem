import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _passwordsVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E88E5), Color(0xFF43A047)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sports_soccer, size: 60, color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      'كورة تيم',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'إنشاء حساب جديد',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildTextField(
                    controller: nameController,
                    label: 'الاسم الكامل',
                    icon: Icons.person,
                    hint: 'أحمد محمد',
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: emailController,
                    label: 'البريد الإلكتروني',
                    icon: Icons.email,
                    hint: 'your@email.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: phoneController,
                    label: 'رقم الهاتف',
                    icon: Icons.phone,
                    hint: '+201012345678',
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: passwordController,
                    label: 'كلمة المرور',
                    icon: Icons.lock,
                    hint: '••••••••',
                    obscureText: !_passwordsVisible,
                    suffixIcon: GestureDetector(
                      onTap: () => setState(
                        () => _passwordsVisible = !_passwordsVisible,
                      ),
                      child: Icon(
                        _passwordsVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: confirmPasswordController,
                    label: 'تأكيد كلمة المرور',
                    icon: Icons.lock_outline,
                    hint: '••••••••',
                    obscureText: !_passwordsVisible,
                  ),
                  SizedBox(height: 24),
                  _buildSignupButton(),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'لديك حساب بالفعل؟ ',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            color: Color(0xFF1E88E5),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String hint = '',
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Color(0xFF1E88E5)),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF1E88E5), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildSignupButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1E88E5).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _signup,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: _isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'إنشاء حساب',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _signup() async {
    if (nameController.text.isEmpty) {
      _showError('الرجاء إدخال الاسم الكامل');
      return;
    }
    if (emailController.text.isEmpty) {
      _showError('الرجاء إدخال البريد الإلكتروني');
      return;
    }
    if (phoneController.text.isEmpty) {
      _showError('الرجاء إدخال رقم الهاتف');
      return;
    }
    if (passwordController.text.isEmpty) {
      _showError('الرجاء إدخال كلمة المرور');
      return;
    }
    if (passwordController.text.length < 6) {
      _showError('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _showError('كلمات المرور غير متطابقة');
      return;
    }

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.signUpWithEmail(
      emailController.text,
      passwordController.text,
      nameController.text,
      phoneController.text,
    );

    setState(() => _isLoading = false);

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إنشاء الحساب بنجاح'),
          backgroundColor: Color(0xFF43A047),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } else {
      _showError(authService.errorMessage ?? 'حدث خطأ أثناء إنشاء الحساب');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
