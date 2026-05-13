import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import '../models/reading_history_model.dart';
import '../providers/book_provider.dart';
import '../providers/reading_provider.dart';
import '../widgets/book_card.dart';
import '../widgets/book_cover_widget.dart';
import '../widgets/empty_state.dart';
import '../widgets/profile_avatar.dart';
import 'detail_book_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().loadDashboard();
    });
  }

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Selamat Pagi';
    if (h < 15) return 'Selamat Siang';
    if (h < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  void _openDetail(BookModel book) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => DetailBookPage(book: book)));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstName = (user?.displayName ?? 'Pembaca').split(' ').first;

    return RefreshIndicator(
      color: const Color(0xFF2D5A41),
      onRefresh: () => context.read<BookProvider>().loadDashboard(force: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2D5A41), Color(0xFF1E3D2C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_getGreeting()}, $firstName 👋',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Mau baca buku apa\nhari ini?',
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, height: 1.2),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 2)),
                        child: const SmallProfileAvatar(radius: 26),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Search bar tap → ke Explore
                  GestureDetector(
                    onTap: () {
                      // Navigate ke tab Explore (index 1)
                      DefaultTabController.maybeOf(context)?.animateTo(1);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search_rounded, color: Color(0xFF2D5A41), size: 22),
                          SizedBox(width: 12),
                          Text('Cari judul, penulis, atau genre...', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Lanjutkan Membaca (dari Firestore) ──────────────────
            Consumer<ReadingProvider>(
              builder: (context, readProv, _) {
                final continueList = readProv.continueReading;
                if (continueList.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(title: 'Lanjutkan Membaca'),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 155,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: continueList.length,
                        itemBuilder: (_, i) => _ContinueReadingCard(
                          history: continueList[i],
                          isDark: isDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                );
              },
            ),

            // ── Reading Challenge ────────────────────────────────────
            Consumer<ReadingProvider>(
              builder: (context, readProv, _) {
                final finished = readProv.finishedBooks.length;
                final total = 12;
                final progress = (finished / total).clamp(0.0, 1.0);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D5A41).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF2D5A41).withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFF2D5A41).withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.emoji_events_outlined, color: Color(0xFF2D5A41), size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Target Membaca 2025', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text('$finished dari $total buku selesai', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 4,
                          backgroundColor: Colors.black12,
                          color: const Color(0xFF2D5A41),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            // ── Quote of the Day ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kutipan Hari Ini', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : const Color(0xFFF8FBF9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF2D5A41), width: 0.5),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          '"Buku adalah cermin; kamu hanya melihat di dalamnya apa yang sudah ada dalam dirimu."',
                          style: TextStyle(fontStyle: FontStyle.italic, height: 1.5, fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text('— Carlos Ruiz Zafón', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2D5A41))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Popular Books ───────────────────────────────────────
            Consumer<BookProvider>(
              builder: (context, prov, _) => _BookSection(
                title: 'Buku Populer',
                state: prov.dashboardState,
                books: prov.popularBooks,
                onSeeAll: () {},
                onBookTap: _openDetail,
                onRetry: () => prov.loadDashboard(force: true),
                isDark: isDark,
              ),
            ),

            // ── Newest Books ────────────────────────────────────────
            Consumer<BookProvider>(
              builder: (context, prov, _) => _BookSection(
                title: 'Baru Ditambahkan',
                state: prov.dashboardState,
                books: prov.newestBooks,
                onBookTap: _openDetail,
                isDark: isDark,
              ),
            ),

            // ── Recommended ─────────────────────────────────────────
            Consumer<BookProvider>(
              builder: (context, prov, _) {
                if (prov.dashboardState == LoadState.loading) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeader(title: 'Rekomendasi Untukmu'),
                      const SizedBox(height: 14),
                      const HorizontalSkeletonRow(count: 4, cardWidth: 120, cardHeight: 200),
                      const SizedBox(height: 32),
                    ],
                  );
                }
                if (prov.recommendedBooks.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(title: 'Rekomendasi Untukmu', onSeeAll: () {}),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 220,
                      child: HorizontalBookList(books: prov.recommendedBooks, onBookTap: _openDetail),
                    ),
                    const SizedBox(height: 32),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Reusable sub-widgets ─────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: const Text('Lihat semua', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D5A41))),
            ),
        ],
      ),
    );
  }
}

class _BookSection extends StatelessWidget {
  final String title;
  final LoadState state;
  final List<BookModel> books;
  final VoidCallback? onSeeAll;
  final void Function(BookModel) onBookTap;
  final VoidCallback? onRetry;
  final bool isDark;

  const _BookSection({
    required this.title,
    required this.state,
    required this.books,
    required this.onBookTap,
    this.onSeeAll,
    this.onRetry,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: title, onSeeAll: onSeeAll),
        const SizedBox(height: 14),
        if (state == LoadState.loading)
          const HorizontalSkeletonRow(count: 4, cardWidth: 120, cardHeight: 200)
        else if (state == LoadState.error)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ErrorState(message: 'Gagal memuat buku.', onRetry: onRetry),
          )
        else if (books.isEmpty)
          const SizedBox.shrink()
        else
          SizedBox(
            height: 220,
            child: HorizontalBookList(books: books, onBookTap: onBookTap),
          ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  final ReadingHistoryModel history;
  final bool isDark;

  const _ContinueReadingCard({required this.history, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16, bottom: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                BookCoverWidget(
                  imageUrl: history.thumbnail,
                  width: 75,
                  height: 110,
                  borderRadius: 12,
                  fallbackColor: const Color(0xFF2D5A41),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(history.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(history.authors, style: const TextStyle(color: Colors.grey, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: history.progress,
                          minHeight: 6,
                          backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                          color: const Color(0xFF2D5A41),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${history.progressPercent}% selesai', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
                          const Icon(Icons.play_circle_fill, color: Color(0xFF2D5A41), size: 22),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
