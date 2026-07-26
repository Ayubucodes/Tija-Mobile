import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/loading_overlay.dart';
import 'package:tija/constants/app_color.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/mixins/book_detail_mixin.dart';
import 'package:tija/mixins/payment_mixin.dart';
import 'package:tija/models/books_model.dart';
import 'package:tija/screens/home/add_review_screen.dart';
import 'package:tija/states/books_state.dart';
import 'package:tija/states/reader_library_state.dart';
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
  bool _isFavourite = false;
  String? _lastFetchedGenreId;
  bool _isOpeningBook = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksState>().onGetBookById(widget.book.bookId);
      context.read<ReaderLibraryState>().getReaderLibrary();
    });
  }

  void _fetchRelatedBooks(String genreId) {
    if (genreId != _lastFetchedGenreId) {
      _lastFetchedGenreId = genreId;
      context.read<BooksState>().onGetRelatedBooks(genreId);
    }
  }

  @override
  void navigateToReadScreen(String bookId) {
    setState(() => _isOpeningBook = true);
    super.navigateToReadScreen(bookId);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isOpeningBook = false);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    context.read<BooksState>().clearBookDetail();
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
                booksState.isLoadingDetail ||
                booksState.isLoadingRelated ||
                isPaymentProcessing ||
                _isOpeningBook,
            child: Builder(
              builder: (context) {
                if (booksState.isErrorDetail) {
                  return Center(
                    child: Text(
                      booksState.errorMessageDetail,
                      style: TextStyle(color: theme.secondaryText),
                    ),
                  );
                }

                final book = booksState.bookDetail;
                if (book == null) {
                  return const SizedBox.shrink();
                }

                final genre = book.genres.isNotEmpty
                    ? book.genres.first.name
                    : 'Unknown';

                return Column(
                  children: [
                    _HeroHeader(
                      book: book,
                      genre: genre,
                      isFavourite: _isFavourite,
                      onFavouriteTap: () =>
                          setState(() => _isFavourite = !_isFavourite),
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
// Hero header — cover centered on top, details centered below
// ---------------------------------------------------------------------------
class _HeroHeader extends StatelessWidget {
  final BookDetail book;
  final String genre;
  final bool isFavourite;
  final VoidCallback onFavouriteTap;
  final VoidCallback onBackTap;
  final VoidCallback onReadBookTap;

  const _HeroHeader({
    required this.book,
    required this.genre,
    required this.isFavourite,
    required this.onFavouriteTap,
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
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  _CircleIconButton(
                    icon: isFavourite ? Iconsax.heart5 : Iconsax.heart,
                    iconColor: isFavourite ? Colors.red : null,
                    onTap: onFavouriteTap,
                  ),
                ],
              ),
              SizedBox(height: width / 16),

              // Centered book cover
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
                      child: Image.network(
                        book.coverImageUrl,
                        width: width / 2.0,
                        height: width / 1.9,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => PlaceholderCover(
                          width: width / 2.6,
                          height: width / 1.9,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: width / 20),

              // Title, centered
              Text(
                book.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: width / 16,
                  fontWeight: FontWeight.w700,
                  color: theme.primaryText,
                ),
              ),
              SizedBox(height: width / 60),

              // // Genre badge, centered
              // Container(
              //   padding: EdgeInsets.symmetric(
              //     horizontal: width / 22,
              //     vertical: width / 70,
              //   ),
              //   decoration: BoxDecoration(
              //     color: theme.inputFilledColor,
              //     borderRadius: BorderRadius.circular(width / 18),
              //   ),
              //   child: Text(
              //     genre,
              //     style: TextStyle(
              //       fontSize: width / 30,
              //       fontWeight: FontWeight.w500,
              //       color: theme.secondaryText,
              //     ),
              //   ),
              // ),
              // SizedBox(height: width / 18),

              // // Author row, centered
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     ClipOval(
              //       child: Container(
              //         width: width / 10,
              //         height: width / 10,
              //         color: AppColor.defaultSecondaryColor.withValues(
              //           alpha: 0.2,
              //         ),
              //         child: Icon(
              //           Iconsax.user,
              //           size: width / 20,
              //           color: AppColor.defaultSecondaryColor,
              //         ),
              //       ),
              //     ),
              //     SizedBox(width: width / 40),
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Text(
              //           book.author.fullName,
              //           style: TextStyle(
              //             fontSize: width / 28,
              //             fontWeight: FontWeight.w600,
              //             color: theme.primaryText,
              //           ),
              //         ),
              //         Text(
              //           'Author',
              //           style: TextStyle(
              //             fontSize: width / 33,
              //             color: theme.secondaryText,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
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

  const _AboutTab({
    required this.book,
    required this.onFetchRelatedBooks,
    required this.lastFetchedGenreId,
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
          Text(
            book.description,
            style: TextStyle(
              fontSize: width / 26,
              height: 1.6,
              color: theme.secondaryText,
            ),
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
              Row(
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

              // Only show loading if we're fetching for this specific genre
              if (booksState.isLoadingRelated &&
                  genreId == lastFetchedGenreId) {
                return SizedBox(height: width / 1.6);
              }

              final relatedBooks = booksState.relatedBooks
                  .where((b) => b.id != book.id)
                  .take(5)
                  .toList();

              if (relatedBooks.isEmpty && !booksState.isLoadingRelated) {
                return SizedBox(
                  height: width / 1.6,
                  child: Center(child: Text('No related books found')),
                );
              }

              return SizedBox(
                height: width / 1.6,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: relatedBooks.length,
                  separatorBuilder: (_, __) => SizedBox(width: width / 27),
                  itemBuilder: (_, i) =>
                      _RelatedBookCard(book: relatedBooks[i]),
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
                    builder: (_) =>
                        AddReviewScreen(book: BookDetailArgs(bookId: book.id)),
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
          Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: width / 26,
              color: AppColor.defaultSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Related book card
// ---------------------------------------------------------------------------
class _RelatedBookCard extends StatelessWidget {
  final Item book;
  const _RelatedBookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;
    final price = 'Tsh ${book.priceTzs.toStringAsFixed(0)}';

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              BookDetailScreen(book: BookDetailArgs(bookId: book.id)),
        ),
      ),
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
                    book.coverImageUrl,
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
  final Color? iconColor;
  final double size;

  const _CircleIconButton({
    required this.icon,
    this.onTap,
    this.iconColor,
    this.size = 25,
  });

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
        child: Icon(icon, size: size, color: iconColor ?? theme.primaryText),
      ),
    );
  }
}
