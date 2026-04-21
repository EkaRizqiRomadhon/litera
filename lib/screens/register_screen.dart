import 'package:flutter/material.dart';
import 'dart:math' as math;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureKonfirmasi = true;
  bool _setuju = false;
  bool _isGoogleLoading = false;

  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiController = TextEditingController();

  static const Color hijauTua = Color(0xFF2D5A45);
  static const Color merahBata = Color(0xFFB84130);
  static const Color bgKrem = Color(0xFFF5F0EB);
  static const Color bgInput = Color(0xFFEDEAE5);
  static const Color teksAbu = Color(0xFF888888);
  static const Color teksGelap = Color(0xFF1A1A1A);

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
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
              top: 52,
              bottom: 32,
              left: 24,
              right: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tombol Back
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Buat Akun',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Georgia',
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Center(
                  child: Text(
                    'Bergabung dan mulai membaca',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Body ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),

                  // ── Nama Lengkap ──
                  _buildLabel('Nama Lengkap'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _namaController,
                    hint: 'Budi Santoso',
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 16),

                  // ── Email ──
                  _buildLabel('Email'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'budi@email.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // ── Password ──
                  _buildLabel('Password'),
                  const SizedBox(height: 8),
                  _buildPasswordField(
                    controller: _passwordController,
                    hint: 'Min. 8 karakter',
                    obscure: _obscurePassword,
                    onToggle: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Konfirmasi Password ──
                  _buildLabel('Konfirmasi Password'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _konfirmasiController,
                    hint: 'Ulangi password',
                    obscure: _obscureKonfirmasi,
                  ),
                  const SizedBox(height: 20),

                  // ── Checkbox Syarat & Ketentuan ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: _setuju,
                          onChanged: (val) {
                            setState(() => _setuju = val ?? false);
                          },
                          activeColor: merahBata,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: const BorderSide(color: Color(0xFFCCCCCC)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 13,
                              color: teksGelap,
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(text: 'Saya setuju dengan '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {},
                                  child: const Text(
                                    'Syarat & Ketentuan',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: merahBata,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(text: '\ndan '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {},
                                  child: const Text(
                                    'Kebijakan Privasi',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: merahBata,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Tombol Daftar Sekarang ──
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _setuju
                          ? () {
                              final nama = _namaController.text.trim();
                              final email = _emailController.text.trim();
                              final password = _passwordController.text.trim();
                              final konfirmasi =
                                  _konfirmasiController.text.trim();

                              if (nama.isEmpty ||
                                  email.isEmpty ||
                                  password.isEmpty ||
                                  konfirmasi.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Semua field wajib diisi')),
                                );
                                return;
                              }

                              if (password != konfirmasi) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Password tidak cocok')),
                                );
                                return;
                              }

                              if (password.length < 8) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Password minimal 8 karakter')),
                                );
                                return;
                              }

                              // TODO: proses registrasi (Firebase / API)
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: merahBata,
                        disabledBackgroundColor:
                            merahBata.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Daftar Sekarang',
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

                  // ── Divider "atau" ──
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Color(0xFFCCCCCC))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'atau',
                          style:
                              TextStyle(color: teksAbu, fontSize: 13),
                        ),
                      ),
                      Expanded(child: Divider(color: Color(0xFFCCCCCC))),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Tombol Google ──
                  OutlinedButton(
                    onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                              SizedBox(width: 10),
                              Text(
                                'Daftar dengan Google',
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

                  // ── Sudah punya akun? ──
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Sudah punya akun? ',
                        style: const TextStyle(
                          color: teksAbu,
                          fontSize: 13,
                        ),
                        children: [
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                'Masuk',
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
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: teksGelap,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: teksAbu, fontSize: 14),
        filled: true,
        fillColor: bgInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: teksAbu, fontSize: 14),
        filled: true,
        fillColor: bgInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: TextButton(
          onPressed: onToggle,
          child: Text(
            obscure ? 'Lihat' : 'Sembunyikan',
            style: const TextStyle(
              color: merahBata,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

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

    paint.color = _green;
    canvas.drawArc(rect, _d(35), _d(50), false, paint);

    paint.color = _yellow;
    canvas.drawArc(rect, _d(85), _d(50), false, paint);

    paint.color = _blue;
    canvas.drawArc(rect, _d(135), _d(150), false, paint);

    paint.color = _red;
    canvas.drawArc(rect, _d(285), _d(40), false, paint);

    // Crossbar horizontal (batang G)
    final barRight = cx + outerR;
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - strokeW / 2, barRight - cx, strokeW),
      Paint()..color = _blue..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}