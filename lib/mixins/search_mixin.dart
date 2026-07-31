import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tija/screens/home/book_detail_screen.dart';
import 'package:tija/states/books_state.dart';
import 'package:tija/utils/app_util.dart';
import 'package:tija/widgets/material_router.dart';

mixin SearchMixin<T extends StatefulWidget> on State<T> {
  final TextEditingController searchController = TextEditingController();
  List<String> recentSearches = [];
  int selectedCategory = 0;
  bool isNavigatingToBookDetail = false;
  static const String _recentSearchesKey = 'recent_searches';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSearches = prefs.getStringList(_recentSearchesKey);
    if (savedSearches != null) {
      recentSearches = savedSearches;
    }
  }

  Future<void> saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesKey, recentSearches);
  }

  void clearRecent() {
    setState(() => recentSearches = []);
    saveRecentSearches();
  }

  void onCancel() {
    searchController.clear();
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  void onSearchChanged(String query) => setState(() {});

  Future<void> navigateToBookDetail(String bookId) async {
    final bookState = Provider.of<BooksState>(context, listen: false);
    setState(() => isNavigatingToBookDetail = true);
    await context.read<BooksState>().onGetBookById(bookId);
    await context.read<BooksState>().onGetReviews(bookId);
    if (mounted) {
      setState(() => isNavigatingToBookDetail = false);
      if (bookState.isErrorDetail) {
        AppUtil.showToastMessage(
          isError: true,
          message: 'Failed to load book details ',
        );
        return;
      }
      MaterialRouter.navigateTo(
        context,
        BookDetailScreen(book: BookDetailArgs(bookId: bookId)),
      );
    }
  }
}
