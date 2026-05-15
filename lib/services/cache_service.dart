import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

/// Service untuk menangani caching ebook secara lokal
class CacheService {
  static final Dio _dio = Dio();

  /// Mendapatkan direktori penyimpanan aplikasi
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Mendapatkan referensi file lokal berdasarkan ID dan ekstensi
  static Future<File> _getLocalFile(String bookId, String extension) async {
    final path = await _localPath;
    final dir = Directory('$path/ebooks');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File('${dir.path}/$bookId.$extension');
  }

  /// Mengecek apakah buku sudah tersimpan di cache
  static Future<File?> getCachedBook(String bookId) async {
    try {
      final path = await _localPath;
      final dir = Directory('$path/ebooks');
      if (!await dir.exists()) return null;

      // Cek PDF
      final pdf = File('${dir.path}/$bookId.pdf');
      if (await pdf.exists()) return pdf;

      // Cek EPUB
      final epub = File('${dir.path}/$bookId.epub');
      if (await epub.exists()) return epub;

      return null;
    } catch (e) {
      debugPrint('[CacheService] ⚠️ Error checking cache: $e');
      return null;
    }
  }

  /// Download buku dan simpan ke cache
  static Future<File> downloadBook(
    String bookId, 
    String url, 
    String extension,
    {ProgressCallback? onProgress}
  ) async {
    final file = await _getLocalFile(bookId, extension);
    
    try {
      debugPrint('[CacheService] 📥 Downloading $bookId from $url');
      await _dio.download(
        url, 
        file.path,
        onReceiveProgress: onProgress,
      );
      debugPrint('[CacheService] ✅ Saved to ${file.path}');
      return file;
    } catch (e) {
      debugPrint('[CacheService] ❌ Download error: $e');
      // Hapus file jika gagal sebagian
      if (await file.exists()) {
        await file.delete();
      }
      rethrow;
    }
  }

  /// Hapus semua cache ebook
  static Future<void> clearCache() async {
    try {
      final path = await _localPath;
      final dir = Directory('$path/ebooks');
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('[CacheService] ⚠️ Error clearing cache: $e');
    }
  }
}
