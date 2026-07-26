import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/loading_overlay.dart';
import 'package:tija/constants/app_asset.dart';
import 'package:tija/constants/app_color.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/mixins/search_mixin.dart';
import 'package:tija/models/books_model.dart';
import 'package:tija/screens/home/book_detail_screen.dart';
import 'package:tija/states/books_state.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class MoreBooksScreen extends StatefulWidget {
  const MoreBooksScreen({super.key});

  @override
  State<MoreBooksScreen> createState() => _MoreBooksScreenState();
}

class _MoreBooksScreenState extends State<MoreBooksScreen> with SearchMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksState>().onGetBooks(pageSize: 50);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: LoadingOverlay(
        isVisible: isNavigatingToBookDetail,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── App bar with title and search ─────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                  width / 22,
                  width / 45,
                  width / 22,
                  width / 45,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: width / 10,
                        height: width / 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.secondaryBackground,
                        ),
                        child: Icon(
                          Icons.chevron_left_rounded,
                          color: theme.primaryText,
                          size: width / 16,
                        ),
                      ),
                    ),
                    SizedBox(width: width / 38),
                    Expanded(
                      child: Text(
                        'Books',
                        style: TextStyle(
                          fontSize: width / 22,
                          fontWeight: FontWeight.w700,
                          color: theme.primaryText,
                        ),
                      ),
                    ),
                    SizedBox(width: width / 10),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: theme.lineColor),
              SizedBox(height: width / 22),

              // ── Search bar ────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(width / 22, 0, width / 22, 0),
                child: Container(
                  height: width / 8,
                  decoration: BoxDecoration(
                    color: theme.inputFilledColor,
                    borderRadius: BorderRadius.circular(width / 27),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: width / 30),
                      Icon(
                        Iconsax.search_normal,
                        color: theme.secondaryText,
                        size: width / 22,
                      ),
                      SizedBox(width: width / 45),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: (_) => setState(() {}),
                          style: TextStyle(
                            fontSize: width / 26,
                            color: theme.primaryText,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search books...',
                            hintStyle: TextStyle(
                              color: theme.secondaryText,
                              fontSize: width / 26,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            searchController.clear();
                            setState(() {});
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: width / 30,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: theme.secondaryText,
                              size: width / 22,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: width / 22),

              // ── Books grid ────────────────────────────────────────────────
              Expanded(
                child: Consumer<BooksState>(
                  builder: (context, booksState, _) {
                    if (booksState.isLoading) {
                      return Center(
                        child: Image.asset(
                          AppAssets.LOADING_GIF,
                          width: width / 7,
                          height: width / 7,
                        ),
                      );
                    }

                    if (booksState.isError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              booksState.errorMessage,
                              style: TextStyle(
                                fontSize: width / 26,
                                color: theme.secondaryText,
                              ),
                            ),
                            SizedBox(height: width / 22),
                            ElevatedButton(
                              onPressed: () =>
                                  booksState.onGetBooks(pageSize: 50),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (booksState.items.isEmpty) {
                      return Center(
                        child: Text(
                          'No books found',
                          style: TextStyle(
                            fontSize: width / 26,
                            color: theme.secondaryText,
                          ),
                        ),
                      );
                    }

                    // Filter books based on search query
                    final searchQuery = searchController.text.toLowerCase();
                    final filteredBooks = booksState.items.where((book) {
                      return book.title.toLowerCase().contains(searchQuery) ||
                          book.author.fullName.toLowerCase().contains(
                            searchQuery,
                          );
                    }).toList();

                    if (filteredBooks.isEmpty) {
                      return Center(
                        child: Text(
                          'No books match "${searchController.text}"',
                          style: TextStyle(
                            fontSize: width / 26,
                            color: theme.secondaryText,
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        width / 22,
                        0,
                        width / 22,
                        width / 12,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: width / 30,
                        mainAxisSpacing: width / 22,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: filteredBooks.length,
                      itemBuilder: (_, i) => _BookCard(
                        book: filteredBooks[i],
                        onTap: () => navigateToBookDetail(filteredBooks[i].id),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Book card
// ---------------------------------------------------------------------------
class _BookCard extends StatelessWidget {
  final Item book;
  final VoidCallback onTap;

  const _BookCard({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(width / 30),
              child: Image.network(
                book.coverImageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultCover(width),
              ),
            ),
          ),
          SizedBox(height: width / 45),
          // Title
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: width / 26,
              fontWeight: FontWeight.w600,
              color: theme.primaryText,
            ),
          ),
          SizedBox(height: width / 90),
          // Author
          Text(
            book.author.fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: width / 30, color: theme.secondaryText),
          ),
          SizedBox(height: width / 90),
          // Price
          Text(
            'TZS ${book.priceTzs.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: width / 28,
              fontWeight: FontWeight.w700,
              color: AppColor.defaultSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultCover(double width) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width / 30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD4A77A), Color(0xFF9D6638)],
        ),
      ),
      child: Center(
        child: Icon(Iconsax.book, color: Colors.white54, size: width / 10),
      ),
    );
  }
}
