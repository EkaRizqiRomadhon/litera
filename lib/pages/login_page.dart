import 'package:flutter/material.dart';
import 'package:litera2/auth_service.dart';
import '../widgets/custom_elements.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscured = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ================= RESET PASSWORD =================
  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reset Password"),
          content: TextField(
            controller: _emailController,
            decoration: const InputDecoration(hintText: "Masukkan email"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                final email = _emailController.text.trim();

                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Email tidak boleh kosong")),
                  );
                  return;
                }

                final result = await AuthService().resetPassword(email);

                if (!context.mounted) return;

                Navigator.pop(context);

                if (result == "success") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Link reset password dikirim ke email"),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(result)));
                }
              },
              child: const Text("Kirim"),
            ),
          ],
        );
      },
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF2D5A41),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: const [
                    Text(
                      'Litera',
                      style: TextStyle(
                        fontSize: 42,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'BACA. JELAJAH. BERKEMBANG.',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              Material(
                color: const Color(0xFFF2F1ED),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(50),
                  bottom: Radius.circular(50),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 35,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selamat datang',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // GOOGLE LOGIN
                      buildGoogleButton(
                        onTap: () async {
                          String result = await AuthService()
                              .signInWithGoogle();

                          if (!context.mounted) return;

                          if (result == "success") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Berhasil masuk dengan Google!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else if (result != "Login dibatalkan") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Gagal login: $result"),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 20),
                      buildDivider("atau email"),
                      const SizedBox(height: 20),

                      // EMAIL
                      buildInputField(
                        label: "Email",
                        hint: "budi@email.com",
                        controller: _emailController,
                      ),

                      // PASSWORD
                      buildInputField(
                        label: "Password",
                        hint: "••••••••",
                        isPassword: true,
                        controller: _passwordController,
                        isObscured: _isObscured,
                        onToggleVisibility: () {
                          setState(() => _isObscured = !_isObscured);
                        },
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: buildClickableText(
                          text: "Lupa password?",
                          onTap: _showResetDialog, // 
                        ),
                      ),

                      const SizedBox(height: 25),

                      ElevatedButton(
                        onPressed: () async {
                          final email = _emailController.text.trim();
                          final password = _passwordController.text.trim();

                          if (email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Email dan password tidak boleh kosong",
                                ),
                              ),
                            );
                            return;
                          }

                          String result = await AuthService().login(
                            email,
                            password,
                          );

                          if (!context.mounted) return;

                          if (result == "success") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Berhasil Masuk!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC7491E),
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Belum punya akun? "),
                          buildClickableText(
                            text: "Daftar sekarang",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
