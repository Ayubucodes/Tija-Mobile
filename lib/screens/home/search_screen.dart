import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/custom_card.dart';
import 'package:tija/components/loading_overlay.dart';
import 'package:tija/constants/app_asset.dart';
import 'package:tija/constants/app_color.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/mixins/search_mixin.dart';
import 'package:tija/models/books_model.dart';
import 'package:tija/screens/home/book_detail_screen.dart';
import 'package:tija/states/books_state.dart';

// ---------------------------------------------------------------------------
// Hardcoded data
// ---------------------------------------------------------------------------
const _initialTags = <String>[];

// ---------------------------------------------------------------------------
// SearchScreen
// ---------------------------------------------------------------------------
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SearchMixin {
  String? _selectedGenreId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadGenres();
    _loadAllBooks();
    loadRecentSearches();
  }

  Future<void> _loadGenres() async {
    await context.read<BooksState>().onGetGenres();
  }

  Future<void> _loadAllBooks() async {
    await context.read<BooksState>().onGetBooks(pageSize: 100);
  }

  Future<void> _loadBooksByGenre(String genreId) async {
    await context.read<BooksState>().onGetRelatedBooks(genreId);
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
    });

    // Add to recent searches (max 10)
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

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Consumer<BooksState>(
      builder: (_, booksState, __) => LoadingOverlay(
        isVisible: booksState.isLoadingRelated || booksState.isLoading,
        child: Scaffold(
          backgroundColor: theme.primaryBackground,
          extendBody: true,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title ─────────────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    width / 20,
                    width / 22,
                    width / 20,
                    0,
                  ),
                  child: Center(
                    child: Text(
                      'Search Books',
                      style: TextStyle(
                        fontSize: width / 20,
                        fontWeight: FontWeight.w700,
                        color: theme.primaryText,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: width / 22),
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

                // ── Category tabs (hide when searching) ─────────────────────
                if (_searchQuery.isEmpty) ...[
                  SizedBox(
                    height: width / 10,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: width / 20),
                      itemCount: booksState.genres.length,
                      separatorBuilder: (_, __) => SizedBox(width: width / 17),
                      itemBuilder: (_, i) {
                        final genre = booksState.genres[i];
                        final isActive = _selectedGenreId == genre.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = i;
                              _selectedGenreId = genre.id;
                            });
                            _loadBooksByGenre(genre.id);
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                genre.name,
                                style: TextStyle(
                                  fontSize: width / 26,
                                  fontWeight: isActive
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isActive
                                      ? theme.primaryText
                                      : theme.secondaryText,
                                ),
                              ),
                              SizedBox(height: width / 90),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: width / 180,
                                width: isActive ? width / 16 : 0,
                                decoration: BoxDecoration(
                                  color: AppColor.defaultSecondaryColor,
                                  borderRadius: BorderRadius.circular(
                                    width / 180,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: width / 22),
                ],

                // ── Scrollable body ───────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.only(bottom: width / 3.6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // New Book List header
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: width / 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'New Book List',
                                style: TextStyle(
                                  fontSize: width / 22,
                                  fontWeight: FontWeight.w700,
                                  color: theme.primaryText,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'more',
                                    style: TextStyle(
                                      fontSize: width / 28,
                                      color: theme.secondaryText,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: width / 180),
                                  Icon(
                                    Iconsax.arrow_right_3,
                                    size: width / 22,
                                    color: theme.secondaryText,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: width / 25),

                        // Popular books horizontal list
                        _buildBookList(booksState, width, theme),
                        SizedBox(height: width / 15),

                        // Recent Searched header
                        if (recentSearches.isNotEmpty) ...[
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: width / 20,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Recent Searched',
                                    style: TextStyle(
                                      fontSize: width / 24,
                                      fontWeight: FontWeight.w600,
                                      color: theme.primaryText,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: clearRecent,
                                  child: Icon(
                                    Iconsax.trash,
                                    size: width / 18,
                                    color: theme.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: width / 25),

                          // Chip tags
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: width / 20,
                            ),
                            child: Wrap(
                              spacing: width / 38,
                              runSpacing: width / 38,
                              children: recentSearches
                                  .map(
                                    (tag) => GestureDetector(
                                      onTap: () {
                                        searchController.text = tag;
                                        _performSearch(tag);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: width / 20,
                                          vertical: width / 45,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.inputFilledColor,
                                          borderRadius: BorderRadius.circular(
                                            width / 18,
                                          ),
                                          border: Border.all(
                                            color: theme.lineColor,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          tag,
                                          style: TextStyle(
                                            fontSize: width / 28,
                                            fontWeight: FontWeight.w500,
                                            color: theme.primaryText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookList(BooksState booksState, double width, AppTheme theme) {
    List<Item> booksToDisplay;
    String emptyMessage;

    if (_searchQuery.isNotEmpty) {
      // Filter books client-side like more_books_screen
      final searchQuery = _searchQuery.toLowerCase();
      booksToDisplay = booksState.items.where((book) {
        return book.title.toLowerCase().contains(searchQuery) ||
            book.author.fullName.toLowerCase().contains(searchQuery);
      }).toList();
      emptyMessage = 'No books match "$_searchQuery"';
    } else if (_selectedGenreId != null) {
      booksToDisplay = booksState.relatedBooks;
      emptyMessage = 'No books found for this genre';
    } else {
      booksToDisplay = booksState.items;
      emptyMessage = 'No books available';
    }

    if (booksToDisplay.isEmpty) {
      return _buildEmptyState(width, theme, emptyMessage);
    }

    return SizedBox(
      height: width / 1.6,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: width / 20),
        itemCount: booksToDisplay.length,
        separatorBuilder: (_, __) => SizedBox(width: width / 27),
        itemBuilder: (_, i) {
          final book = booksToDisplay[i];
          return BookCard(
            title: book.title,
            author: book.author.fullName,
            price: 'TZS ${book.priceTzs.toStringAsFixed(0)}',
            imageUrl: book.coverImageUrl,
            width: width / 3.2,
            imageHeight: width / 2.4,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    BookDetailScreen(book: BookDetailArgs(bookId: book.id)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(double width, AppTheme theme, String message) {
    return SizedBox(
      height: width / 1.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppAssets.STAR_ICON,
              width: width / 15,
              height: width / 15,
            ),
            SizedBox(height: width / 30),
            Text(
              message,
              style: TextStyle(
                fontSize: width / 26,
                color: theme.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
