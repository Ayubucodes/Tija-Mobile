import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/book_card_shimmer.dart';
import 'package:tija/components/custom_card.dart';
import 'package:tija/components/loading_overlay.dart';
import 'package:tija/constants/app_asset.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/mixins/search_mixin.dart';
import 'package:tija/models/books_model.dart';
import 'package:tija/screens/home/more_books_screen.dart';
import 'package:tija/states/books_state.dart';
import 'package:tija/widgets/empty_state.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with SearchMixin {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksState>().onGetBooks();
      context.read<BooksState>().getMostPopularBooks();
    });
  }

  Future<void> onRefresh() async {
    await context.read<BooksState>().onGetBooks();
    await context.read<BooksState>().getMostPopularBooks();
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
    });

    if (query.trim().isNotEmpty && !recentSearches.contains(query)) {
      recentSearches.insert(0, query);
      if (recentSearches.length > 10) {
        recentSearches.removeLast();
      }
      saveRecentSearches();
    }
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      searchController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  List<Item> _filterBooks(List<Item> books) {
    if (_searchQuery.isEmpty) return books;
    final searchQuery = _searchQuery.toLowerCase();
    return books.where((book) {
      return book.title.toLowerCase().contains(searchQuery) ||
          book.author.fullName.toLowerCase().contains(searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      extendBody: true,
      body: LoadingOverlay(
        isVisible: isNavigatingToBookDetail,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Top bar ───────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.only(
                  left: width / 20,
                  right: width / 20,
                  top: width / 25,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Today's Deal",
                        style: TextStyle(
                          fontSize: width / 18,
                          fontWeight: FontWeight.w700,
                          color: theme.primaryText,
                        ),
                      ),
                    ),
                    Image.asset(AppAssets.AVATAR_ICON, width: 30, height: 30),
                  ],
                ),
              ),
              SizedBox(height: width / 25),

              // ── Search bar ────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width / 20),
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
                        size: width / 18,
                      ),
                      SizedBox(width: width / 45),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) => _performSearch(value),
                          style: TextStyle(
                            fontSize: width / 26,
                            color: theme.primaryText,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search Here',
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
                      GestureDetector(
                        onTap: _clearSearch,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: width / 30),
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
              SizedBox(height: width / 16),

              // ── Scrollable body ───────────────────────────────────────────
              Expanded(
                child: RefreshIndicator(
                  onRefresh: onRefresh,
                  displacement: 20,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.only(bottom: width / 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Best Selling — driven by BooksState
                        _SectionHeader(
                          title: 'New Book List',
                          onMoreTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MoreBooksScreen(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: width / 25),
                        Consumer<BooksState>(
                          builder: (context, booksState, _) {
                            final items = _filterBooks(booksState.items);

                            if (booksState.isLoading) {
                              return BookCardShimmerList(
                                // height: width / 1.5,
                                itemWidth: width / 3,
                                imageHeight: width / 2.3,
                              );
                            }

                            if (items.isEmpty) {
                              return SizedBox(
                                height: width / 1.5,
                                child: Center(
                                  child: EmptyState(
                                    message: _searchQuery.isNotEmpty
                                        ? 'Please No books match "$_searchQuery"'
                                        : (booksState.isError
                                              ? booksState.errorMessage
                                              : 'Please No books available'),
                                  ),
                                ),
                              );
                            }

                            return SizedBox(
                              height: width / 1.5,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(
                                  horizontal: width / 20,
                                  vertical: width / 200,
                                ),
                                itemCount: items.length > 5 ? 5 : items.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(width: width / 24),
                                itemBuilder: (_, i) {
                                  final item = items[i];
                                  final title = item.title;
                                  final author = item.author.fullName;
                                  final price = item.priceTzs;
                                  final imageUrl = item.coverImageUrl ?? '';
                                  return Center(
                                    child: BookCard(
                                      title: title,
                                      author: author,
                                      price: price,
                                      imageUrl: imageUrl,
                                      isNew: i == 0,
                                      onTap: () =>
                                          navigateToBookDetail(item.id),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        SizedBox(height: width / 20),

                        // Most Popular — same API data, second half
                        _SectionHeader(
                          title: 'Most Popular',
                          onMoreTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MoreBooksScreen(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: width / 25),
                        Consumer<BooksState>(
                          builder: (context, booksState, _) {
                            final items = booksState.mostPopularItems;

                            if (booksState.isLoadingMostPopular) {
                              return BookCardShimmerList(
                                // height: width / 1.6,
                                itemWidth: width / 2.8,
                                imageHeight: width / 2.2,
                              );
                            }

                            if (items.isEmpty)
                              return EmptyState(
                                message: 'Popular Books will be displayed here',
                              );

                            return SizedBox(
                              height: width / 1.6,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(
                                  horizontal: width / 20,
                                  vertical: width / 200,
                                ),
                                itemCount: items.length > 5 ? 5 : items.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(width: width / 24),
                                itemBuilder: (_, i) {
                                  final item = items[i];
                                  final title = item.title;
                                  final author = item.author.fullName;
                                  final price = item.priceTzs;
                                  final imageUrl = item.coverImageUrl ?? '';
                                  return Center(
                                    child: BookCard(
                                      title: title,
                                      author: author,
                                      price: price,
                                      imageUrl: imageUrl,
                                      width: width / 2.8,
                                      // imageHeight: width / 2.2,
                                      onTap: () =>
                                          navigateToBookDetail(item.id),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        SizedBox(height: width / 18),
                      ],
                    ),
                  ),
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
// Private widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onMoreTap;
  const _SectionHeader({required this.title, this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width / 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: width / 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.of(context).primaryText,
              ),
            ),
          ),
          GestureDetector(
            onTap: onMoreTap,
            child: Row(
              children: [
                Text(
                  'More',
                  style: TextStyle(
                    fontSize: width / 28,
                    color: AppTheme.of(context).secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: width / 200),
                Icon(
                  Iconsax.arrow_right_3,
                  size: width / 22,
                  color: AppTheme.of(context).secondaryText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _IconCircleButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width / 9,
        height: width / 9,
        decoration: BoxDecoration(
          color: AppTheme.of(context).inputFilledColor,
          borderRadius: BorderRadius.circular(width / 30),
        ),
        child: Icon(
          icon,
          color: AppTheme.of(context).primaryText,
          size: width / 18,
        ),
      ),
    );
  }
}
