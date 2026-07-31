import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tija/screens/home/book_detail_screen.dart';
import 'package:tija/screens/home/read_screen.dart';
import 'package:tija/states/books_state.dart';
import 'package:tija/states/reader_state.dart';
import 'package:tija/utils/app_util.dart';

mixin BookDetailController<T extends StatefulWidget> on State<T> {
  bool isNavigatingToBookDetail = false;
  bool isNavigatingToReadScreen = false;

  Future<void> navigateToReadScreen(String bookId) async {
    final booksState = Provider.of<BooksState>(context, listen: false);
    if (booksState.isError) {
      AppUtil.showToastMessage(isError: true, message: 'Failed to open book');
      return;
    }

    setState(() => isNavigatingToReadScreen = true);
    final readerState = context.read<ReaderState>();

    await readerState.openBook(bookId);

    if (readerState.isError) {
      if (mounted) {
        setState(() => isNavigatingToReadScreen = false);
      }
      AppUtil.showToastMessage(
        isError: true,
        message: readerState.errorMessage.isNotEmpty
            ? readerState.errorMessage
            : 'Failed to open book',
      );
      return;
    }

    if (readerState.readerResponse != null) {
      await readerState.decryptBook();
    }

    if (readerState.isError) {
      if (mounted) {
        setState(() => isNavigatingToReadScreen = false);
      }
      AppUtil.showToastMessage(
        isError: true,
        message: readerState.errorMessage.isNotEmpty
            ? readerState.errorMessage
            : 'Failed to open book',
      );
      return;
    }

    if (mounted) {
      setState(() => isNavigatingToReadScreen = false);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              ReadScreen(args: ReadScreenArgs(bookId: bookId)),
        ),
      );
    }
  }

  Future<void> navigateToBookDetail(String bookId, {String? genreId}) async {
    setState(() => isNavigatingToBookDetail = true);
    await context.read<BooksState>().onGetBookById(bookId);
    if (genreId != null) {
      await context.read<BooksState>().onGetRelatedBooks(genreId);
    }
    await context.read<BooksState>().onGetReviews(bookId);
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
