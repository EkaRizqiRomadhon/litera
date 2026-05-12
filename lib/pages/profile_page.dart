import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;

  // --- Edit Nama ---
  void _showEditNameSheet() {
    final user = _auth.currentUser;
    final nameController = TextEditingController(text: user?.displayName ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Nama',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Nama Tampilan',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5A41),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        await user?.updateDisplayName(nameController.text.trim());
                        await user?.reload();
                        if (mounted) {
                          setState(() {});
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nama berhasil diperbarui!')),
                          );
                        }
                      }
                    },
                    child: const Text('Simpan', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Dialog Konfirmasi Logout ---
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar Akun?'),
        content: const Text('Kamu akan keluar dari akun Litera-mu. Yakin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              AuthService().signOut();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  // --- Widget: Kartu Statistik ---
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget: Menu Item ---
  Widget _buildMenuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // ── Avatar & Nama ──────────────────────────────────────────
        const SizedBox(height: 12),
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 52,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                backgroundColor: const Color(0xFF2D5A41).withOpacity(0.15),
                child: user?.photoURL == null
                    ? const Icon(Icons.person, size: 58, color: Color(0xFF2D5A41))
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showEditNameSheet,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2D5A41),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            user?.displayName ?? 'Pengguna Litera',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            user?.email ?? '-',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        const SizedBox(height: 6),
        // Badge verifikasi email
        Center(
          child: Chip(
            avatar: Icon(
              user?.emailVerified == true ? Icons.verified : Icons.warning_amber,
              size: 16,
              color: user?.emailVerified == true ? Colors.green : Colors.orange,
            ),
            label: Text(
              user?.emailVerified == true ? 'Email Terverifikasi' : 'Email Belum Diverifikasi',
              style: TextStyle(
                fontSize: 12,
                color: user?.emailVerified == true ? Colors.green : Colors.orange,
              ),
            ),
            backgroundColor: (user?.emailVerified == true ? Colors.green : Colors.orange)
                .withOpacity(0.1),
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ),

        const SizedBox(height: 28),

        // ── Statistik Membaca ──────────────────────────────────────
        const Text(
          'Statistik Membaca',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard('Buku\nDibaca', '12', Icons.menu_book, const Color(0xFF2D5A41)),
            const SizedBox(width: 10),
            _buildStatCard('Jam\nMembaca', '48', Icons.schedule, Colors.blue),
            const SizedBox(width: 10),
            _buildStatCard('Hari\nBeruntun', '7', Icons.local_fire_department, Colors.orange),
          ],
        ),

        const SizedBox(height: 28),

        // ── Pengaturan Akun ────────────────────────────────────────
        const Text(
          'Akun',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        _buildMenuTile(
          icon: Icons.person_outline,
          iconColor: Colors.blue,
          title: 'Edit Nama',
          subtitle: user?.displayName ?? 'Belum diatur',
          onTap: _showEditNameSheet,
        ),
        _buildMenuTile(
          icon: Icons.email_outlined,
          iconColor: Colors.teal,
          title: 'Email',
          subtitle: user?.email ?? '-',
          trailing: const SizedBox.shrink(),
        ),
        if (user?.emailVerified == false)
          _buildMenuTile(
            icon: Icons.mark_email_unread_outlined,
            iconColor: Colors.orange,
            title: 'Kirim Ulang Verifikasi Email',
            onTap: () async {
              await user?.sendEmailVerification();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email verifikasi telah dikirim!')),
                );
              }
            },
          ),

        const SizedBox(height: 16),

        // ── Pengaturan Tampilan ────────────────────────────────────
        const Text(
          'Tampilan',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, currentMode, _) {
            final isDarkMode =
                currentMode == ThemeMode.dark || (currentMode == ThemeMode.system && isDark);
            return SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              secondary: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: Colors.purple,
                  size: 22,
                ),
              ),
              title: const Text('Tema Gelap', style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(isDarkMode ? 'Aktif' : 'Nonaktif',
                  style: const TextStyle(fontSize: 12)),
              value: isDarkMode,
              activeColor: const Color(0xFF2D5A41),
              onChanged: (value) {
                themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
              },
            );
          },
        ),

        const SizedBox(height: 16),

        // ── Lainnya ────────────────────────────────────────────────
        const Text(
          'Lainnya',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        _buildMenuTile(
          icon: Icons.help_outline,
          iconColor: Colors.orange,
          title: 'Pusat Bantuan',
          onTap: () {},
        ),
        _buildMenuTile(
          icon: Icons.info_outline,
          iconColor: Colors.grey,
          title: 'Tentang Aplikasi',
          subtitle: 'Versi 1.0.0',
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'Litera',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2025 Litera App',
            );
          },
        ),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),

        // ── Tombol Keluar ──────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showLogoutDialog,
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text(
              'Keluar Akun',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
