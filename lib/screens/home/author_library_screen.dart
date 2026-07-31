import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/loading_overlay.dart';
import 'package:tija/constants/app_color.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/models/books_model.dart';
import 'package:tija/screens/home/book_detail_screen.dart';
import 'package:tija/states/author_state.dart';
import 'package:tija/states/books_state.dart';
import 'package:tija/utils/app_util.dart';
import 'package:tija/widgets/empty_state.dart';
import 'package:tija/widgets/placeholder.dart';

class AuthorLibraryScreen extends StatefulWidget {
  const AuthorLibraryScreen({super.key});

  @override
  State<AuthorLibraryScreen> createState() => _AuthorLibraryScreenState();
}

class _AuthorLibraryScreenState extends State<AuthorLibraryScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksState>().getAuthorBooks();
    });
  }

  Future<void> navigateToBookDetail(String bookId) async {
    final bookState = Provider.of<BooksState>(context, listen: false);
    setState(() => _isNavigating = true);
    await context.read<BooksState>().onGetBookById(bookId);
    if (bookState.isErrorDetail) {
      setState(() => _isNavigating = false);
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

  // ── Send draft book to review ─────────────────────────────────────────
  Future<void> sendBookToReview(String bookId) async {
    setState(() => _isNavigating = true);
    await context.read<BooksState>().submitBookForReview(bookId);
    if (!mounted) return;
    setState(() => _isNavigating = false);
    if (context.read<BooksState>().isSubmitBookError) {
      AppUtil.showToastMessage(
        isError: true,
        message: context.read<BooksState>().submitBookErrorMessage.isNotEmpty
            ? context.read<BooksState>().submitBookErrorMessage
            : 'Failed to send book for review',
      );
    } else {
      AppUtil.showToastMessage(isError: false, message: 'Book sent for review');
      // Refresh the author books list
      context.read<BooksState>().getAuthorBooks();
      // Refresh the author dashboard data
      // context.read<AuthorState>().getAuthorDashboard();
    }
  }

  // ── Delete draft book ───────────────────────────────────────────────
  Future<void> deleteDraftBook(String bookId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete draft'),
        content: const Text(
          'Are you sure you want to delete this draft book? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isNavigating = true);
    await context.read<BooksState>().deleteBook(bookId);
    if (!mounted) return;
    setState(() => _isNavigating = false);
    if (context.read<BooksState>().isDeleteBookError) {
      AppUtil.showToastMessage(
        isError: true,
        message: context.read<BooksState>().deleteBookErrorMessage.isNotEmpty
            ? context.read<BooksState>().deleteBookErrorMessage
            : 'Failed to delete draft',
      );
    } else {
      AppUtil.showToastMessage(isError: false, message: 'Draft deleted');
      // Refresh the author books list
      context.read<BooksState>().getAuthorBooks();
      // Refresh the author dashboard data
      context.read<AuthorState>().getAuthorDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Consumer<BooksState>(
      builder: (_, booksState, __) => LoadingOverlay(
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
                                  Iconsax.arrow_left_2,
                                  color: theme.primaryText,
                                  size: width / 16,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'My Books',
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
                  child: Consumer<BooksState>(
                    builder: (context, booksState, _) {
                      if (booksState.authorBooksItems.isEmpty) {
                        return EmptyState(
                          message: "Most author's books will be displayed here",
                        );
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
                            await context.read<BooksState>().getAuthorBooks();
                          },
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: EdgeInsets.only(bottom: width / 12),
                            itemCount: booksState.authorBooksItems.length,
                            itemBuilder: (context, index) {
                              final book = booksState.authorBooksItems[index];
                              final isDraft =
                                  book.status.toLowerCase() == 'draft';
                              return _AuthorBookCard(
                                book: book,
                                onTap: () => navigateToBookDetail(book.id),
                                onSendToReview: isDraft
                                    ? () => sendBookToReview(book.id)
                                    : null,
                                onDelete: isDraft
                                    ? () => deleteDraftBook(book.id)
                                    : null,
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
// Author book card
// ---------------------------------------------------------------------------
class _AuthorBookCard extends StatelessWidget {
  final Item book;
  final VoidCallback onTap;
  final VoidCallback? onSendToReview;
  final VoidCallback? onDelete;

  const _AuthorBookCard({
    required this.book,
    required this.onTap,
    this.onSendToReview,
    this.onDelete,
  });

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
              child:
                  book.coverImageUrl != null && book.coverImageUrl!.isNotEmpty
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
                            book.author.fullName,
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
                      // Status badge + draft actions (send to review / delete)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatusBadge(status: book.status),
                          if (onSendToReview != null || onDelete != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (onSendToReview != null)
                                  IconButton(
                                    icon: Icon(
                                      Iconsax.send_2,
                                      color: AppColor.defaultSecondaryColor,
                                      size: width / 22,
                                    ),
                                    tooltip: 'Send for review',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    visualDensity: VisualDensity.compact,
                                    onPressed: onSendToReview,
                                  ),
                                if (onSendToReview != null && onDelete != null)
                                  SizedBox(width: width / 45),
                                if (onDelete != null)
                                  IconButton(
                                    icon: Icon(
                                      Iconsax.trash,
                                      color: Colors.red,
                                      size: width / 22,
                                    ),
                                    tooltip: 'Delete draft',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    visualDensity: VisualDensity.compact,
                                    onPressed: onDelete,
                                  ),
                              ],
                            ),
                        ],
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

// ---------------------------------------------------------------------------
// Status badge
// ---------------------------------------------------------------------------
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    Color badgeColor;
    switch (status.toLowerCase()) {
      case 'published':
        badgeColor = Colors.green;
        break;
      case 'draft':
        badgeColor = Colors.orange;
        break;
      case 'pending':
        badgeColor = Colors.blue;
        break;
      default:
        badgeColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width / 30,
        vertical: width / 90,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(width / 45),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: width / 32,
          color: badgeColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
