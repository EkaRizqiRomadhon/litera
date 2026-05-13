import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import '../providers/bookmark_provider.dart';
import '../providers/reading_provider.dart';
import '../models/reading_history_model.dart';
import '../widgets/book_cover_widget.dart';
import '../widgets/empty_state.dart';
import 'detail_book_page.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: Color(0xFF2D5A41),
            indicatorColor: Color(0xFF2D5A41),
            unselectedLabelColor: Colors.grey,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Koleksi Saya'),
              Tab(text: 'Riwayat Baca'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _BookmarkTab(),
                _HistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab Koleksi (Bookmark) ────────────────────────────────────────────────────

class _BookmarkTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BookmarkProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 4,
            itemBuilder: (_, _) => const BookListSkeleton(),
          );
        }

        if (prov.isEmpty) {
          return const EmptyState(
            icon: Icons.bookmark_outline_rounded,
            title: 'Koleksi Kosong',
            message:
                'Tandai buku favoritmu dengan ikon bookmark\ndan temukan kembali di sini.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: prov.bookmarks.length,
          itemBuilder: (_, i) => _BookmarkCard(
            book: prov.bookmarks[i],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailBookPage(book: prov.bookmarks[i])),
            ),
            onRemove: () => prov.removeBookmark(prov.bookmarks[i].id),
          ),
        );
      },
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _BookmarkCard({
    required this.book,
    required this.onTap,
    required this.onRemove,
  });

  Color _colorFromId(String id) {
    const colors = [Color(0xFF2D5A41), Color(0xFF1A4A7A), Color(0xFF7A3A1A), Color(0xFF4A2D7A), Color(0xFF1A6A6A)];
    if (id.isEmpty) return colors[0];
    return colors[id.codeUnitAt(id.length - 1) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                BookCoverWidget(
                  imageUrl: book.bestCover,
                  width: 65,
                  height: 95,
                  borderRadius: 10,
                  fallbackColor: _colorFromId(book.id),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(book.authorsDisplay, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D5A41).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(book.categoryDisplay, style: const TextStyle(fontSize: 10, color: Color(0xFF2D5A41), fontWeight: FontWeight.w700)),
                          ),
                          if (book.averageRating > 0) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.star_rounded, color: Color(0xFFFACC15), size: 13),
                            const SizedBox(width: 2),
                            Text(book.averageRating.toStringAsFixed(1), style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Hapus bookmark
                IconButton(
                  onPressed: () => _showRemoveDialog(context),
                  icon: const Icon(Icons.bookmark_remove_outlined, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRemoveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus dari Koleksi?'),
        content: Text('Buku "${book.title}" akan dihapus dari koleksi Anda.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () { Navigator.pop(context); onRemove(); },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// ── Tab Riwayat Baca ─────────────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ReadingProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 4,
            itemBuilder: (_, _) => const BookListSkeleton(),
          );
        }

        if (prov.isEmpty) {
          return const EmptyState(
            icon: Icons.history_edu_rounded,
            title: 'Belum Ada Riwayat',
            message: 'Mulai membaca buku untuk melacak\nprogres bacaanmu.',
          );
        }

        final all = [...prov.continueReading, ...prov.finishedBooks];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: all.length,
          itemBuilder: (_, i) => _HistoryCard(
            history: all[i],
            onDelete: () => prov.deleteHistory(all[i].bookId),
          ),
        );
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final ReadingHistoryModel history;
  final VoidCallback onDelete;

  const _HistoryCard({required this.history, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            BookCoverWidget(
              imageUrl: history.thumbnail,
              width: 65,
              height: 95,
              borderRadius: 10,
              fallbackColor: const Color(0xFF2D5A41),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(history.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(history.authors, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 10),
                  if (history.isFinished)
                    Row(children: const [
                      Icon(Icons.check_circle_rounded, color: Color(0xFF2D5A41), size: 16),
                      SizedBox(width: 4),
                      Text('Selesai Dibaca', style: TextStyle(fontSize: 12, color: Color(0xFF2D5A41), fontWeight: FontWeight.w600)),
                    ])
                  else ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: history.progress,
                        minHeight: 5,
                        backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        color: const Color(0xFF2D5A41),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${history.progressPercent}% selesai', style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
