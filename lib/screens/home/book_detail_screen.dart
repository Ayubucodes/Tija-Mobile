import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/loading_overlay.dart';
import 'package:tija/constants/app_asset.dart';
import 'package:tija/constants/app_color.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/mixins/book_detail_mixin.dart';
import 'package:tija/mixins/payment_mixin.dart';
import 'package:tija/models/books_model.dart';
import 'package:tija/screens/home/add_review_screen.dart';
import 'package:tija/screens/home/more_books_screen.dart';
import 'package:tija/states/books_state.dart';
import 'package:tija/states/reader_library_state.dart';
import 'package:tija/utils/app_util.dart';
import 'package:tija/widgets/empty_state.dart';
import 'package:tija/widgets/placeholder.dart';

// ---------------------------------------------------------------------------
// Public model
// ---------------------------------------------------------------------------
class BookDetailArgs {
  final String bookId;

  const BookDetailArgs({required this.bookId});
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class BookDetailScreen extends StatefulWidget {
  final BookDetailArgs book;
  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen>
    with SingleTickerProviderStateMixin, BookDetailController, PaymentMixin {
  late final TabController _tabController;
  String? _lastFetchedGenreId;
  String? _lastFetchedReviewsBookId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReaderLibraryState>().getReaderLibrary();
    });
  }

  void _onTabChanged() {
    if (_tabController.index == 1) {
      final book = context.read<BooksState>().bookDetail;
      if (book != null && book.id != _lastFetchedReviewsBookId) {
        _lastFetchedReviewsBookId = book.id;
        context.read<BooksState>().onGetReviews(book.id);
      }
    }
  }

  void _fetchRelatedBooks(String genreId) {
    if (genreId != _lastFetchedGenreId) {
      _lastFetchedGenreId = genreId;
      context.read<BooksState>().onGetRelatedBooks(genreId);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    context.read<BooksState>().clearBookDetail();
    context.read<BooksState>().clearReviews();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Consumer<BooksState>(
        builder: (context, booksState, _) {
          return LoadingOverlay(
            isVisible:
                isPaymentProcessing ||
                isNavigatingToReadScreen ||
                isNavigatingToBookDetail,
            // booksState.isLoadingReviews,
            child: Builder(
              builder: (context) {
                if (booksState.isErrorDetail) {
                  return Center(
                    child: EmptyState(
                      message: 'Book details will be displayed here',
                    ),
                  );
                }

                final book = booksState.bookDetail;
                if (book == null) {
                  return const SizedBox.shrink();
                }

                final genre = book.genres.isNotEmpty
                    ? book.genres.first.name
                    : '';

                return Column(
                  children: [
                    _HeroHeader(
                      book: book,
                      genre: genre,
                      onRefreshTap: () async {
                        await context
                            .read<ReaderLibraryState>()
                            .getReaderLibrary();
                        // Show success toast message
                        AppUtil.showToastMessage(
                          message: 'Successfully refreshed',
                          isError: false,
                        );
                      },
                      onBackTap: () => Navigator.of(context).pop(),
                      onReadBookTap: () => navigateToReadScreen(book.id),
                    ),
                    _BookTabBar(controller: _tabController),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _AboutTab(
                            book: book,
                            onFetchRelatedBooks: _fetchRelatedBooks,
                            lastFetchedGenreId: _lastFetchedGenreId,
                            onNavigateToBookDetail: (bookId, {genreId}) =>
                                navigateToBookDetail(bookId, genreId: genreId),
                          ),
                          _ReviewsTab(book: book),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer2<BooksState, ReaderLibraryState>(
        builder: (context, booksState, readerLibraryState, _) {
          final book = booksState.bookDetail;
          if (book == null) return const SizedBox.shrink();
          final price = 'Tsh ${book.priceTzs.toStringAsFixed(0)}';
          final hasAccess = readerLibraryState.hasBookAccess(book.id);
          return _BuyNowBar(
            price: price,
            bookId: book.id,
            hasAccess: hasAccess,
            onReadBookTap: () => navigateToReadScreen(book.id),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Floating price + small Buy Now button (no enclosing container/background)
// ---------------------------------------------------------------------------
class _BuyNowBar extends StatelessWidget {
  final String price;
  final String bookId;
  final bool hasAccess;
  final VoidCallback onReadBookTap;
  const _BuyNowBar({
    required this.price,
    required this.bookId,
    required this.hasAccess,
    required this.onReadBookTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        width / 15,
        width / 40,
        width / 15,
        (width / 30) + bottomInset,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Price floats bottom-left
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasAccess ? 'Owned' : 'Price',
                style: TextStyle(
                  fontSize: width / 34,
                  color: theme.secondaryText,
                ),
              ),
              SizedBox(height: width / 200),
              Text(
                hasAccess ? 'You own this book' : price,
                style: TextStyle(
                  fontSize: width / 20,
                  fontWeight: FontWeight.w700,
                  color: AppColor.defaultSecondaryColor,
                ),
              ),
            ],
          ),
          // Buy Now / Read button floats bottom-right
          GestureDetector(
            onTap: hasAccess
                ? onReadBookTap
                : () {
                    final state = context
                        .findAncestorStateOfType<_BookDetailScreenState>();
                    state?.showPhoneNumberBottomSheet(bookId);
                  },
            child: Container(
              height: width / 11,
              padding: EdgeInsets.symmetric(horizontal: width / 12),
              decoration: BoxDecoration(
                color: AppColor.defaultSecondaryColor,
                borderRadius: BorderRadius.circular(width / 9),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.defaultSecondaryColor.withValues(
                      alpha: 0.35,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                hasAccess ? 'Read' : 'Buy Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width / 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero header — cover on the left, genre / author / rating stacked on the
// right (matches the reference layout).
// ---------------------------------------------------------------------------
class _HeroHeader extends StatelessWidget {
  final BookDetail book;
  final String genre;
  final VoidCallback onRefreshTap;
  final VoidCallback onBackTap;
  final VoidCallback onReadBookTap;

  const _HeroHeader({
    required this.book,
    required this.genre,
    required this.onRefreshTap,
    required this.onBackTap,
    required this.onReadBookTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;
    return Container(
      color: theme.secondaryBackground,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            width / 20,
            width / 30,
            width / 20,
            width / 28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top nav row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleIconButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: onBackTap,
                    size: width / 10.5,
                  ),
                  _CircleIconButton(icon: Iconsax.refresh, onTap: onRefreshTap),
                ],
              ),
              SizedBox(height: width / 16),

              // Cover on the left, details stacked on the right
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book cover
                  Hero(
                    tag: 'book-cover-${book.title}',
                    child: GestureDetector(
                      onTap: () {},
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(width / 22),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(width / 22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: book.coverImageUrl != null
                              ? Image.network(
                                  book.coverImageUrl!,
                                  width: width / 2.6,
                                  height: width / 1.9,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      PlaceholderCover(
                                        width: width / 2.6,
                                        height: width / 1.9,
                                      ),
                                )
                              : PlaceholderCover(
                                  width: width / 2.6,
                                  height: width / 1.9,
                                ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: width / 18),

                  // Details column: title, genre badge, author, rating
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: width / 20),

                        // Title
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: width / 20,
                            fontWeight: FontWeight.w700,
                            color: theme.primaryText,
                          ),
                        ),
                        SizedBox(height: width / 28),

                        // Genre badge
                        if (genre.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: width / 22,
                              vertical: width / 70,
                            ),
                            decoration: BoxDecoration(
                              color: theme.alternate,
                              borderRadius: BorderRadius.circular(width / 18),
                            ),
                            child: Text(
                              genre,
                              style: TextStyle(
                                fontSize: width / 30,
                                fontWeight: FontWeight.w500,
                                color: theme.secondaryText,
                              ),
                            ),
                          ),
                        SizedBox(height: width / 20),

                        // Author row
                        Row(
                          children: [
                            ClipOval(
                              child: Container(
                                width: width / 10,
                                height: width / 10,
                                color: AppColor.defaultSecondaryColor
                                    .withValues(alpha: 0.2),
                                child: Icon(
                                  Iconsax.user,
                                  size: width / 20,
                                  color: AppColor.defaultSecondaryColor,
                                ),
                              ),
                            ),
                            SizedBox(width: width / 40),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    book.author.fullName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: width / 28,
                                      fontWeight: FontWeight.w600,
                                      color: theme.primaryText,
                                    ),
                                  ),
                                  Text(
                                    'Author',
                                    style: TextStyle(
                                      fontSize: width / 33,
                                      color: theme.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: width / 20),

                        // // Star rating
                        // _StarRating(
                        //   rating: book.rating,
                        //   size: width / 24,
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab bar
// ---------------------------------------------------------------------------
class _BookTabBar extends StatelessWidget {
  final TabController controller;
  const _BookTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;
    return Container(
      color: theme.secondaryBackground,
      child: TabBar(
        controller: controller,
        labelColor: AppColor.defaultSecondaryColor,
        unselectedLabelColor: theme.secondaryText,
        indicatorColor: AppColor.defaultSecondaryColor,
        indicatorWeight: 2.5,
        labelStyle: TextStyle(
          fontSize: width / 26,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: width / 26,
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'About Book'),
          Tab(text: 'Reviews'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// About tab
// ---------------------------------------------------------------------------
class _AboutTab extends StatelessWidget {
  final BookDetail book;
  final Function(String) onFetchRelatedBooks;
  final String? lastFetchedGenreId;
  final Function(String, {String? genreId}) onNavigateToBookDetail;

  const _AboutTab({
    required this.book,
    required this.onFetchRelatedBooks,
    required this.lastFetchedGenreId,
    required this.onNavigateToBookDetail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        width / 20,
        width / 16,
        width / 20,
        width / 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              fontSize: width / 22,
              fontWeight: FontWeight.w700,
              color: theme.primaryText,
            ),
          ),
          SizedBox(height: width / 36),
          _DescriptionWidget(
            description: book.description,
            width: width,
            theme: theme,
          ),
          SizedBox(height: width / 13),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'You May Like This',
                style: TextStyle(
                  fontSize: width / 22,
                  fontWeight: FontWeight.w700,
                  color: theme.primaryText,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => MoreBooksScreen()));
                },
                child: Row(
                  children: [
                    Text(
                      'More',
                      style: TextStyle(
                        fontSize: width / 28,
                        color: theme.secondaryText,
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
              ),
            ],
          ),
          SizedBox(height: width / 22),
          Consumer<BooksState>(
            builder: (context, booksState, _) {
              // Fetch related books by genre only if genre ID changed
              final genreId = book.genres.isNotEmpty
                  ? book.genres.first.id
                  : null;
              if (genreId != null && genreId != lastFetchedGenreId) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onFetchRelatedBooks(genreId);
                });
              }

              if (booksState.isLoadingRelated &&
                  genreId == lastFetchedGenreId) {
                return SizedBox(
                  height: width / 2.6,
                  child: Center(
                    child: Image.asset(
                      AppAssets.LOADING_GIF,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              }

              final relatedBooks = booksState.relatedBooks
                  .where((b) => b.id != book.id)
                  .take(5)
                  .toList();

              if (relatedBooks.isEmpty && !booksState.isLoadingRelated) {
                return SizedBox(
                  height: width / 2.6,
                  child: Center(
                    child: EmptyState(
                      message: 'Most related books will be displayed here',
                    ),
                  ),
                );
              }

              return SizedBox(
                height: width / 1.6,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: relatedBooks.length,
                  separatorBuilder: (_, __) => SizedBox(width: width / 27),
                  itemBuilder: (_, i) => _RelatedBookCard(
                    book: relatedBooks[i],
                    genreId: genreId,
                    onTap: onNavigateToBookDetail,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reviews tab
// ---------------------------------------------------------------------------
class _ReviewsTab extends StatelessWidget {
  final BookDetail book;
  const _ReviewsTab({required this.book});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;
    return Consumer<BooksState>(
      builder: (context, booksState, _) {
        // Fetch reviews when tab is first accessed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!booksState.isLoadingReviews && booksState.reviews == null) {
            booksState.onGetReviews(book.id);
          }
        });

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            width / 20,
            width / 16,
            width / 20,
            width / 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reviews',
                    style: TextStyle(
                      fontSize: width / 24,
                      fontWeight: FontWeight.w600,
                      color: theme.primaryText,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddReviewScreen(
                          book: BookDetailArgs(bookId: book.id),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.edit,
                          size: width / 22,
                          color: AppColor.defaultSecondaryColor,
                        ),
                        SizedBox(width: width / 90),
                        Text(
                          'Add Review',
                          style: TextStyle(
                            fontSize: width / 28,
                            fontWeight: FontWeight.w600,
                            color: AppColor.defaultSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: width / 22),

              // Loading state
              if (booksState.isLoadingReviews)
                SizedBox(
                  height: width / 2,
                  child: Center(
                    child: Image.asset(
                      AppAssets.LOADING_GIF,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

              // Error state
              if (booksState.isErrorReviews && !booksState.isLoadingReviews)
                SizedBox(
                  height: width / 2,
                  child: Center(
                    child: EmptyState(
                      message: booksState.errorMessageReviews.isNotEmpty
                          ? booksState.errorMessageReviews
                          : 'Failed to load reviews',
                    ),
                  ),
                ),

              // Empty state
              if (!booksState.isLoadingReviews &&
                  !booksState.isErrorReviews &&
                  booksState.reviewItems.isEmpty)
                SizedBox(
                  height: width / 2,
                  child: Center(
                    child: EmptyState(
                      message: 'Most reviews will be displayed here',
                      iconSize: width / 16,
                    ),
                  ),
                ),

              // Reviews list
              if (!booksState.isLoadingReviews &&
                  !booksState.isErrorReviews &&
                  booksState.reviewItems.isNotEmpty)
                Column(
                  children: [
                    ...booksState.reviewItems.map(
                      (review) => _ReviewCard(review: review),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Review card
// ---------------------------------------------------------------------------
class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(bottom: width / 22),
      padding: EdgeInsets.all(width / 22),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(width / 27),
        border: Border.all(color: theme.lineColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewer info and rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Reviewer name
              Row(
                children: [
                  ClipOval(
                    child: Container(
                      width: width / 12,
                      height: width / 12,
                      color: AppColor.defaultSecondaryColor.withValues(
                        alpha: 0.2,
                      ),
                      child: Icon(
                        Iconsax.user,
                        size: width / 24,
                        color: AppColor.defaultSecondaryColor,
                      ),
                    ),
                  ),
                  SizedBox(width: width / 36),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.reviewerName,
                        style: TextStyle(
                          fontSize: width / 28,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryText,
                        ),
                      ),
                      Text(
                        _formatDate(review.createdAt),
                        style: TextStyle(
                          fontSize: width / 34,
                          color: theme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Star rating
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < review.rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: const Color(0xFFFFB800),
                    size: width / 28,
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: width / 36),

          // Comment
          Text(
            review.comment,
            style: TextStyle(
              fontSize: width / 26,
              height: 1.5,
              color: theme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// ---------------------------------------------------------------------------
// Related book card
// ---------------------------------------------------------------------------
class _RelatedBookCard extends StatelessWidget {
  final Item book;
  final String? genreId;
  final Function(String, {String? genreId}) onTap;
  const _RelatedBookCard({
    required this.book,
    this.genreId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;
    final price = 'Tsh ${book.priceTzs.toStringAsFixed(0)}';

    return GestureDetector(
      onTap: () => onTap(book.id, genreId: genreId),
      child: SizedBox(
        width: width / 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(width / 30),
                  child: Image.network(
                    book.coverImageUrl ?? '',
                    width: width / 3,
                    height: width / 2.5,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        PlaceholderCover(width: width / 3, height: width / 2.5),
                  ),
                ),
              ],
            ),
            SizedBox(height: width / 51),
            Text(
              price,
              style: TextStyle(
                fontSize: width / 30,
                fontWeight: FontWeight.w700,
                color: AppColor.defaultSecondaryColor,
              ),
            ),
            SizedBox(height: width / 180),
            Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: width / 30,
                fontWeight: FontWeight.w500,
                color: theme.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Star rating
// ---------------------------------------------------------------------------
class _StarRating extends StatelessWidget {
  final double rating;
  final double size;
  const _StarRating({required this.rating, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return Icon(
            Icons.star_rounded,
            color: const Color(0xFFFFB800),
            size: size,
          );
        } else if (i < rating) {
          return Icon(
            Icons.star_half_rounded,
            color: const Color(0xFFFFB800),
            size: size,
          );
        } else {
          return Icon(
            Icons.star_outline_rounded,
            color: const Color(0xFFFFB800),
            size: size,
          );
        }
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Circle icon button
// ---------------------------------------------------------------------------
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  const _CircleIconButton({required this.icon, this.onTap, this.size = 25});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.inputFilledColor,
          shape: BoxShape.circle,
          border: Border.all(color: theme.lineColor, width: 1.5),
        ),
        child: Icon(icon, size: size, color: theme.primaryText),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Description widget with see more/see less
// ---------------------------------------------------------------------------
class _DescriptionWidget extends StatefulWidget {
  final String description;
  final double width;
  final dynamic theme;

  const _DescriptionWidget({
    required this.description,
    required this.width,
    required this.theme,
  });

  @override
  State<_DescriptionWidget> createState() => _DescriptionWidgetState();
}

class _DescriptionWidgetState extends State<_DescriptionWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final words = widget.description.split(' ');
    final hasMoreThan37Words = words.length > 37;
    final shouldShowToggle = hasMoreThan37Words;

    if (!shouldShowToggle) {
      return Text(
        widget.description,
        style: TextStyle(
          fontSize: widget.width / 26,
          height: 1.6,
          color: widget.theme.secondaryText,
        ),
      );
    }

    final displayedText = _isExpanded
        ? widget.description
        : words.take(37).join(' ') + '...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayedText,
          style: TextStyle(
            fontSize: widget.width / 26,
            height: 1.6,
            color: widget.theme.secondaryText,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isExpanded ? 'See less' : 'See more',
                style: TextStyle(
                  fontSize: widget.width / 28,
                  fontWeight: FontWeight.w600,
                  color: AppColor.defaultSecondaryColor,
                ),
              ),
              SizedBox(width: widget.width / 90),
              Icon(
                _isExpanded ? Iconsax.arrow_up_2 : Iconsax.arrow_down_2,
                size: widget.width / 28,
                color: AppColor.defaultSecondaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
