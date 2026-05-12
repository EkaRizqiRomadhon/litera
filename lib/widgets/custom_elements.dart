import 'package:flutter/material.dart';

// 1. Input Field (Update: Perbaikan posisi 'Lihat' dan Padding)
Widget buildInputField({
  required String label,
  required String hint,
  bool isPassword = false,
  bool isObscured = true,
  VoidCallback? onToggleVisibility,
  TextEditingController? controller,
  String? Function(String?)? validator,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
      ),
      const SizedBox(height: 8),

      // 🔥 FIX UTAMA DI SINI
      TextFormField(
        controller: controller,
        obscureText: isPassword ? isObscured : false,
        validator: validator, // 🔥 WAJIB
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          filled: true,
          fillColor: const Color(0xFFEBE8E2),

          // 🔥 ERROR STYLE BIAR JELAS
          errorStyle: const TextStyle(fontSize: 12, color: Colors.red),

          // Password toggle
          suffixIcon: isPassword
              ? Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onToggleVisibility,
                    borderRadius: BorderRadius.circular(15),
                    splashColor: const Color(0xFFC7491E).withValues(alpha: 0.2),
                    highlightColor: const Color(
                      0xFFC7491E,
                    ).withValues(alpha: 0.1),
                    child: Container(
                      width: 70,
                      alignment: Alignment.center,
                      child: Text(
                        isObscured ? 'Lihat' : 'Sembunyi',
                        style: const TextStyle(
                          color: Color(0xFFC7491E),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                )
              : null,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),

          // 🔥 TAMBAHAN BIAR ERROR GAK NGEGESER UI PARAH
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),

      const SizedBox(height: 16),
    ],
  );
}

// 2. Tombol Google (Baru: Requirement Gambar 02)
Widget buildGoogleButton({required VoidCallback onTap}) {
  return OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      side: const BorderSide(color: Colors.black12),
      minimumSize: const Size(double.infinity, 55),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/google.png', width: 24, height: 24
        ),
        const SizedBox(width: 12),
        const Text(
          'Lanjutkan dengan Google',
          style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}

// 3. Garis Pemisah / Divider (Baru: Requirement Gambar 02 & 03)
Widget buildDivider(String text) {
  return Row(
    children: [
      const Expanded(child: Divider(color: Colors.black12, thickness: 1)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          text,
          style: const TextStyle(color: Colors.black45, fontSize: 14),
        ),
      ),
      const Expanded(child: Divider(color: Colors.black12, thickness: 1)),
    ],
  );
}

// 4. Klikable Text (Punya kamu sudah oke, kita rapikan sedikit)
Widget buildClickableText({required String text, required VoidCallback onTap}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFFC7491E),
            fontWeight: FontWeight.w700,
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ),
  );
}
