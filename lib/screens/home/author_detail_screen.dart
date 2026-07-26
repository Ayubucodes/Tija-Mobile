import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/loading_overlay.dart';
import 'package:tija/constants/app_color.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/mixins/author_detail_mixin.dart';
import 'package:tija/models/author_model.dart';
import 'package:tija/screens/home/book_detail_screen.dart';
import 'package:tija/states/author_state.dart';
import 'package:tija/states/books_state.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class AuthorDetailScreen extends StatefulWidget {
  final String authorId;
  const AuthorDetailScreen({super.key, required this.authorId});

  @override
  State<AuthorDetailScreen> createState() => _AuthorDetailScreenState();
}

class _AuthorDetailScreenState extends State<AuthorDetailScreen>
    with AuthorDetailMixin {
  @override
  void initState() {
    super.initState();
    loadAuthor(widget.authorId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Consumer<AuthorState>(
      builder: (_, authorState, __) => LoadingOverlay(
        isVisible: authorState.isDetailLoading || isNavigatingToBookDetail,
        child: Scaffold(
          backgroundColor: theme.primaryBackground,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── App bar ──────────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    width / 22,
                    width / 36,
                    width / 22,
                    width / 36,
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
                      Expanded(
                        child: Text(
                          'the author',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: width / 22,
                            fontWeight: FontWeight.w700,
                            color: theme.primaryText,
                          ),
                        ),
                      ),
                      // Spacer to balance the back button
                      SizedBox(width: width / 10),
                    ],
                  ),
                ),

                Expanded(
                  child: Consumer<AuthorState>(
                    builder: (context, authorState, _) {
                      if (authorState.isDetailError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                authorState.detailErrorMessage,
                                style: TextStyle(
                                  fontSize: width / 26,
                                  color: theme.secondaryText,
                                ),
                              ),
                              SizedBox(height: width / 22),
                              ElevatedButton(
                                onPressed: () =>
                                    retryLoadAuthor(widget.authorId),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      final author = authorState.authorDetail;
                      if (author == null) {
                        return Center(
                          child: Text(
                            'Author not found',
                            style: TextStyle(
                              fontSize: width / 26,
                              color: theme.secondaryText,
                            ),
                          ),
                        );
                      }

                      // Only the "Popular Books" list scrolls — the profile
                      // card and section header stay fixed on screen.
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          width / 22,
                          width / 90,
                          width / 22,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Profile card ─────────────────────────────────────
                            Container(
                              padding: EdgeInsets.all(width / 22),
                              decoration: BoxDecoration(
                                color: theme.secondaryBackground,
                                borderRadius: BorderRadius.circular(width / 18),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Avatar
                                      ClipOval(
                                        child: author.profilePictureUrl != null
                                            ? Image.network(
                                                author.profilePictureUrl!,
                                                width: width / 5.5,
                                                height: width / 5.5,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    _buildDefaultAvatar(
                                                      width / 5.5,
                                                    ),
                                              )
                                            : _buildDefaultAvatar(width / 5.5),
                                      ),
                                      SizedBox(width: width / 22),
                                      // Name + rating
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              author.fullName,
                                              style: TextStyle(
                                                fontSize: width / 22,
                                                fontWeight: FontWeight.w700,
                                                color: theme.primaryText,
                                              ),
                                            ),
                                            SizedBox(height: width / 60),
                                            if (author.averageRating != null)
                                              _StarRating(
                                                rating: author.averageRating!,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: width / 20),
                                  // Stats row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _StatItem(
                                        value: author.totalBooks.toString(),
                                        label: 'Books',
                                      ),
                                      _Divider(),
                                      _StatItem(
                                        value: author.reviewCount.toString(),
                                        label: 'Reviews',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: width / 15),

                            // ── Popular Books header ──────────────────────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Popular Books',
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
                            SizedBox(height: width / 22),

                            // ── Books list (scrollable) ───────────────────────────
                            Expanded(
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                padding: EdgeInsets.only(bottom: width / 12),
                                itemCount: author.books.items.length,
                                itemBuilder: (context, index) {
                                  final book = author.books.items[index];
                                  return _PopularBookCard(
                                    book: book,
                                    onTap: () => navigateToBookDetail(book.id),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.defaultSecondaryColor,
      ),
      child: Icon(Iconsax.user, color: Colors.white, size: size / 2.25),
    );
  }
}

// ---------------------------------------------------------------------------
// Popular book card
// ---------------------------------------------------------------------------
class _PopularBookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const _PopularBookCard({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: width / 22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            ClipRRect(
              borderRadius: BorderRadius.circular(width / 30),
              child: book.coverImageUrl != null
                  ? Image.network(
                      book.coverImageUrl!,
                      width: width / 3.5,
                      height: width / 2.6,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultCover(width),
                    )
                  : _buildDefaultCover(width),
            ),
            SizedBox(width: width / 27),
            // Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: width / 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: TextStyle(
                        fontSize: width / 22,
                        fontWeight: FontWeight.w700,
                        color: theme.primaryText,
                      ),
                    ),
                    SizedBox(height: width / 60),
                    Text(
                      book.genres.isNotEmpty ? book.genres.first.name : '',
                      style: TextStyle(
                        fontSize: width / 28,
                        color: theme.secondaryText,
                      ),
                    ),
                    SizedBox(height: width / 36),
                    Text(
                      'TZS ${book.priceTzs.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: width / 26,
                        fontWeight: FontWeight.w700,
                        color: AppColor.defaultSecondaryColor,
                      ),
                    ),
                    SizedBox(height: width / 45),
                    _StarRating(rating: 4.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultCover(double width) {
    return Container(
      width: width / 3.5,
      height: width / 2.6,
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

// ---------------------------------------------------------------------------
// Stat item
// ---------------------------------------------------------------------------
class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: width / 22,
            fontWeight: FontWeight.w700,
            color: theme.primaryText,
          ),
        ),
        SizedBox(height: width / 180),
        Text(
          label,
          style: TextStyle(fontSize: width / 30, color: theme.secondaryText),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: 1,
      height: width / 12,
      color: AppTheme.of(context).lineColor,
    );
  }
}

// ---------------------------------------------------------------------------
// Star rating
// ---------------------------------------------------------------------------
class _StarRating extends StatelessWidget {
  final double rating;
  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return Icon(
            Icons.star_rounded,
            color: const Color(0xFFFFB800),
            size: width / 18,
          );
        } else if (i < rating) {
          return Icon(
            Icons.star_half_rounded,
            color: const Color(0xFFFFB800),
            size: width / 18,
          );
        } else {
          return Icon(
            Icons.star_outline_rounded,
            color: const Color(0xFFFFB800),
            size: width / 18,
          );
        }
      }),
    );
  }
}
