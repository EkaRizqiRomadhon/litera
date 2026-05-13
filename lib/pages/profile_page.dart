import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../auth_service.dart';
import '../controllers/profile_controller.dart';
import '../main.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/stat_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfileView();
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ProfileController>(
      builder: (context, controller, _) {
        // Tampilkan error dari controller jika ada
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (controller.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(controller.errorMessage!),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
            controller.clearError();
          }
        });

        return StreamBuilder<User?>(
          stream: controller.userStream,
          initialData: controller.currentUser,
          builder: (context, snapshot) {
            final user = snapshot.data;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                const SizedBox(height: 12),
                _buildAvatarSection(context, controller, user),
                const SizedBox(height: 28),
                _buildSectionTitle('Statistik Membaca'),
                const SizedBox(height: 12),
                _buildStats(),
                const SizedBox(height: 28),
                _buildSectionTitle('Akun'),
                const SizedBox(height: 4),
                _buildAccountSection(context, controller, user),
                const SizedBox(height: 16),
                _buildSectionTitle('Tampilan'),
                const SizedBox(height: 4),
                _buildThemeSwitch(isDark),
                const SizedBox(height: 16),
                _buildSectionTitle('Lainnya'),
                const SizedBox(height: 4),
                _buildOtherSection(context),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 8),
                _buildLogoutButton(context),
                const SizedBox(height: 20),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAvatarSection(BuildContext context, ProfileController controller, User? user) {
    return Column(
      children: [
        ProfileAvatar(
          photoUrl: user?.photoURL,
          photoVersion: controller.photoVersion,
          isLoading: controller.isLoading,
          onTap: () => _showImageSourceSheet(context, controller, user),
        ),
        const SizedBox(height: 14),
        Text(user?.displayName ?? 'Pengguna Litera', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(user?.email ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 8),
        Chip(
          avatar: Icon(user?.emailVerified == true ? Icons.verified : Icons.warning_amber, size: 16, color: user?.emailVerified == true ? Colors.green : Colors.orange),
          label: Text(user?.emailVerified == true ? 'Email Terverifikasi' : 'Email Belum Diverifikasi', style: TextStyle(fontSize: 12, color: user?.emailVerified == true ? Colors.green : Colors.orange)),
          backgroundColor: (user?.emailVerified == true ? Colors.green : Colors.orange).withValues(alpha: 0.1),
          side: BorderSide.none,
        ),
      ],
    );
  }

  Widget _buildStats() {
    return const Row(
      children: [
        StatCard(label: 'Buku\nDibaca', value: '12', icon: Icons.menu_book, color: Color(0xFF2D5A41)),
        SizedBox(width: 10),
        StatCard(label: 'Jam\nMembaca', value: '48', icon: Icons.schedule, color: Colors.blue),
        SizedBox(width: 10),
        StatCard(label: 'Hari\nBeruntun', value: '7', icon: Icons.local_fire_department, color: Colors.orange),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context, ProfileController controller, User? user) {
    return Column(
      children: [
        ProfileMenuTile(
          icon: Icons.person_outline,
          iconColor: Colors.blue,
          title: 'Edit Nama',
          subtitle: user?.displayName ?? 'Belum diatur',
          onTap: () => _showEditNameDialog(context, controller),
        ),
        ProfileMenuTile(icon: Icons.email_outlined, iconColor: Colors.teal, title: 'Email', subtitle: user?.email ?? '-', trailing: const SizedBox.shrink()),
        if (user?.emailVerified == false)
          ProfileMenuTile(
            icon: Icons.mark_email_unread_outlined,
            iconColor: Colors.orange,
            title: 'Kirim Ulang Verifikasi Email',
            onTap: () async {
              await controller.sendVerificationEmail();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email verifikasi telah dikirim!')));
            },
          ),
      ],
    );
  }

  Widget _buildThemeSwitch(bool isDark) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        final isDarkMode = currentMode == ThemeMode.dark || (currentMode == ThemeMode.system && isDark);
        return SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          secondary: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, color: Colors.purple, size: 22),
          ),
          title: const Text('Tema Gelap', style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(isDarkMode ? 'Aktif' : 'Nonaktif', style: const TextStyle(fontSize: 12)),
          value: isDarkMode,
          activeThumbColor: const Color(0xFF2D5A41),
          onChanged: (value) => themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light,
        );
      },
    );
  }

  Widget _buildOtherSection(BuildContext context) {
    return Column(
      children: [
        ProfileMenuTile(icon: Icons.help_outline, iconColor: Colors.orange, title: 'Pusat Bantuan', onTap: () {}),
        ProfileMenuTile(
          icon: Icons.info_outline,
          iconColor: Colors.grey,
          title: 'Tentang Aplikasi',
          subtitle: 'Versi 1.0.0',
          onTap: () => showAboutDialog(context: context, applicationName: 'Litera', applicationVersion: '1.0.0', applicationLegalese: '© 2025 Litera App'),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text('Keluar Akun', style: TextStyle(fontSize: 16, color: Colors.red)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600));
  }

  void _showImageSourceSheet(BuildContext context, ProfileController controller, User? user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(padding: EdgeInsets.all(16), child: Text('Pilih Foto Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndPreview(context, controller, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndPreview(context, controller, ImageSource.gallery);
              },
            ),
            if (user?.photoURL != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Hapus Foto', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(context, controller);
                },
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndPreview(BuildContext context, ProfileController controller, ImageSource source) async {
    final file = await controller.pickImageFromSource(source);
    if (file == null || !context.mounted) return;
    _showPreviewDialog(context, controller, file);
  }

  void _showPreviewDialog(BuildContext context, ProfileController controller, File file) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Preview Foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(file, height: 200, width: 200, fit: BoxFit.cover)),
            const SizedBox(height: 10),
            const Text('Gunakan foto ini sebagai profil Anda?', textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2D5A41)),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await controller.uploadProfilePhoto(file);
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Foto profil berhasil diperbarui!' : (controller.errorMessage ?? 'Gagal upload.')), backgroundColor: success ? Colors.green : Colors.red, behavior: SnackBarBehavior.floating));
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProfileController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Foto?'),
        content: const Text('Foto profil Anda akan dihapus dan diganti dengan avatar default.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await controller.deleteProfilePhoto();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto profil dihapus.')));
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, ProfileController controller) {
    final nameController = TextEditingController(text: controller.currentUser?.displayName ?? '');
    final formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Nama', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(controller: nameController, autofocus: true, decoration: InputDecoration(labelText: 'Nama Tampilan', prefixIcon: const Icon(Icons.person_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama tidak boleh kosong' : null),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2D5A41), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(ctx);
                      final success = await controller.updateName(nameController.text.trim());
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Nama berhasil diperbarui!' : (controller.errorMessage ?? 'Gagal update nama.')), backgroundColor: success ? Colors.green : Colors.red, behavior: SnackBarBehavior.floating));
                    }
                  },
                  child: const Text('Simpan', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar Akun?'),
        content: const Text('Kamu akan keluar dari akun Litera-mu. Yakin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () { Navigator.pop(ctx); AuthService().signOut(); }, child: const Text('Keluar')),
        ],
      ),
    );
  }
}
