import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isGoogleLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Warna utama dari desain
  static const Color hijauTua = Color(0xFF2D5A45);
  static const Color merahBata = Color(0xFFB84130);
  static const Color bgKrem = Color(0xFFF5F0EB);
  static const Color bgInput = Color(0xFFEDEAE5);
  static const Color teksAbu = Color(0xFF888888);
  static const Color teksGelap = Color(0xFF1A1A1A);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password wajib diisi')),
      );
      return;
    }

    // TODO: handle login (Firebase / API)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login berhasil!')),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    // Simulasi loading — ganti dengan Google Sign-In sungguhan nanti
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isGoogleLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google Sign-In belum dikonfigurasi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgKrem,
      body: Column(
        children: [
          // ── Header Hijau ──
          Container(
            width: double.infinity,
            color: hijauTua,
            padding: const EdgeInsets.only(
              top: 72,
              bottom: 36,
              left: 24,
              right: 24,
            ),
            child: const Column(
              children: [
                Text(
                  'Litera',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontFamily: 'Georgia',
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'BACA. JELAJAH. BERKEMBANG.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ── Body Krem ──
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),

                    // Judul
                    const Text(
                      'Selamat datang',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: teksGelap,
                        fontFamily: 'Georgia',
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Masuk untuk melanjutkan membaca',
                      style: TextStyle(
                        fontSize: 13,
                        color: teksAbu,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Tombol Google ──
                    OutlinedButton(
                      onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFDDDDDD)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: const Size(double.infinity, 52),
                      ),
                      child: _isGoogleLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFF4285F4),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _GoogleIcon(),
                                SizedBox(width: 12),
                                Text(
                                  'Lanjutkan dengan Google',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: teksGelap,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 20),

                    // ── Divider "atau masuk dengan email" ──
                    const Center(
                      child: Text(
                        'atau masuk dengan email',
                        style: TextStyle(
                          fontSize: 13,
                          color: merahBata,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Field Email ──
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 13,
                        color: teksGelap,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'budi@email.com',
                        hintStyle: const TextStyle(
                          color: teksAbu,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: bgInput,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Field Password ──
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 13,
                        color: teksGelap,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: const TextStyle(
                          color: teksAbu,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: bgInput,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        suffixIcon: TextButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          child: Text(
                            _obscurePassword ? 'Lihat' : 'Sembunyikan',
                            style: const TextStyle(
                              color: merahBata,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── Lupa Password ──
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Lupa password?',
                          style: TextStyle(
                            color: merahBata,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Tombol Masuk ──
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: merahBata,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Daftar sekarang ──
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: 'Belum punya akun? ',
                          style: const TextStyle(
                            color: teksAbu,
                            fontSize: 13,
                          ),
                          children: [
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Daftar sekarang',
                                  style: TextStyle(
                                    color: merahBata,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
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

/// Widget logo Google asli 4 warna
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  static const _blue   = Color(0xFF4285F4);
  static const _red    = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green  = Color(0xFF34A853);

  double _d(double deg) => deg * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width * 0.46;
    final innerR = size.width * 0.26;
    final ringR  = (outerR + innerR) / 2;
    final strokeW = outerR - innerR;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: ringR);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.butt;

    // Gap di kanan (east): 325° → 35° (70° gap)
    // Searah jarum jam dari 35°:
    // Green  : 35°  → 85°  (50°)
    // Yellow : 85°  → 135° (50°)
    // Blue   : 135° → 285° (150°)
    // Red    : 285° → 325° (40°)
    paint.color = _green;
    canvas.drawArc(rect, _d(35), _d(50), false, paint);

    paint.color = _yellow;
    canvas.drawArc(rect, _d(85), _d(50), false, paint);

    paint.color = _blue;
    canvas.drawArc(rect, _d(135), _d(150), false, paint);

    paint.color = _red;
    canvas.drawArc(rect, _d(285), _d(40), false, paint);

    // Crossbar horizontal (batang G) dari tengah ke kanan
    final barRight = cx + outerR;
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - strokeW / 2, barRight - cx, strokeW),
      Paint()..color = _blue..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}