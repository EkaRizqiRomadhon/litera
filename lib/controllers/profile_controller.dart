import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/image_upload_service.dart';
import '../services/profile_service.dart';

class ProfileController extends ChangeNotifier {
  final _picker = ImagePicker();
  final _uploadService = ImageUploadService();
  final _profileService = ProfileService();

  bool _isLoading = false;
  String? _errorMessage;
  // Timestamp digunakan untuk cache busting, diperbarui setiap kali foto berubah
  int _photoVersion = DateTime.now().millisecondsSinceEpoch;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get photoVersion => _photoVersion;

  // Cache stream agar tidak membuat instance baru setiap kali diakses
  late final Stream<User?> userStream = _profileService.userStream;
  User? get currentUser => _profileService.currentUser;

  // --- Validasi & Pengambilan Gambar ---
  Future<File?> pickImageFromSource(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 50,
      );
      if (picked == null) return null;

      final file = File(picked.path);
      final sizeInBytes = await file.length();

      // Validasi ukuran max 2MB
      if (sizeInBytes > 2 * 1024 * 1024) {
        throw Exception('Ukuran file melebihi batas 2MB.');
      }

      // Validasi format file
      final ext = picked.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png'].contains(ext)) {
        throw Exception('Format file harus JPG, JPEG, atau PNG.');
      }

      return file;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // --- Upload Foto Profil ---
  Future<bool> uploadProfilePhoto(File file) async {
    _setLoading(true);
    try {
      final url = await _uploadService.uploadImage(file);
      await _profileService.updatePhoto(url);
      // Refresh cache buster agar Image.network memuat ulang gambar terbaru
      _photoVersion = DateTime.now().millisecondsSinceEpoch;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal upload foto: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // --- Hapus Foto Profil ---
  Future<bool> deleteProfilePhoto() async {
    _setLoading(true);
    try {
      await _profileService.removePhoto();
      _photoVersion = DateTime.now().millisecondsSinceEpoch;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus foto: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // --- Update Nama ---
  Future<bool> updateName(String name) async {
    _setLoading(true);
    try {
      await _profileService.updateName(name);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal update nama: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // --- Kirim Ulang Email Verifikasi ---
  Future<void> sendVerificationEmail() async {
    await _profileService.sendVerificationEmail();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}