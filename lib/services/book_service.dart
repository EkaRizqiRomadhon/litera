import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../pages/book_reader_page.dart';
import '../pages/reader_page.dart';
import 'google_books_service.dart';
import 'reading_history_service.dart';
import 'cache_service.dart';

class BookService {
  /// Mendapatkan link yang bisa dibaca (PDF atau EPUB)
  /// Prioritas: PDF > EPUB
  static String? getReadableLink(BookModel book) {
    if (book.pdfDownloadLink != null && book.pdfDownloadLink!.isNotEmpty) {
      return book.pdfDownloadLink;
    }
    if (book.epubDownloadLink != null && book.epubDownloadLink!.isNotEmpty) {
      return book.epubDownloadLink;
    }
    return null;
  }

  /// Mengecek apakah buku bisa dibaca di dalam aplikasi
  static bool isReadable(BookModel book) {
    return getReadableLink(book) != null;
  }

  /// Menangani aksi baca buku
  static Future<void> openBook(BuildContext context, BookModel book) async {
    // 1. Cek cache lokal terlebih dahulu
    final cachedFile = await CacheService.getCachedBook(book.id);
    
    if (cachedFile != null) {
      debugPrint('[BookService] 📂 Opening cached file: ${cachedFile.path}');
      if (context.mounted) {
        _navigateToNativeReader(context, book, localPath: cachedFile.path);
      }
      return;
    }

    // 2. Jika tidak ada cache, cek link download (PDF/EPUB)
    final link = getReadableLink(book);
    if (link != null) {
      final isPdf = (book.pdfDownloadLink != null && book.pdfDownloadLink!.isNotEmpty);
      
      if (context.mounted) {
        _navigateToNativeReader(context, book, remoteUrl: link, isPdf: isPdf);
      }
    } else {
      // 3. Fallback ke Web Reader / Preview via ReaderPage
      debugPrint('[BookService] 🌐 No direct link, falling back to web reader');
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReaderPage(book: book),
          ),
        );
      }
    }
  }

  /// Helper untuk navigasi ke native reader
  static void _navigateToNativeReader(
    BuildContext context, 
    BookModel book, 
    {String? localPath, String? remoteUrl, bool isPdf = true}
  ) {
    // Update history
    ReadingHistoryService.recordBookOpen(book);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookReaderPage(
          book: book,
          localPath: localPath,
          remoteUrl: remoteUrl,
          isPdf: isPdf,
        ),
      ),
    );
  }

  /// Membuka buku berdasarkan ID (untuk riwayat/bookmark)
  static Future<void> openBookById(BuildContext context, String bookId) async {
    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final book = await GoogleBooksService.getBookById(bookId);
      if (!context.mounted) return;
      Navigator.pop(context); // Tutup loading

      if (book != null) {
        await openBook(context, book);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengambil data buku.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }
}
