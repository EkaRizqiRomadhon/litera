import 'package:flutter/material.dart';
import 'login_screen.dart'; // sesuaikan import

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const Color hijauTua = Color(0xFF2D5A45);
  static const Color hijauMuda = Color(0xFF3D7A5A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hijauTua,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Ilustrasi Buku ──
              _BookIllustration(),

              const SizedBox(height: 36),

              // ── Logo Litera ──
              const Text(
                'Litera',
                style: TextStyle(
                  fontSize: 46,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Georgia',
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'BACA. JELAJAH. BERKEMBANG.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white60,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(flex: 2),

              // ── Tagline ──
              const Text(
                'Ratusan buku di\ngenggamanmu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.3,
                  fontFamily: 'Georgia',
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Mulai perjalanan membaca hari ini.\nTemukan buku yang tepat untukmu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white60,
                  height: 1.6,
                ),
              ),

              const Spacer(flex: 3),

              // ── Tombol Mulai Sekarang ──
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: hijauTua,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Mulai Sekarang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ilustrasi buku bertumpuk dengan CustomPaint
class _BookIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: _BookPainter(),
      ),
    );
  }
}

class _BookPainter extends CustomPainter {
  static const Color hijauGelap = Color(0xFF1F4433);
  static const Color hijauSedang = Color(0xFF2D5A45);
  static const Color hijauTerang = Color(0xFF3D7A5A);
  static const Color hijauAksen = Color(0xFF4A9068);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // ── Buku kiri (kecil, miring) ──
    _drawBook(
      canvas,
      center: Offset(cx - 60, cy + 10),
      width: 50,
      height: 65,
      angle: -0.3,
      color: hijauGelap,
      opacity: 0.6,
    );

    // ── Buku kanan (kecil, miring) ──
    _drawBook(
      canvas,
      center: Offset(cx + 58, cy + 5),
      width: 44,
      height: 55,
      angle: 0.25,
      color: hijauTerang,
      opacity: 0.5,
    );

    // ── Buku utama (tengah) ──
    _drawMainBook(canvas, Offset(cx, cy - 10), size);

    // ── Bayangan di bawah ──
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 78),
        width: 100,
        height: 14,
      ),
      shadowPaint,
    );
  }

  void _drawBook(
    Canvas canvas, {
    required Offset center,
    required double width,
    required double height,
    required double angle,
    required Color color,
    required double opacity,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final paint = Paint()..color = color.withOpacity(opacity);
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: width,
      height: height,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
    canvas.drawRRect(rrect, paint);

    canvas.restore();
  }

  void _drawMainBook(Canvas canvas, Offset center, Size size) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    final double w = 100;
    final double h = 130;

    // Body buku utama
    final bodyPaint = Paint()
      ..color = const Color(0xFF2A5240).withOpacity(0.85);
    final bodyRect = Rect.fromCenter(
      center: Offset.zero,
      width: w,
      height: h,
    );
    final bodyRRect =
        RRect.fromRectAndRadius(bodyRect, const Radius.circular(10));
    canvas.drawRRect(bodyRRect, bodyPaint);

    // Efek glossy/kaca di atas
    final glossPaint = Paint()
      ..color = Colors.white.withOpacity(0.08);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-w / 2, -h / 2, w, h * 0.45),
        const Radius.circular(10),
      ),
      glossPaint,
    );

    // Garis dekorasi (seperti teks di cover)
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(-22, -22), Offset(22, -22), linePaint);

    final linePaint2 = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(-16, -8), Offset(16, -8), linePaint2);

    // Ikon berlian di tengah bawah
    final diamondPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final diamondPath = Path()
      ..moveTo(0, 18)
      ..lineTo(12, 30)
      ..lineTo(0, 42)
      ..lineTo(-12, 30)
      ..close();
    canvas.drawPath(diamondPath, diamondPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}