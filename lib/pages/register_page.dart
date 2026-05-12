import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../widgets/custom_elements.dart';
import '../auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isAgreed = false;
  bool _isLoading = false;

  bool _isPasswordObscured = true;
  bool _isConfirmObscured = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ================= VALIDATION =================

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Nama wajib diisi";
    }
    if (value.length < 3) {
      return "Minimal 3 karakter";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email wajib diisi";
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return "Format email tidak valid";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password wajib diisi";
    }
    if (value.length < 8) {
      return "Minimal 8 karakter";
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return "Harus mengandung angka";
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Konfirmasi password wajib diisi";
    }
    if (value.length < 8) {
      return "Minimal 8 karakter";
    }
    if (value != _passwordController.text) {
      return "Password tidak sama";
    }
    return null;
  }

  // ================= DIALOG =================

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Syarat & Ketentuan"),
        content: const Text(
          "Dengan menggunakan aplikasi ini, Anda setuju menjaga keamanan akun dan mematuhi semua aturan yang berlaku.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  // ================= REGISTER =================

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap setujui Syarat & Ketentuan")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService().register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result == "success") {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Daftar berhasil")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D5A41),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const Text(
            'Buat Akun',
            style: TextStyle(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Bergabung dan mulai membaca',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 30),

          Expanded(
            child: Material(
              color: const Color(0xFFF2F1ED),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(50),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 30,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    autovalidateMode:
                        AutovalidateMode.onUserInteraction, // 🔥 penting
                    child: Column(
                      children: [
                        buildInputField(
                          label: "Nama Lengkap",
                          hint: "Budi Santoso",
                          controller: _nameController,
                          validator: _validateName,
                        ),
                        buildInputField(
                          label: "Email",
                          hint: "budi@email.com",
                          controller: _emailController,
                          validator: _validateEmail,
                        ),
                        buildInputField(
                          label: "Password",
                          hint: "Min. 8 karakter",
                          isPassword: true,
                          isObscured: _isPasswordObscured,
                          controller: _passwordController,
                          validator: _validatePassword,
                          onToggleVisibility: () {
                            setState(() {
                              _isPasswordObscured = !_isPasswordObscured;
                            });
                          },
                        ),
                        buildInputField(
                          label: "Konfirmasi Password",
                          hint: "Ulangi password",
                          isPassword: true,
                          isObscured: _isConfirmObscured,
                          controller: _confirmPasswordController,
                          validator: _validateConfirmPassword,
                          onToggleVisibility: () {
                            setState(() {
                              _isConfirmObscured = !_isConfirmObscured;
                            });
                          },
                        ),

                        // Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _isAgreed,
                              onChanged: (v) {
                                setState(() => _isAgreed = v ?? false);
                              },
                            ),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  text: "Saya setuju dengan ",
                                  children: [
                                    TextSpan(
                                      text: "Syarat & Ketentuan",
                                      style: const TextStyle(
                                        color: Color(0xFFC7491E),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = _showTermsDialog,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC7491E),
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                )
                              : const Text(
                                  'Daftar Sekarang',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),

                        const SizedBox(height: 20),
                        buildDivider("atau"),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Sudah punya akun? "),
                            buildClickableText(
                              text: "Masuk",
                              onTap: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
