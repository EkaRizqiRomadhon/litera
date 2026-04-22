import 'package:flutter/material.dart';
import 'package:litera/services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  String? _errorMessage;

  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final AuthService _authService = AuthService();

  static const Color kGreen = Color(0xFF3E6F52);
  static const Color kRed = Color(0xFFD08A7E);
  static const Color kBg = Color(0xFFF3F1ED);

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final name = _namaController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final confirmPassword = _confirmController.text;

      // Validasi
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        setState(() => _errorMessage = 'Semua field harus diisi');
        return;
      }

      if (password.length < 6) {
        setState(() => _errorMessage = 'Password minimal 6 karakter');
        return;
      }

      if (password != confirmPassword) {
        setState(() => _errorMessage = 'Password tidak cocok');
        return;
      }

      // Register
      await _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: name,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran berhasil! Silakan login.')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ===== REUSABLE INPUT STYLE =====
  InputDecoration inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFB0AAA3)),
      filled: true,
      fillColor: const Color(0xFFEDEAE4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreen,
      body: Column(
        children: [

          // ===== HEADER =====
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const Text(
                        "Buat Akun",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  Text(
                    "Bergabung dan mulai membaca",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          // ===== BODY =====
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: kRed.withValues(alpha: 0.1),
                            border: Border.all(color: kRed),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Color(0xFFD08A7E), fontSize: 12),
                          ),
                        ),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            _field(
                              "Nama Lengkap",
                              _namaController,
                              "Budi Santoso",
                            ),

                            const SizedBox(height: 16),

                            _field("Email", _emailController, "budi@email.com"),

                            const SizedBox(height: 16),

                            _password(
                              "Password",
                              _passwordController,
                              _obscurePassword,
                              () => setState(() {
                                _obscurePassword = !_obscurePassword;
                              }),
                            ),

                            const SizedBox(height: 16),

                            _password(
                              "Konfirmasi Password",
                              _confirmController,
                              _obscureConfirm,
                              () => setState(() {
                                _obscureConfirm = !_obscureConfirm;
                              }),
                            ),

                            const SizedBox(height: 16),

                            // CHECKBOX
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _agreeToTerms = !_agreeToTerms;
                                    });
                                  },
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                      color: _agreeToTerms
                                          ? kRed.withValues(alpha: 0.2)
                                          : Colors.transparent,
                                    ),
                                    child: _agreeToTerms
                                        ? const Icon(Icons.check, size: 14)
                                        : null,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                const Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      text: "Saya setuju dengan ",
                                      children: [
                                        TextSpan(
                                          text: "Syarat & Ketentuan",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        TextSpan(text: " dan "),
                                        TextSpan(
                                          text: "Kebijakan Privasi",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: (_agreeToTerms && !_isLoading)
                                    ? _handleRegister
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kRed,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation(Colors.white),
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        "Daftar Sekarang",
                                        style: TextStyle(color: Colors.white),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Link ke Login
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Sudah punya akun? ',
                                  style: TextStyle(fontSize: 12),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Masuk',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFD08A7E),
                                      fontSize: 12,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== TEXT FIELD =====
  Widget _field(String label, TextEditingController c, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),

        const SizedBox(height: 6),

        TextFormField(
          controller: c,
          decoration: inputStyle(hint),

          validator: (value) {
            if (value == null || value.isEmpty) {
              return "$label wajib diisi";
            }

            if (label == "Email" && !value.contains("@")) {
              return "Email tidak valid";
            }

            return null;
          },
        ),
      ],
    );
  }

  // ===== PASSWORD FIELD =====
  Widget _password(
    String label,
    TextEditingController c,
    bool obscure,
    VoidCallback toggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),

        const SizedBox(height: 6),

        TextFormField(
          controller: c,
          obscureText: obscure,
          decoration: inputStyle("Min. 8 karakter").copyWith(
            suffixIcon: TextButton(
              onPressed: toggle,
              child: Text(
                obscure ? "Lihat" : "Sembunyikan",
                style: const TextStyle(
                  color: kRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          validator: (value) {
            if (value == null || value.isEmpty) {
              return "$label wajib diisi";
            }

            if (value.length < 8) {
              return "Minimal 8 karakter";
            }

            if (label == "Konfirmasi Password" &&
                value != _passwordController.text) {
              return "Password tidak sama";
            }

            return null;
          },
        ),
      ],
    );
  }
}
