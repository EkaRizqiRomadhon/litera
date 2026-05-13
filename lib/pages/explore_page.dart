import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../models/book_model.dart';
import '../services/google_books_service.dart';
import '../widgets/book_card.dart';
import '../widgets/book_cover_widget.dart';
import '../widgets/empty_state.dart';
import 'detail_book_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isSearchMode = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cat = BookCategory.all[_selectedIndex];
      context.read<BookProvider>().loadCategory(cat.label, cat.query);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    _debounce?.cancel();
    if (val.trim().isEmpty) {
      setState(() => _isSearchMode = false);
      context.read<BookProvider>().clearSearch();
      return;
    }
    setState(() => _isSearchMode = true);
    _debounce = Timer(const Duration(milliseconds: 600), () {
      context.read<BookProvider>().searchBooks(val);
    });
  }

  void _onCategoryTap(int index) {
    if (_selectedIndex == index && !_isSearchMode) return;
    setState(() {
      _selectedIndex = index;
      _isSearchMode = false;
    });
    _searchController.clear();
    context.read<BookProvider>().clearSearch();
    final cat = BookCategory.all[index];
    context.read<BookProvider>().loadCategory(cat.label, cat.query);
  }

  void _openDetail(BookModel book) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => DetailBookPage(book: book)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cari judul, penulis, atau genre...',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2D5A41)),
              suffixIcon: _isSearchMode
                  ? IconButton(icon: const Icon(Icons.close_rounded, color: Colors.grey), onPressed: () { _searchController.clear(); _onSearchChanged(''); FocusScope.of(context).unfocus(); })
                  : null,
              filled: true,
              fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF4F6F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        // Category chips
        if (!_isSearchMode)
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: BookCategory.all.length,
              itemBuilder: (context, i) {
                final isSelected = i == _selectedIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(BookCategory.all[i].label),
                    selected: isSelected,
                    onSelected: (_) => _onCategoryTap(i),
                    backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                    selectedColor: const Color(0xFF2D5A41),
                    labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87), fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: BorderSide.none,
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),
        // Content
        Expanded(
          child: Consumer<BookProvider>(
            builder: (context, prov, _) {
              if (_isSearchMode) {
                if (prov.searchState == LoadState.loading) {
                  return ListView.builder(padding: const EdgeInsets.all(16), itemCount: 5, itemBuilder: (_, _) => const BookListSkeleton());
                }
                if (prov.searchState == LoadState.error) {
                  return ErrorState(message: prov.searchError, onRetry: () => prov.searchBooks(_searchController.text));
                }
                if (prov.searchResults.isEmpty && prov.searchState == LoadState.loaded) {
                  return const EmptyState(icon: Icons.search_off_rounded, title: 'Tidak Ditemukan', message: 'Coba kata kunci yang berbeda atau cek ejaan Anda.');
                }
                return _BookSearchList(books: prov.searchResults, onTap: _openDetail);
              }

              if (prov.categoryState == LoadState.loading) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.55),
                  itemCount: 6,
                  itemBuilder: (_, _) => const BookCardSkeleton(width: double.infinity, height: double.infinity),
                );
              }
              if (prov.categoryState == LoadState.error) {
                return ErrorState(message: prov.categoryError, onRetry: () { final cat = BookCategory.all[_selectedIndex]; prov.loadCategory(cat.label, cat.query); });
              }
              if (prov.categoryBooks.isEmpty && prov.categoryState == LoadState.loaded) {
                return const EmptyState(icon: Icons.library_books_outlined, title: 'Belum Ada Buku', message: 'Tidak ada buku untuk kategori ini.');
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 0.52),
                itemCount: prov.categoryBooks.length,
                itemBuilder: (_, i) => BookCard(book: prov.categoryBooks[i], width: double.infinity, coverHeight: 160, onTap: () => _openDetail(prov.categoryBooks[i])),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BookSearchList extends StatelessWidget {
  final List<BookModel> books;
  final void Function(BookModel) onTap;
  const _BookSearchList({required this.books, required this.onTap});

  Color _colorFromId(String id) {
    const colors = [Color(0xFF2D5A41), Color(0xFF1A4A7A), Color(0xFF7A3A1A), Color(0xFF4A2D7A), Color(0xFF1A6A6A)];
    if (id.isEmpty) return colors[0];
    return colors[id.codeUnitAt(id.length - 1) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (_, i) {
        final book = books[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onTap(book),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    BookCoverWidget(imageUrl: book.bestCover, width: 60, height: 88, borderRadius: 10, fallbackColor: _colorFromId(book.id)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(book.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(book.authorsDisplay, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 6),
                          Row(children: [
                            if (book.averageRating > 0) ...[
                              const Icon(Icons.star_rounded, color: Color(0xFFFACC15), size: 13),
                              const SizedBox(width: 2),
                              Text(book.averageRating.toStringAsFixed(1), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
                              const SizedBox(width: 8),
                            ],
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFF2D5A41).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                              child: Text(book.categoryDisplay, style: const TextStyle(fontSize: 10, color: Color(0xFF2D5A41), fontWeight: FontWeight.w700)),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
