import 'package:flutter/material.dart';

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
            tabs: [
              Tab(text: "Sedang Dibaca"),
              Tab(text: "Selesai"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildBookList("Sedang Dibaca", context),
                _buildBookList("Selesai", context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookList(String status, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 65,
                height: 95,
                decoration: BoxDecoration(
                  color: Colors.indigoAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.library_books, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Buku $status ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    const Text("Nama Penulis", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 12),
                    if (status == "Sedang Dibaca") ...[
                      LinearProgressIndicator(
                        value: 0.2 * (index + 1),
                        backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                        color: const Color(0xFF2D5A41),
                      ),
                      const SizedBox(height: 8),
                      Text("${(20 * (index + 1))}% Selesai", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ] else ...[
                      const Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star_half, color: Colors.amber, size: 18),
                        ],
                      ),
                    ]
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
