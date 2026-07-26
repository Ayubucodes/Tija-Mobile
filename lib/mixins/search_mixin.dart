import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

mixin SearchMixin<T extends StatefulWidget> on State<T> {
  final TextEditingController searchController = TextEditingController();
  List<String> recentSearches = [];
  int selectedCategory = 0;
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
}
