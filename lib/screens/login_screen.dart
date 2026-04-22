import 'package:flutter/material.dart';
import 'package:litera/services/auth_service.dart';
import 'register_screen.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  static const Color kGreen = Color(0xFF2D6A4F);
  static const Color kRed = Color(0xFFC0442A);
  static const Color kCardBg = Color(0xFFF5F0E8);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreen,
      body: Column(
        children: [
          // ── Header ──
          Container(
            color: kGreen,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: Column(
                    children: [
                      const Text(
                        'Litera',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'BACA. JELAJAH. BERKEMBANG.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.6),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

// ===================== FORM CARD ============================
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Selamat datang',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Masuk untuk melanjutkan membaca',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // TOMBOL GOOGLE (VERSI FOTO)
                    const _GoogleButton(),

                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Color(0xFFD8D2CA), // garis samar
                            thickness: 1,
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 35),
                          child: Text(
                            'atau masuk dengan email',
                            style: TextStyle(
                              fontSize: 10,
                              color: kRed,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                          Expanded(
                            child: Divider(
                              color: Color(0xFFD8D2CA), // garis samar
                              thickness: 1,
                            ),
                          ),
                        ],
                    ),
                    
                    const SizedBox(height: 10),
                    const _FieldLabel(text: 'Email'),
                    const SizedBox(height: 6),
                    _TextField(
                      controller: _emailController,
                      hint: 'budi@email.com',
                      keyboardType: TextInputType.emailAddress,
                      ),
                    const SizedBox(height: 16),

                    const _FieldLabel(text: 'Password'),
                    const SizedBox(height: 6),
                    _PasswordField(
                      controller: _passwordController,
                      obscure: _obscurePassword,
                      onToggle: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async {
                          if (_emailController.text.isEmpty) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Email harus diisi')),
                              );
                            }
                            return;
                          }
                          
                          setState(() => _isLoading = true);
                          final ctx = context;
                          try {
                            await _authService.resetPassword(_emailController.text);
                            if (context.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                  content: Text('Email reset password telah dikirim'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          } finally {
                            if (context.mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                        child: const Text(
                          'Lupa password?',
                          style: TextStyle(
                            color: kRed,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: kRed.withValues(alpha: 0.1),
                          border: Border.all(color: kRed),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: kRed, fontSize: 12),
                        ),
                      ),

                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() {
                                  _errorMessage = null;
                                  _isLoading = true;
                                });
                                final ctx = context;

                                try {
                                  final email = _emailController.text.trim();
                                  final password = _passwordController.text;

                                  if (email.isEmpty || password.isEmpty) {
                                    setState(() {
                                      _errorMessage = 'Email dan password harus diisi';
                                      _isLoading = false;
                                    });
                                    return;
                                  }

                                  await _authService.loginWithEmail(
                                    email: email,
                                    password: password,
                                  );

                                  if (context.mounted) {
                                    Navigator.of(ctx).pushNamedAndRemoveUntil(
                                      '/home',
                                      (route) => false,
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    setState(() {
                                      _errorMessage = e.toString();
                                    });
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Masuk',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum punya akun? ',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Daftar sekarang',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: kRed,
                            ),
                          ),
                        ),
                      ],
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
}

// ── WIDGET TOMBOL GOOGLE DENGAN FOTO ──
class _GoogleButton extends StatefulWidget {
  const _GoogleButton();

  @override
  State<_GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<_GoogleButton> {
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        onPressed: _isLoading
            ? null
            : () async {
                setState(() => _isLoading = true);
                final ctx = context;
                try {
                  await _authService.loginWithGoogle();
                  if (context.mounted) {
                    Navigator.of(ctx).pushNamedAndRemoveUntil(
                      '/home',
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() => _isLoading = false);
                  }
                }
              },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFE0DBD3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFF333333)),
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/images/logo.png',
                    height: 20,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Lanjutkan dengan Google',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Komponen Pendukung ──
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF444240),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  const _TextField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color.fromARGB(255, 141, 140, 140)),
        filled: true,
        fillColor: const Color(0xFFECE8E0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}


class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: const TextStyle(color: Color(0xFFB0AAA3)),
        filled: true,
        fillColor: const Color(0xFFECE8E0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Text(
            obscure ? 'Lihat' : 'Sembunyikan',
            style: const TextStyle(
              color: Color(0xFFC0442A),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
