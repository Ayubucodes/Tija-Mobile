import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tija/screens/home/author_library_screen.dart';
import 'package:tija/screens/home/reader_library_screen.dart';
import 'package:tija/screens/home/upload_book_screen.dart';
import 'package:tija/states/author_state.dart';
import 'package:tija/states/books_state.dart';
import 'package:tija/states/reader_library_state.dart';
import 'package:tija/utils/app_util.dart';

mixin AuthorDashboardMixin<T extends StatefulWidget> on State<T> {
  void loadDashboard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthorState>().getAuthorDashboard();
      context.read<ReaderLibraryState>().getReaderLibrary();
    });
  }

  bool isGetReaderLibrary = false;
  bool isNavigatingToUploadBookScreen = false;
  bool isNavigatingToReaderLibrary = false;
  bool isNavigatingToAuthorLibrary = false;

  Future<void> retryLoadDashboard() async {
    await context.read<AuthorState>().getAuthorDashboard();
  }

  Future<void> getReaderLibrary() async {
    final libraryState = Provider.of<ReaderLibraryState>(
      context,
      listen: false,
    );
    setState(() => isNavigatingToReaderLibrary = true);
    await context.read<ReaderLibraryState>().getReaderLibrary();
    setState(() => isNavigatingToReaderLibrary = false);
    if (libraryState.isError) {
      AppUtil.showToastMessage(
        isError: true,
        message: 'Something went wrong',
      );
      return;
    }
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ReaderLibraryScreen()));
  }

  Future<void> navigateToBookUploadScreen() async {
    final bookState = Provider.of<BooksState>(context, listen: false);
    setState(() => isNavigatingToUploadBookScreen = true);
    await context.read<BooksState>().onGetGenres();
    if (mounted) {
      setState(() => isNavigatingToUploadBookScreen = false);
      if (bookState.isErrorDetail) {
        AppUtil.showToastMessage(
          isError: true,
          message: 'Something went wrong',
        );
        return;
      }
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const UploadBookScreen()))
          .then((_) {
            // Reload dashboard when returning from upload screen
            loadDashboard();
          });
    }
  }

  Future<void> navigateToAuthorLibrary() async {
    final bookState = Provider.of<BooksState>(context, listen: false);
    setState(() => isNavigatingToAuthorLibrary = true);
    await context.read<BooksState>().getAuthorBooks();
    if (mounted) {
      setState(() => isNavigatingToAuthorLibrary = false);
      if (bookState.isErrorAuthorBooks) {
        AppUtil.showToastMessage(
          isError: true,
          message: 'Something went wrong, please logout and login again',
        );
        return;
      }
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const AuthorLibraryScreen()));
    }
  }
}
