import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tija/screens/home/book_detail_screen.dart';
import 'package:tija/states/author_state.dart';
import 'package:tija/states/books_state.dart';

mixin AuthorDetailMixin<T extends StatefulWidget> on State<T> {
  bool isFollowing = false;
  bool isNavigatingToBookDetail = false;

  void toggleFollow() => setState(() => isFollowing = !isFollowing);

  void loadAuthor(String authorId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthorState>().getAuthorById(authorId);
    });
  }

  void retryLoadAuthor(String authorId) {
    context.read<AuthorState>().getAuthorById(authorId);
  }

  Future<void> navigateToBookDetail(String bookId) async {
    setState(() => isNavigatingToBookDetail = true);
    await context.read<BooksState>().onGetBookById(bookId);
    if (mounted) {
      setState(() => isNavigatingToBookDetail = false);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              BookDetailScreen(book: BookDetailArgs(bookId: bookId)),
        ),
      );
    }
  }
}
