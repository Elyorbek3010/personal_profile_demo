import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/locale_service.dart';
import '../widgets/app_top_bar.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: kDebugMode ? '2311194e@jdu.uz' : '');
  final _passwordController = TextEditingController(text: kDebugMode ? 'jdu12345' : '');
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _isSubmitting = false;

  final List<Map<String, String>> _quickStudents = [
    {
      'label': 'Ozodbek',
      'sub': '23C • TOU • Ozod',
      'email': '2300037o@jdu.uz',
      'pass': 'jdu12345',
    },
    {
      'label': 'Elyorbek',
      'sub': '23D • TOU • Ozod',
      'email': '2311194e@jdu.uz',
      'pass': 'jdu12345',
    },
    {
      'label': 'Sardor',
      'sub': '23D • SANNO',
      'email': '2311195e@jdu.uz',
      'pass': 'jdu12345',
    },
    {
      'label': 'Diyorbek',
      'sub': '24A • 2-kurs',
      'email': '2411001e@jdu.uz',
      'pass': 'jdu12345',
    },
  ];

  Future<void> _handleLogin() async {
    final t = LocaleService().t;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = t('email_empty');
        _isSubmitting = false;
      });
      return;
    }

    if (!email.toLowerCase().endsWith('@jdu.uz')) {
      setState(() {
        _errorMessage = t('domain_error');
        _isSubmitting = false;
      });
      return;
    }

    try {
      await AuthService().login(email, password);
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _fillAndLogin(String email, String pass) {
    _emailController.text = email;
    _passwordController.text = pass;
    _handleLogin();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = LocaleService().t;
    final isLoading = _isSubmitting || AuthService().isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Action Bar: Theme & Language
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  ThemeAndLanguageBar(),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // App Name Header (Logo picture removed per user request)
                        Text(
                          t('app_name'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          t('app_subtitle'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Form Container Card
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF131D31) : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Title & Instruction
                              Text(
                                t('login_title'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                t('login_desc'),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Error Banner
                              if (_errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline_rounded,
                                        color: Color(0xFFEF4444),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: const TextStyle(
                                            color: Color(0xFFEF4444),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Email Input
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                enabled: !isLoading,
                                decoration: InputDecoration(
                                  labelText: t('email_label'),
                                  hintText: t('email_hint'),
                                  prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Password Input
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                enabled: !isLoading,
                                decoration: InputDecoration(
                                  labelText: t('password_label'),
                                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                onSubmitted: (_) => _handleLogin(),
                              ),
                              const SizedBox(height: 22),

                              // Submit Button with Gradient
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2563EB),
                                      Color(0xFF1D4ED8),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  onPressed: isLoading ? null : _handleLogin,
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          t('login_btn'),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (kDebugMode) ...[
                          const SizedBox(height: 26),

                          // Quick Test Students Section (Debug only)
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  t('quick_test'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Quick Student Chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: _quickStudents.map((s) {
                              return InkWell(
                                onTap: isLoading
                                    ? null
                                    : () => _fillAndLogin(s['email']!, s['pass']!),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF131D31) : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        s['label']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: Color(0xFF38BDF8),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        s['sub']!,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
