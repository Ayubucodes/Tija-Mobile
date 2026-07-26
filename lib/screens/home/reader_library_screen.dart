import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/loading_overlay.dart';
import 'package:tija/constants/app_asset.dart';
import 'package:tija/constants/app_color.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/models/reader_library_model.dart';
import 'package:tija/screens/home/book_detail_screen.dart';
import 'package:tija/states/books_state.dart';
import 'package:tija/states/reader_library_state.dart';
import 'package:tija/widgets/placeholder.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    setState(() => _isNavigating = true);
    await context.read<BooksState>().onGetBookById(bookId);
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
        isVisible: libraryState.isLoading || _isNavigating,
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
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                libraryState.errorMessage,
                                style: TextStyle(
                                  fontSize: width / 26,
                                  color: theme.secondaryText,
                                ),
                              ),
                              SizedBox(height: width / 22),
                              ElevatedButton(
                                onPressed: () => context
                                    .read<ReaderLibraryState>()
                                    .getReaderLibrary(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (libraryState.books.isEmpty) {
                        return _buildEmptyState(
                          width,
                          theme,
                          'No books in your library',
                        );
                      }

                      return Padding(
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
                          itemCount: libraryState.books.length,
                          itemBuilder: (context, index) {
                            final book = libraryState.books[index];
                            return _LibraryBookCard(
                              book: book,
                              onTap: () => navigateToBookDetail(book.bookId),
                            );
                          },
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
                      errorBuilder: (_, __, ___) => PlaceholderCover(
                        width: width / 3.5,
                        height: width / 2.6,
                      ),
                    )
                  : PlaceholderCover(width: width / 3.5, height: width / 2.6),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: width / 60),
                    Text(
                      book.authorName,
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
                    if (book.progressPercentage != null)
                      _ProgressBar(progress: book.progressPercentage!),
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
