import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/action_button.dart';
import 'package:tija/components/loading_overlay.dart';
import 'package:tija/constants/app_color.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/mixins/review_mixin.dart';
import 'package:tija/models/books_model.dart';
import 'package:tija/screens/home/book_detail_screen.dart';
import 'package:tija/states/books_state.dart';
import 'package:tija/widgets/empty_state.dart';
import 'package:tija/widgets/placeholder.dart';

class AddReviewScreen extends StatefulWidget {
  final BookDetailArgs book;
  const AddReviewScreen({super.key, required this.book});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> with ReviewMixin {
  @override
  void initState() {
    super.initState();
    loadBook(widget.book.bookId);
  }

  @override
  void dispose() {
    clearBook();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;

    return LoadingOverlay(
      isVisible: isSubmitting,
      child: Scaffold(
        backgroundColor: theme.primaryBackground,
        body: SafeArea(
          bottom: false,
          child: Consumer<BooksState>(
            builder: (context, booksState, _) {
              if (booksState.isErrorDetail) {
                return EmptyState(message: booksState.errorMessageDetail);
              }

              final book = booksState.bookDetail;
              if (book == null) {
                return const EmptyState(message: 'Book not found');
              }

              final genre = book.genres.isNotEmpty
                  ? book.genres.first.name
                  : 'Unknown';

              return Column(
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
                            'Add Review',
                            textAlign: TextAlign.center,
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

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        width / 20,
                        width / 45,
                        width / 20,
                        width / 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Book info card ───────────────────────────────────
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Cover
                              ClipRRect(
                                borderRadius: BorderRadius.circular(width / 30),
                                child: Image.network(
                                  book.coverImageUrl!,
                                  width: width / 3.5,
                                  height: width / 2.6,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return const Center(
                                          child: SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1,
                                              color: AppColor
                                                  .defaultSecondaryColor,
                                            ),
                                          ),
                                        );
                                      },
                                  errorBuilder: (_, __, ___) => Container(
                                    width: width / 3.5,
                                    height: width / 2.6,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        width / 30,
                                      ),
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFFD4A77A),
                                          Color(0xFF9D6638),
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Iconsax.book,
                                        color: Colors.white54,
                                        size: width / 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: width / 22),
                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: width / 90),
                                    Text(
                                      book.title,
                                      style: TextStyle(
                                        fontSize: width / 20,
                                        fontWeight: FontWeight.w700,
                                        color: theme.primaryText,
                                      ),
                                    ),
                                    SizedBox(height: width / 36),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width / 25,
                                        vertical: width / 72,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.inputFilledColor,
                                        borderRadius: BorderRadius.circular(
                                          width / 18,
                                        ),
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
                                    SizedBox(height: width / 26),
                                    Row(
                                      children: [
                                        ClipOval(
                                          child: Container(
                                            width: width / 11,
                                            height: width / 11,
                                            color: AppColor
                                                .defaultSecondaryColor
                                                .withValues(alpha: 0.2),
                                            child: Icon(
                                              Iconsax.user,
                                              size: width / 22,
                                              color: AppColor
                                                  .defaultSecondaryColor,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: width / 45),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              book.author.fullName,
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
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: width / 13),
                          Divider(color: theme.lineColor, height: 1),
                          SizedBox(height: width / 15),

                          // ── Overall rating ───────────────────────────────────
                          Center(
                            child: Text(
                              'Your Overall Rating Of The Product',
                              style: TextStyle(
                                fontSize: width / 26,
                                fontWeight: FontWeight.w500,
                                color: theme.primaryText,
                              ),
                            ),
                          ),
                          SizedBox(height: width / 26),
                          Center(
                            child: _InteractiveStars(
                              rating: selectedRating,
                              onChanged: (r) =>
                                  setState(() => selectedRating = r),
                            ),
                          ),
                          SizedBox(height: width / 13),

                          // ── Detailed review ──────────────────────────────────
                          Text(
                            'Add Detailed Review',
                            style: TextStyle(
                              fontSize: width / 26,
                              fontWeight: FontWeight.w600,
                              color: theme.primaryText,
                            ),
                          ),
                          SizedBox(height: width / 36),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.inputFilledColor,
                              borderRadius: BorderRadius.circular(width / 27),
                            ),
                            child: TextField(
                              controller: reviewController,
                              maxLines: 5,
                              style: TextStyle(
                                fontSize: width / 26,
                                color: theme.primaryText,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter Here',
                                hintStyle: TextStyle(
                                  color: theme.secondaryText,
                                  fontSize: width / 26,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(width / 22),
                              ),
                            ),
                          ),
                          SizedBox(height: width / 11),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // ── Floating bottom-sheet-style action button ──────────────
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: EdgeInsets.fromLTRB(
            width / 15,
            width / 20,
            width / 15,
            width / 20,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: width / 25,
              vertical: width / 28,
            ),
            child: ActionButton(
              text: 'Submit',
              onPressed: isSubmitting
                  ? null
                  : () => submitReview(widget.book.bookId),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Interactive star selector
// ---------------------------------------------------------------------------
class _InteractiveStars extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;

  const _InteractiveStars({required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating;
        return GestureDetector(
          onTap: () => onChanged(i + 1),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width / 120),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              color: const Color(0xFFFFB800),
              size: width / 10,
            ),
          ),
        );
      }),
    );
  }
}
