import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // Data dummy buku yang sedang dibaca
  static const List<Map<String, dynamic>> _readingBooks = [
    {
      'title': 'Laskar Pelangi',
      'author': 'Andrea Hirata',
      'progress': 0.65,
      'color': Color(0xFF2D5A41),
    },
    {
      'title': 'Bumi Manusia',
      'author': 'Pramoedya Ananta Toer',
      'progress': 0.3,
      'color': Color(0xFF1A4A7A),
    },
    {
      'title': 'Atomic Habits',
      'author': 'James Clear',
      'progress': 0.85,
      'color': Color(0xFF7A3A1A),
    },
  ];

  // Data dummy rekomendasi buku
  static const List<Map<String, dynamic>> _recommendedBooks = [
    {
      'title': 'Sapiens',
      'author': 'Yuval Noah Harari',
      'genre': 'Sejarah',
      'color': Color(0xFF4A2D7A),
    },
    {
      'title': 'Rich Dad Poor Dad',
      'author': 'Robert Kiyosaki',
      'genre': 'Bisnis',
      'color': Color(0xFF7A4A1A),
    },
    {
      'title': 'Filosofi Teras',
      'author': 'Henry Manampiring',
      'genre': 'Pengembangan Diri',
      'color': Color(0xFF1A6A6A),
    },
    {
      'title': 'The Alchemist',
      'author': 'Paulo Coelho',
      'genre': 'Fiksi',
      'color': Color(0xFF6A1A3A),
    },
  ];

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstName = (user?.displayName ?? 'Pembaca').split(' ').first;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Sapaan ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2D5A41), Color(0xFF4A8C62)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_getGreeting()}, $firstName 👋',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Apa yang ingin kamu baca hari ini?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Search bar di dalam header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari judul atau penulis...',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Ringkasan Aktivitas ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildStatChip(Icons.menu_book, '12', 'Buku', Colors.green),
                const SizedBox(width: 10),
                _buildStatChip(Icons.schedule, '48 jam', 'Baca', Colors.blue),
                const SizedBox(width: 10),
                _buildStatChip(Icons.local_fire_department, '7 hari', 'Streak', Colors.orange),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Lanjutkan Membaca ──────────────────────────────────────
          _buildSectionHeader('Lanjutkan Membaca', onSeeAll: () {}),
          const SizedBox(height: 12),
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _readingBooks.length,
              itemBuilder: (context, i) {
                final book = _readingBooks[i];
                return _buildReadingCard(book, isDark);
              },
            ),
          ),

          const SizedBox(height: 28),

          // ── Rekomendasi Untukmu ────────────────────────────────────
          _buildSectionHeader('Rekomendasi Untukmu', onSeeAll: () {}),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recommendedBooks.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, i) {
                final book = _recommendedBooks[i];
                return _buildRecommendCard(book, isDark);
              },
            ),
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }

  // ── Widget: Chip Statistik ─────────────────────────────────────────
  Widget _buildStatChip(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14, color: color)),
                Text(label,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Widget: Header Seksi ───────────────────────────────────────────
  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: onSeeAll,
            child: const Text('Lihat semua',
                style: TextStyle(fontSize: 13, color: Color(0xFF2D5A41))),
          ),
        ],
      ),
    );
  }

  // ── Widget: Kartu Sedang Dibaca ────────────────────────────────────
  Widget _buildReadingCard(Map<String, dynamic> book, bool isDark) {
    final progress = book['progress'] as double;
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cover buku
          Container(
            width: 70,
            height: 100,
            decoration: BoxDecoration(
              color: book['color'] as Color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  book['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  book['author'] as String,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  color: const Color(0xFF2D5A41),
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progress * 100).toInt()}% selesai',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D5A41),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Lanjut',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Widget: Kartu Rekomendasi ──────────────────────────────────────
  Widget _buildRecommendCard(Map<String, dynamic> book, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover
          Container(
            width: double.infinity,
            height: 110,
            decoration: BoxDecoration(
              color: book['color'] as Color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Icon(Icons.auto_stories, color: Colors.white54, size: 40),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  book['author'] as String,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D5A41).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    book['genre'] as String,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF2D5A41),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
