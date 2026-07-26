import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tija/screens/home/read_screen.dart';
import 'package:tija/states/books_state.dart';
import 'package:tija/utils/app_util.dart';

mixin BookDetailController<T extends StatefulWidget> on State<T> {
  void navigateToReadScreen(String bookId) {
    final booksState = Provider.of<BooksState>(context, listen: false);
    if (booksState.isError) {
      AppUtil.showToastMessage(isError: true, message: 'Failed to open book');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReadScreen(args: ReadScreenArgs(bookId: bookId)),
      ),
    );
  }
}
