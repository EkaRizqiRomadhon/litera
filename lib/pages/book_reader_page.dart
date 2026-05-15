import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:epub_view/epub_view.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../models/book_model.dart';
import '../services/cache_service.dart';
import '../services/reading_history_service.dart';
import '../providers/history_provider.dart';

class BookReaderPage extends StatefulWidget {
  final BookModel book;
  final String? localPath;
  final String? remoteUrl;
  final bool isPdf;

  const BookReaderPage({
    super.key,
    required this.book,
    this.localPath,
    this.remoteUrl,
    required this.isPdf,
  });

  @override
  State<BookReaderPage> createState() => _BookReaderPageState();
}

class _BookReaderPageState extends State<BookReaderPage> {
  // Common states
  bool _isLoading = true;
  bool _isDownloading = false;
  double _downloadProgress = 0;
  String? _filePath;
  String? _error;

  // PDF Controllers
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  PdfViewerController? _pdfController;

  // EPUB Controllers
  EpubController? _epubController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
    _initReader();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    _epubController?.dispose();
    super.dispose();
  }

  Future<void> _initReader() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. Prioritas: File lokal yang sudah ada
      if (widget.localPath != null) {
        _filePath = widget.localPath;
      } 
      // 2. Jika tidak ada localPath, coba download (dan cache)
      else if (widget.remoteUrl != null) {
        setState(() => _isDownloading = true);
        final file = await CacheService.downloadBook(
          widget.book.id, 
          widget.remoteUrl!, 
          widget.isPdf ? 'pdf' : 'epub',
          onProgress: (received, total) {
            if (total != -1) {
              setState(() => _downloadProgress = received / total);
            }
          },
        );
        _filePath = file.path;
      } else {
        throw 'Tidak ada sumber buku yang valid.';
      }

      // 3. Inisialisasi controller spesifik format
      if (!widget.isPdf && _filePath != null) {
        final history = await ReadingHistoryService.getBookHistory(widget.book.id);
        _epubController = EpubController(
          document: EpubDocument.openFile(File(_filePath!)),
          // EPUB usually uses Cfi for position, but we'll try to map it or just start fresh
        );
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isDownloading = false;
        });
      }
    } catch (e) {
      debugPrint('[BookReaderPage] ❌ Init error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isDownloading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _saveProgress(int page, int total) {
    if (total <= 0) return;
    final progress = page / total;
    
    // Update ke Firestore via Service
    ReadingHistoryService.updateProgress(
      widget.book.id, 
      progress: progress, 
      lastPage: page,
    );
    
    // Update Provider untuk UI reaktif (opsional jika sudah realtime stream)
    // HistoryProvider uses watchRecentlyRead (Stream), so it updates automatically

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.book.title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (widget.isPdf)
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () => _pdfViewerKey.currentState?.openBookmarkView(),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isDownloading) {
      return _buildDownloadView();
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_error != null) {
      return _buildErrorView();
    }

    if (widget.isPdf) {
      return _buildPdfReader();
    } else {
      return _buildEpubReader();
    }
  }

  Widget _buildDownloadView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.downloading_rounded, size: 64, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text(
              'Mengunduh Buku...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Buku akan disimpan di cache untuk akses offline.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            LinearProgressIndicator(
              value: _downloadProgress,
              backgroundColor: Colors.grey[200],
              color: AppColors.primary,
              minHeight: 8,
            ),
            const SizedBox(height: 12),
            Text('${(_downloadProgress * 100).toInt()}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Gagal Memuat Buku',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Terjadi kesalahan tidak diketahui',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _initReader,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfReader() {
    return SfPdfViewer.file(
      File(_filePath!),
      key: _pdfViewerKey,
      controller: _pdfController,
      onDocumentLoaded: (details) async {
        final history = await ReadingHistoryService.getBookHistory(widget.book.id);
        if (history != null && history.lastPage > 1) {
          _pdfController?.jumpToPage(history.lastPage);
        }
      },
      onPageChanged: (details) {
        _saveProgress(details.newPageNumber, _pdfController!.pageCount);
      },
    );
  }

  Widget _buildEpubReader() {
    if (_epubController == null) return const Center(child: Text('Gagal inisialisasi EPUB'));
    
    return EpubView(
      controller: _epubController!,
      onDocumentLoaded: (document) {
        debugPrint('[EpubReader] ✅ Loaded: ${document.Title}');
      },
      onChapterChanged: (value) {
        // EPUB progress handling is more complex due to CFI
        // For now, we'll just mark it as opened
        _saveProgress(1, 100); 
      },
    );
  }
}
