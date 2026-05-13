import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

/// Service untuk mengambil data dari Google Books API
class GoogleBooksService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  // API Key (kosongkan untuk tanpa key, ada limit request)
  // Untuk production: tambahkan API key Anda di sini
  static const String _apiKey = '';

  static const int _maxResults = 20;

  // ── Internal helper ──────────────────────────────────────────────────
  static String _buildUrl(String query, {int startIndex = 0, int maxResults = _maxResults}) {
    final buffer = StringBuffer('$_baseUrl?q=${Uri.encodeQueryComponent(query)}');
    buffer.write('&maxResults=$maxResults');
    buffer.write('&startIndex=$startIndex');
    buffer.write('&printType=books');
    buffer.write('&langRestrict=id,en');
    if (_apiKey.isNotEmpty) buffer.write('&key=$_apiKey');
    return buffer.toString();
  }

  static List<BookModel> _parseItems(Map<String, dynamic> json) {
    final items = json['items'] as List<dynamic>? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(BookModel.fromJson)
        .where((b) => b.title.isNotEmpty)
        .toList();
  }

  static Future<Map<String, dynamic>> _fetchJson(String url) async {
    final response = await http.get(Uri.parse(url)).timeout(
      const Duration(seconds: 15),
    );
    if (response.statusCode != 200) {
      throw Exception('Google Books API error: ${response.statusCode}');
    }
    return json.decode(response.body) as Map<String, dynamic>;
  }

  // ── Public Methods ───────────────────────────────────────────────────

  /// Cari buku berdasarkan query teks
  static Future<List<BookModel>> searchBooks(
    String query, {
    int startIndex = 0,
    int maxResults = _maxResults,
  }) async {
    if (query.trim().isEmpty) return [];
    final url = _buildUrl(query, startIndex: startIndex, maxResults: maxResults);
    final json = await _fetchJson(url);
    return _parseItems(json);
  }

  /// Ambil buku berdasarkan kategori / subject
  static Future<List<BookModel>> getBooksByCategory(
    String category, {
    int maxResults = _maxResults,
  }) async {
    final url = _buildUrl('subject:$category', maxResults: maxResults);
    final json = await _fetchJson(url);
    return _parseItems(json);
  }

  /// Ambil buku populer (berdasarkan rating tinggi)
  static Future<List<BookModel>> getPopularBooks({
    String language = 'id',
    int maxResults = _maxResults,
  }) async {
    final url = _buildUrl(
      'subject:fiction+bestseller',
      maxResults: maxResults,
    );
    final json = await _fetchJson(url);
    final books = _parseItems(json);
    // Urutkan berdasarkan rating
    books.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    return books;
  }

  /// Ambil buku terbaru (berdasarkan tahun publish)
  static Future<List<BookModel>> getNewestBooks({
    int maxResults = _maxResults,
  }) async {
    final url = '${_buildUrl('subject:fiction', maxResults: maxResults)}'
        '&orderBy=newest';
    final json = await _fetchJson(url);
    return _parseItems(json);
  }

  /// Ambil detail satu buku berdasarkan ID
  static Future<BookModel?> getBookById(String bookId) async {
    final url = _apiKey.isNotEmpty
        ? '$_baseUrl/$bookId?key=$_apiKey'
        : '$_baseUrl/$bookId';
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 15),
      );
      if (response.statusCode != 200) return null;
      final data = json.decode(response.body) as Map<String, dynamic>;
      return BookModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Ambil buku rekomendasi berdasarkan kategori/author buku yang sedang dibaca
  static Future<List<BookModel>> getRelatedBooks(
    BookModel book, {
    int maxResults = 8,
  }) async {
    String query;
    if (book.categories.isNotEmpty) {
      query = 'subject:${book.categories.first}';
    } else if (book.authors.isNotEmpty) {
      query = 'inauthor:${book.authors.first}';
    } else {
      query = book.title.split(' ').take(2).join(' ');
    }
    final url = _buildUrl(query, maxResults: maxResults);
    try {
      final data = await _fetchJson(url);
      final books = _parseItems(data);
      // Hapus buku yang sama dari hasil
      return books.where((b) => b.id != book.id).take(6).toList();
    } catch (_) {
      return [];
    }
  }

  /// Ambil rekomendasi berdasarkan daftar kategori favorit
  static Future<List<BookModel>> getRecommendations({
    List<String> categories = const ['fiction', 'self-help'],
    int maxResults = _maxResults,
  }) async {
    final category = categories[
        DateTime.now().millisecondsSinceEpoch % categories.length];
    return getBooksByCategory(category, maxResults: maxResults);
  }
}

/// Kategori buku yang tersedia di aplikasi
class BookCategory {
  final String label;
  final String query; // query untuk Google Books API

  const BookCategory({required this.label, required this.query});

  static const List<BookCategory> all = [
    BookCategory(label: 'Semua', query: 'bestseller'),
    BookCategory(label: 'Novel', query: 'subject:fiction novel'),
    BookCategory(label: 'Teknologi', query: 'subject:technology computers'),
    BookCategory(label: 'Bisnis', query: 'subject:business economics'),
    BookCategory(label: 'Sejarah', query: 'subject:history indonesia'),
    BookCategory(label: 'Self-Help', query: 'subject:self-help motivation'),
    BookCategory(label: 'Romance', query: 'subject:romance love'),
    BookCategory(label: 'Fantasy', query: 'subject:fantasy magic'),
    BookCategory(label: 'Sains', query: 'subject:science popular'),
    BookCategory(label: 'Biografi', query: 'subject:biography autobiography'),
  ];
}
