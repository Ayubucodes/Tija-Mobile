import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/loading_overlay.dart';
import 'package:tija/constants/app_color.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/mixins/author_mixin.dart';
import 'package:tija/mixins/search_mixin.dart';
import 'package:tija/models/author_model.dart' as author_model;
import 'package:tija/models/books_model.dart';
import 'package:tija/models/reader_library_model.dart';
import 'package:tija/screens/home/book_detail_screen.dart';
import 'package:tija/states/auth_state.dart';
import 'package:tija/states/author_state.dart';
import 'package:tija/states/books_state.dart';
import 'package:tija/states/reader_library_state.dart';
import 'package:tija/utils/app_util.dart';
import 'package:tija/widgets/empty_state.dart';
import 'package:tija/widgets/placeholder.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class AuthorsScreen extends StatefulWidget {
  const AuthorsScreen({super.key});

  @override
  State<AuthorsScreen> createState() => _AuthorsScreenState();
}

class _AuthorsScreenState extends State<AuthorsScreen>
    with SearchMixin, AuthorMixin, SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthorState>().getAuthors();
      // Load books based on user type
      final authState = context.read<AuthState>();
      final isAuthor = authState.user?.roles.contains('Author') ?? false;
      if (isAuthor) {
        context.read<BooksState>().getAuthorBooks();
      } else {
        context.read<ReaderLibraryState>().getReaderLibrary();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Consumer<AuthorState>(
      builder: (_, authorState, __) => LoadingOverlay(
        isVisible:
            authorState.isLoading ||
            authorState.isDetailLoading ||
            isNavigatingToAuthorDetail ||
            _isNavigating,
        child: Scaffold(
          backgroundColor: theme.primaryBackground,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── App bar with centered title ────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    width / 22,
                    width / 45,
                    width / 22,
                    width / 45,
                  ),
                  child: SizedBox(
                    height: width / 10,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Centered title — stays centered regardless of
                        // any leading/trailing icons added later.
                        Center(
                          child: Text(
                            'Library',
                            style: TextStyle(
                              fontSize: width / 22,
                              fontWeight: FontWeight.w700,
                              color: theme.primaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: width / 22),

                // ── Search bar ──────────────────────────────────────────
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
                            onChanged: (_) => setState(() {}),
                            style: TextStyle(
                              fontSize: width / 26,
                              color: theme.primaryText,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search...',
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
                          onTap: () {
                            searchController.clear();
                            setState(() {});
                          },
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
                SizedBox(height: width / 30),

                // ── Tabs ───────────────────────────────────────────────────
                Container(
                  color: Colors.transparent,
                  child: TabBar(
                    controller: _tabController,
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
                      Tab(text: 'My Books'),
                      Tab(text: 'Authors'),
                    ],
                  ),
                ),
                SizedBox(height: width / 30),

                // ── Tab content ────────────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // My Books tab
                      _buildMyBooksTab(width, theme),
                      // Authors tab
                      _buildAuthorsTab(width, theme, authorState),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyBooksTab(double width, AppTheme theme) {
    final authState = context.read<AuthState>();
    final isAuthor = authState.user?.roles.contains('Author') ?? false;

    if (isAuthor) {
      // Author books tab
      return Consumer<BooksState>(
        builder: (context, booksState, _) {
          if (booksState.authorBooksItems.isEmpty) {
            return EmptyState(message: "Your books will be displayed here");
          }

          // Filter books based on search query
          final searchQuery = searchController.text.toLowerCase();
          final filteredBooks = booksState.authorBooksItems.where((book) {
            return book.title.toLowerCase().contains(searchQuery) ||
                book.author.fullName.toLowerCase().contains(searchQuery);
          }).toList();

          if (filteredBooks.isEmpty) {
            return EmptyState(
              message: 'No books match "${searchController.text}"',
            );
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(width / 22, width / 90, width / 22, 0),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.only(bottom: width / 12),
              itemCount: filteredBooks.length,
              itemBuilder: (context, index) {
                final book = filteredBooks[index];
                final isDraft = book.status.toLowerCase() == 'draft';
                return _BookCard(
                  book: book,
                  onTap: () => navigateToBookDetail(book.id),
                  onSendToReview: isDraft
                      ? () => sendBookToReview(book.id)
                      : null,
                  onDelete: isDraft ? () => deleteDraftBook(book.id) : null,
                );
              },
            ),
          );
        },
      );
    } else {
      // Reader library tab
      return Consumer<ReaderLibraryState>(
        builder: (context, libraryState, _) {
          if (libraryState.isError) {
            return EmptyState(message: libraryState.errorMessage);
          }

          if (libraryState.books.isEmpty) {
            return EmptyState(message: 'No books in your library');
          }

          // Filter books based on search query
          final searchQuery = searchController.text.toLowerCase();
          final filteredBooks = libraryState.books.where((book) {
            return book.title.toLowerCase().contains(searchQuery) ||
                book.authorName.toLowerCase().contains(searchQuery);
          }).toList();

          if (filteredBooks.isEmpty) {
            return EmptyState(
              message: 'No books match "${searchController.text}"',
            );
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(width / 22, width / 90, width / 22, 0),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.only(bottom: width / 12),
              itemCount: filteredBooks.length,
              itemBuilder: (context, index) {
                final book = filteredBooks[index];
                return _LibraryBookCard(
                  book: book,
                  onTap: () => navigateToBookDetail(book.bookId),
                );
              },
            ),
          );
        },
      );
    }
  }

  Widget _buildAuthorsTab(
    double width,
    AppTheme theme,
    AuthorState authorState,
  ) {
    if (authorState.isError) {
      return EmptyState(message: authorState.errorMessage);
    }

    if (authorState.authors.isEmpty) {
      return EmptyState(message: 'No authors found');
    }

    // Filter authors based on search query
    final searchQuery = searchController.text.toLowerCase();
    final filteredAuthors = authorState.authors.where((author) {
      return author.fullName.toLowerCase().contains(searchQuery);
    }).toList();

    if (filteredAuthors.isEmpty) {
      return EmptyState(message: 'No authors match "${searchController.text}"');
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(
        width / 22,
        width / 30,
        width / 22,
        width / 3.5,
      ),
      itemCount: filteredAuthors.length,
      separatorBuilder: (_, __) => SizedBox(height: width / 30),
      itemBuilder: (_, i) => _AuthorRow(
        author: filteredAuthors[i],
        onTap: () => navigateToAuthorDetail(filteredAuthors[i].id),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Author row (card style)
// ---------------------------------------------------------------------------
class _AuthorRow extends StatelessWidget {
  final author_model.Author author;
  final VoidCallback onTap;

  const _AuthorRow({required this.author, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(width / 18),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(width / 22),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(width / 18),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: width / 10,
                height: width / 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.defaultSecondaryColor.withOpacity(0.12),
                  border: Border.all(
                    color: AppColor.defaultSecondaryColor.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: author.profilePictureUrl != null
                      ? Image.network(
                          author.profilePictureUrl!,
                          width: width / 10,
                          height: width / 10,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              width: width / 10,
                              height: width / 10,
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
                          errorBuilder: (_, __, ___) =>
                              _buildDefaultAvatarIcon(width),
                        )
                      : _buildDefaultAvatarIcon(width),
                ),
              ),
              SizedBox(width: width / 22),

              // Name + stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author.fullName,
                      style: TextStyle(
                        fontSize: width / 28,
                        fontWeight: FontWeight.w700,
                        color: theme.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: width / 150),
                    Text(
                      '${author.totalBooks} books',
                      style: TextStyle(
                        fontSize: width / 34,
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: width / 38),

              // Rating (optional)
              if (author.averageRating != null) ...[
                Icon(
                  Icons.star_rounded,
                  color: const Color(0xFFFFB800),
                  size: width / 24,
                ),
                SizedBox(width: width / 90),
                Text(
                  author.averageRating!.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: width / 28,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryText,
                  ),
                ),
                SizedBox(width: width / 45),
              ],

              // Trailing arrow
              Icon(
                Iconsax.arrow_right_3,
                color: theme.secondaryText,
                size: width / 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatarIcon(double width) {
    return Icon(
      Iconsax.user,
      color: AppColor.defaultSecondaryColor,
      size: width / 20,
    );
  }
}

// ---------------------------------------------------------------------------
// Book card for author books
// ---------------------------------------------------------------------------
class _BookCard extends StatelessWidget {
  final Item book;
  final VoidCallback onTap;
  final VoidCallback? onSendToReview;
  final VoidCallback? onDelete;

  const _BookCard({
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
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          width: width / 3.5,
                          height: coverHeight,
                          child: Center(
                            child: const SizedBox(
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
// Library book card for reader
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
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
