import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import '../providers/bookmark_provider.dart';
import '../providers/book_provider.dart';
import '../providers/reading_provider.dart';
import '../services/reading_history_service.dart';
import '../widgets/book_card.dart';
import '../widgets/book_cover_widget.dart';
import 'reader_page.dart';

class DetailBookPage extends StatefulWidget {
  final BookModel book;

  const DetailBookPage({super.key, required this.book});

  @override
  State<DetailBookPage> createState() => _DetailBookPageState();
}

class _DetailBookPageState extends State<DetailBookPage> {
  bool _descExpanded = false;

  @override
  void initState() {
    super.initState();
    // Load related books
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().loadRelatedBooks(widget.book);
    });
  }

  void _openReader(BuildContext context) async {
    final book = widget.book;
    // Catat ke history
    await ReadingHistoryService.recordBookOpen(book);

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReaderPage(book: book),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF111111) : const Color(0xFFF8FBF9);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          // ── App Bar dengan cover ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: const Color(0xFF1E3D2C),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background blur cover
                  BookCoverWidget(
                    imageUrl: book.bestCover,
                    width: double.infinity,
                    height: 320,
                    borderRadius: 0,
                    fallbackColor: const Color(0xFF2D5A41),
                  ),
                  // Dark overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Color(0xFF1E3D2C)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Cover + info di tengah bawah
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Cover buku
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: BookCoverWidget(
                            imageUrl: book.bestCover,
                            width: 100,
                            height: 145,
                            borderRadius: 12,
                            fallbackColor: const Color(0xFF2D5A41),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Info dasar
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                book.authorsDisplay,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (book.averageRating > 0) ...[
                                const SizedBox(height: 8),
                                _RatingRow(rating: book.averageRating, count: book.ratingsCount),
                              ],
                              if (book.categoryDisplay.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Text(
                                    book.categoryDisplay,
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Bookmark button
              Consumer<BookmarkProvider>(
                builder: (context, bookmarkProv, _) {
                  final isBookmarked = bookmarkProv.isBookmarked(book.id);
                  return IconButton(
                    onPressed: () async {
                      await bookmarkProv.toggleBookmark(book);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              bookmarkProv.isBookmarked(book.id)
                                  ? '✓ Ditambahkan ke koleksi'
                                  : 'Dihapus dari koleksi',
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF2D5A41),
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                      color: isBookmarked ? const Color(0xFF4ADE80) : Colors.white,
                    ),
                    tooltip: isBookmarked ? 'Hapus bookmark' : 'Tambah bookmark',
                  );
                },
              ),
            ],
          ),

          // ── Body konten ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Tombol Baca ───────────────────────────────────
                  Consumer<ReadingProvider>(
                    builder: (context, readProv, _) {
                      final progress = readProv.progressOf(book.id);
                      final hasHistory = readProv.hasHistory(book.id);
                      return _ReadButtons(
                        book: book,
                        progress: progress,
                        hasHistory: hasHistory,
                        onRead: () => _openReader(context),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // ── Info Grid ─────────────────────────────────────
                  _InfoGrid(book: book, isDark: isDark),

                  const SizedBox(height: 28),

                  // ── Deskripsi ─────────────────────────────────────
                  if (book.description.isNotEmpty) ...[
                    const Text(
                      'Tentang Buku',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      crossFadeState: _descExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: Text(
                        book.description,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.grey),
                      ),
                      secondChild: Text(
                        book.description,
                        style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _descExpanded = !_descExpanded),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF2D5A41),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(_descExpanded ? 'Tampilkan lebih sedikit' : 'Baca selengkapnya'),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Related Books ─────────────────────────────────
                  const Text(
                    'Buku Terkait',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),

          // Related books horizontal
          Consumer<BookProvider>(
            builder: (context, bookProv, _) {
              if (bookProv.relatedState == LoadState.loading) {
                return const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: HorizontalSkeletonRow(count: 4),
                  ),
                );
              }
              if (bookProv.relatedBooks.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox(height: 16));
              }
              return SliverToBoxAdapter(
                child: SizedBox(
                  height: 220,
                  child: HorizontalBookList(
                    books: bookProv.relatedBooks,
                    onBookTap: (related) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailBookPage(book: related),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _RatingRow extends StatelessWidget {
  final double rating;
  final int count;
  const _RatingRow({required this.rating, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (i) {
          if (i < rating.floor()) {
            return const Icon(Icons.star_rounded, color: Color(0xFFFACC15), size: 14);
          } else if (i < rating) {
            return const Icon(Icons.star_half_rounded, color: Color(0xFFFACC15), size: 14);
          }
          return const Icon(Icons.star_outline_rounded, color: Color(0xFFFACC15), size: 14);
        }),
        const SizedBox(width: 4),
        Text(
          '${rating.toStringAsFixed(1)} (${_formatCount(count)})',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11),
        ),
      ],
    );
  }

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}rb';
    return n.toString();
  }
}

class _ReadButtons extends StatelessWidget {
  final BookModel book;
  final double progress;
  final bool hasHistory;
  final VoidCallback onRead;

  const _ReadButtons({
    required this.book,
    required this.progress,
    required this.hasHistory,
    required this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasHistory && progress > 0) ...[
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              color: const Color(0xFF2D5A41),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(progress * 100).toInt()}% sudah dibaca',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
        ],
        if (book.hasPreview || book.hasWebReader)
          FilledButton.icon(
            onPressed: onRead,
            icon: const Icon(Icons.menu_book_rounded),
            label: Text(hasHistory && progress > 0 ? 'Lanjut Membaca' : 'Mulai Membaca'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2D5A41),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          )
        else
          OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.lock_outline_rounded),
            label: const Text('Preview Tidak Tersedia'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey,
              side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
      ],
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final BookModel book;
  final bool isDark;
  const _InfoGrid({required this.book, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _InfoItem(
            icon: Icons.calendar_today_rounded,
            label: 'Terbit',
            value: book.year.isEmpty ? '—' : book.year,
          ),
          _divider(),
          _InfoItem(
            icon: Icons.menu_book_rounded,
            label: 'Halaman',
            value: book.pageCount > 0 ? '${book.pageCount}' : '—',
          ),
          _divider(),
          _InfoItem(
            icon: Icons.language_rounded,
            label: 'Bahasa',
            value: book.language.toUpperCase().isEmpty ? '—' : book.language.toUpperCase(),
          ),
          _divider(),
          _InfoItem(
            icon: Icons.format_list_bulleted_rounded,
            label: 'Genre',
            value: book.categoryDisplay.length > 10
                ? '${book.categoryDisplay.substring(0, 10)}...'
                : book.categoryDisplay,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        height: 40,
        width: 1,
        color: Colors.grey.withValues(alpha: 0.2),
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2D5A41)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}
