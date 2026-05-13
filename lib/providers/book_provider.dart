import 'package:flutter/foundation.dart';
import '../models/book_model.dart';
import '../services/google_books_service.dart';

/// State untuk satu request API
enum LoadState { idle, loading, loaded, error }

/// Provider untuk semua data buku dari Google Books API
class BookProvider extends ChangeNotifier {
  // ── Dashboard sections ───────────────────────────────────────────────
  List<BookModel> _popularBooks = [];
  List<BookModel> _newestBooks = [];
  List<BookModel> _recommendedBooks = [];

  LoadState _dashboardState = LoadState.idle;
  String _dashboardError = '';

  // ── Explore / Category ───────────────────────────────────────────────
  List<BookModel> _categoryBooks = [];
  LoadState _categoryState = LoadState.idle;
  String _categoryError = '';
  String _selectedCategory = 'Semua';

  // ── Search ───────────────────────────────────────────────────────────
  List<BookModel> _searchResults = [];
  LoadState _searchState = LoadState.idle;
  String _searchError = '';
  String _lastQuery = '';

  // ── Related books (detail page) ──────────────────────────────────────
  List<BookModel> _relatedBooks = [];
  LoadState _relatedState = LoadState.idle;

  // ── Getters ──────────────────────────────────────────────────────────
  List<BookModel> get popularBooks => _popularBooks;
  List<BookModel> get newestBooks => _newestBooks;
  List<BookModel> get recommendedBooks => _recommendedBooks;
  LoadState get dashboardState => _dashboardState;
  String get dashboardError => _dashboardError;
  bool get isDashboardLoading => _dashboardState == LoadState.loading;

  List<BookModel> get categoryBooks => _categoryBooks;
  LoadState get categoryState => _categoryState;
  String get categoryError => _categoryError;
  String get selectedCategory => _selectedCategory;
  bool get isCategoryLoading => _categoryState == LoadState.loading;

  List<BookModel> get searchResults => _searchResults;
  LoadState get searchState => _searchState;
  String get searchError => _searchError;
  bool get isSearchLoading => _searchState == LoadState.loading;
  bool get hasSearchResults => _searchResults.isNotEmpty;

  List<BookModel> get relatedBooks => _relatedBooks;
  LoadState get relatedState => _relatedState;

  // ── Dashboard ────────────────────────────────────────────────────────

  /// Load semua data dashboard sekaligus (popular + newest + recommended)
  Future<void> loadDashboard({bool force = false}) async {
    if (_dashboardState == LoadState.loading) return;
    if (_dashboardState == LoadState.loaded && !force) return;

    _dashboardState = LoadState.loading;
    _dashboardError = '';
    notifyListeners();

    try {
      final results = await Future.wait([
        GoogleBooksService.getPopularBooks(maxResults: 10),
        GoogleBooksService.getNewestBooks(maxResults: 10),
        GoogleBooksService.getRecommendations(
          categories: ['fiction', 'self-help', 'technology'],
          maxResults: 10,
        ),
      ]);

      _popularBooks = results[0];
      _newestBooks = results[1];
      _recommendedBooks = results[2];
      _dashboardState = LoadState.loaded;
    } catch (e) {
      _dashboardState = LoadState.error;
      _dashboardError = _friendlyError(e);
    }

    notifyListeners();
  }

  // ── Explore / Category ───────────────────────────────────────────────

  /// Load buku berdasarkan kategori yang dipilih
  Future<void> loadCategory(String category, String apiQuery) async {
    if (_selectedCategory == category && _categoryState == LoadState.loaded) return;

    _selectedCategory = category;
    _categoryState = LoadState.loading;
    _categoryError = '';
    _categoryBooks = [];
    notifyListeners();

    try {
      List<BookModel> books;
      if (category == 'Semua') {
        books = await GoogleBooksService.getPopularBooks(maxResults: 20);
      } else {
        books = await GoogleBooksService.searchBooks(apiQuery, maxResults: 20);
      }
      _categoryBooks = books;
      _categoryState = LoadState.loaded;
    } catch (e) {
      _categoryState = LoadState.error;
      _categoryError = _friendlyError(e);
    }

    notifyListeners();
  }

  // ── Search ───────────────────────────────────────────────────────────

  /// Cari buku (debounce harus dihandle di UI)
  Future<void> searchBooks(String query) async {
    final q = query.trim();

    if (q.isEmpty) {
      _searchResults = [];
      _searchState = LoadState.idle;
      _lastQuery = '';
      notifyListeners();
      return;
    }

    if (q == _lastQuery && _searchState == LoadState.loaded) return;

    _lastQuery = q;
    _searchState = LoadState.loading;
    _searchError = '';
    notifyListeners();

    try {
      _searchResults = await GoogleBooksService.searchBooks(q, maxResults: 20);
      _searchState = LoadState.loaded;
    } catch (e) {
      _searchState = LoadState.error;
      _searchError = _friendlyError(e);
    }

    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    _searchState = LoadState.idle;
    _lastQuery = '';
    _searchError = '';
    notifyListeners();
  }

  // ── Related books ────────────────────────────────────────────────────

  Future<void> loadRelatedBooks(BookModel book) async {
    _relatedBooks = [];
    _relatedState = LoadState.loading;
    notifyListeners();

    try {
      _relatedBooks = await GoogleBooksService.getRelatedBooks(book);
      _relatedState = LoadState.loaded;
    } catch (_) {
      _relatedState = LoadState.error;
    }

    notifyListeners();
  }

  // ── Helpers ──────────────────────────────────────────────────────────
  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('Failed host lookup')) {
      return 'Tidak ada koneksi internet. Coba lagi.';
    }
    if (msg.contains('TimeoutException')) {
      return 'Waktu koneksi habis. Coba lagi.';
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}
