import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/loading_overlay.dart';
import 'package:tija/constants/app_asset.dart';
import 'package:tija/constants/app_color.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/models/reader_library_model.dart';
import 'package:tija/screens/home/book_detail_screen.dart';
import 'package:tija/states/books_state.dart';
import 'package:tija/states/reader_library_state.dart';
import 'package:tija/utils/app_util.dart';
import 'package:tija/widgets/empty_state.dart';
import 'package:tija/widgets/placeholder.dart';

class ReaderLibraryScreen extends StatefulWidget {
  const ReaderLibraryScreen({super.key});

  @override
  State<ReaderLibraryScreen> createState() => _ReaderLibraryScreenState();
}

class _ReaderLibraryScreenState extends State<ReaderLibraryScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReaderLibraryState>().getReaderLibrary();
    });
  }

  Future<void> navigateToBookDetail(String bookId) async {
    final bookState = Provider.of<BooksState>(context, listen: false);
    setState(() => _isNavigating = true);
    await context.read<BooksState>().onGetBookById(bookId);
    if (bookState.isErrorDetail) {
      AppUtil.showToastMessage(
        isError: true,
        message: 'failed to load books details',
      );
      return;
    }
    if (mounted) {
      setState(() => _isNavigating = false);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              BookDetailScreen(book: BookDetailArgs(bookId: bookId)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Consumer<ReaderLibraryState>(
      builder: (_, libraryState, __) => LoadingOverlay(
        isVisible: _isNavigating,
        child: Scaffold(
          backgroundColor: theme.primaryBackground,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                            Expanded(
                              child: Text(
                                'My Library',
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
                      Divider(height: 1, thickness: 1, color: theme.lineColor),
                    ],
                  ),
                ),
                SizedBox(height: width / 22),

                // ── Books list ───────────────────────────────────────────────
                Expanded(
                  child: Consumer<ReaderLibraryState>(
                    builder: (context, libraryState, _) {
                      if (libraryState.isError) {
                        return EmptyState(message: libraryState.errorMessage);
                      }

                      if (libraryState.books.isEmpty) {
                        return EmptyState(message: 'No books in your library');
                      }

                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          width / 22,
                          width / 90,
                          width / 22,
                          0,
                        ),
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await context
                                .read<ReaderLibraryState>()
                                .getReaderLibrary();
                          },
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: EdgeInsets.only(bottom: width / 12),
                            itemCount: libraryState.books.length,
                            itemBuilder: (context, index) {
                              final book = libraryState.books[index];
                              return _LibraryBookCard(
                                book: book,
                                onTap: () => navigateToBookDetail(book.bookId),
                              );
                            },
                          ),
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
}

// ---------------------------------------------------------------------------
// Library book card
// ---------------------------------------------------------------------------
class _LibraryBookCard extends StatelessWidget {
  final ReaderLibraryBook book;
  final VoidCallback onTap;

  const _LibraryBookCard({required this.book, required this.onTap});

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
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          width: width / 3.5,
                          height: coverHeight,
                          child: const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 1,
                                color: AppColor.defaultSecondaryColor,
                              ),
                            ),
                          ),
                        );
                      },
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            book.authorName,
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
                      if (book.progressPercentage != null)
                        _ProgressBar(progress: book.progressPercentage!),
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

// ---------------------------------------------------------------------------
// Progress bar
// ---------------------------------------------------------------------------
class _ProgressBar extends StatelessWidget {
  final double progress;

  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final theme = AppTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: width / 32,
                color: theme.secondaryText,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: width / 32,
                color: AppColor.defaultSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: width / 90),
        Container(
          height: width / 90,
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(width / 90),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(width / 90),
            child: FractionallySizedBox(
              widthFactor: progress,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.defaultSecondaryColor,
                  borderRadius: BorderRadius.circular(width / 90),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
