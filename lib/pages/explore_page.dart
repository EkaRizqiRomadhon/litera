import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: "Cari judul, penulis, atau ISBN...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
              ),
            ),
            const SizedBox(height: 24),
            
            // Categories
            const Text(
              "Kategori",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCategoryChip("Fiksi", true),
                _buildCategoryChip("Pengembangan Diri", false, isDark),
                _buildCategoryChip("Sains", false, isDark),
                _buildCategoryChip("Biografi", false, isDark),
                _buildCategoryChip("Sejarah", false, isDark),
                _buildCategoryChip("Bisnis", false, isDark),
              ],
            ),
            const SizedBox(height: 24),

            // Trending
            const Text(
              "Sedang Tren Minggu Ini",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  leading: Container(
                    width: 50,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.teal[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.book, color: Colors.white),
                  ),
                  title: Text("Buku Trending ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Penulis Terkenal"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, [bool isDark = false]) {
    return Chip(
      label: Text(label),
      backgroundColor: isSelected 
          ? const Color(0xFF2D5A41) 
          : (isDark ? Colors.grey[800] : Colors.grey[200]),
      labelStyle: TextStyle(
        color: isSelected 
            ? Colors.white 
            : (isDark ? Colors.white : Colors.black87)
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    );
  }
}
