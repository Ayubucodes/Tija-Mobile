import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/loading_overlay.dart';
import 'package:tija/constants/app_color.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/mixins/author_detail_mixin.dart';
import 'package:tija/models/author_model.dart';
import 'package:tija/screens/home/book_detail_screen.dart';
import 'package:tija/states/author_state.dart';
import 'package:tija/states/books_state.dart';
import 'package:tija/widgets/empty_state.dart';
import 'package:tija/widgets/placeholder.dart';

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
        isVisible: isNavigatingToBookDetail,
        child: Scaffold(
          backgroundColor: theme.primaryBackground,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── App bar ──────────────────────────────────────────────────
                Expanded(
                  child: Consumer<AuthorState>(
                    builder: (context, authorState, _) {
                      if (authorState.isDetailError) {
                        return EmptyState(
                          message: authorState.detailErrorMessage,
                        );
                      }

                      final author = authorState.authorDetail;
                      if (author == null) {
                        return EmptyState(message: 'Author not found');
                      }

                      return Column(
                        children: [
                          // ── App bar ──────────────────────────────────────────────────
                          SafeArea(
                            bottom: false,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                                        onTap: () =>
                                            Navigator.of(context).pop(),
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
                                          "${author.fullName}'s Books",
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
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: theme.lineColor,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: width / 22),

                          // ── Books list ───────────────────────────────────────────────
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                width / 22,
                                width / 90,
                                width / 22,
                                0,
                              ),
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                padding: EdgeInsets.only(bottom: width / 12),
                                itemCount: author.books.items.length,
                                itemBuilder: (context, index) {
                                  final book = author.books.items[index];
                                  return _AuthorBookCard(
                                    book: book,
                                    onTap: () => navigateToBookDetail(book.id),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
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
}

// ---------------------------------------------------------------------------
// Author book card (library-card style)
// ---------------------------------------------------------------------------
class _AuthorBookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const _AuthorBookCard({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;
    final coverHeight = width / 2.6;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: width / 22),
        height: coverHeight,
        padding: EdgeInsets.only(right: width / 25),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.inputFilledColor,
          borderRadius: BorderRadius.circular(width / 27),
          border: Border.all(color: theme.lineColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover — flush against the card's left edge, so its left
            // corners match the card's own radius exactly.
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(width / 27),
                bottomLeft: Radius.circular(width / 27),
              ),
              child: book.coverImageUrl != null
                  ? Image.network(
                      book.coverImageUrl!,
                      width: width / 3.5,
                      height: coverHeight,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => PlaceholderCover(
                        width: width / 3.5,
                        height: coverHeight,
                      ),
                    )
                  : PlaceholderCover(width: width / 3.5, height: coverHeight),
            ),
            SizedBox(width: width / 22),
            // Details — inset from top/bottom so text doesn't touch the
            // card's edges, while the cover stays flush on the left.
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: width / 40),
                child: SizedBox(
                  height: coverHeight - (width / 40) * 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: TextStyle(
                          fontSize: width / 22,
                          fontWeight: FontWeight.w700,
                          color: theme.primaryText,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: width / 70),
                      Text(
                        book.genres.isNotEmpty ? book.genres.first.name : '',
                        style: TextStyle(
                          fontSize: width / 30,
                          color: theme.secondaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: width / 45),
                      Text(
                        'TZS ${book.priceTzs.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: width / 26,
                          fontWeight: FontWeight.w700,
                          color: AppColor.defaultSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
