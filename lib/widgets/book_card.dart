import 'package:flutter/material.dart';
import '../models/book_model.dart';
import 'book_cover_widget.dart';

/// Card buku vertikal (cover + title + author)
class BookCard extends StatelessWidget {
  final BookModel book;
  final double width;
  final double coverHeight;
  final VoidCallback? onTap;
  final Color? coverFallbackColor;

  const BookCard({
    super.key,
    required this.book,
    this.width = 120,
    this.coverHeight = 160,
    this.onTap,
    this.coverFallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            Stack(
              children: [
                BookCoverWidget(
                  imageUrl: book.bestCover,
                  width: width,
                  height: coverHeight,
                  borderRadius: 12,
                  fallbackColor: coverFallbackColor ?? _colorFromId(book.id),
                ),
                // Ripple
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              book.authorsDisplay,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (book.averageRating > 0) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFACC15), size: 13),
                  const SizedBox(width: 2),
                  Text(
                    book.averageRating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Warna fallback deterministik berdasarkan book id
  Color _colorFromId(String id) {
    const colors = [
      Color(0xFF2D5A41),
      Color(0xFF1A4A7A),
      Color(0xFF7A3A1A),
      Color(0xFF4A2D7A),
      Color(0xFF1A6A6A),
      Color(0xFF6A1A3A),
      Color(0xFF7A4A1A),
      Color(0xFF3A4A7A),
    ];
    if (id.isEmpty) return colors[0];
    return colors[id.codeUnitAt(id.length - 1) % colors.length];
  }
}

/// Row buku horizontal yang reusable
class HorizontalBookList extends StatelessWidget {
  final List<BookModel> books;
  final double cardWidth;
  final double coverHeight;
  final void Function(BookModel)? onBookTap;

  const HorizontalBookList({
    super.key,
    required this.books,
    this.cardWidth = 120,
    this.coverHeight = 160,
    this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: books.length,
      separatorBuilder: (_, _) => const SizedBox(width: 14),
      itemBuilder: (_, i) => BookCard(
        book: books[i],
        width: cardWidth,
        coverHeight: coverHeight,
        onTap: () => onBookTap?.call(books[i]),
      ),
    );
  }
}
