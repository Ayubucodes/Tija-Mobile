import 'package:flutter/material.dart';
import 'package:tija/models/reader_library_model.dart';
import 'package:tija/services/books_services.dart';

class ReaderLibraryState extends ChangeNotifier {
  List<ReaderLibraryBook> _books = [];
  bool _isLoading = false;
  bool _isError = false;
  String _errorMessage = '';

  List<ReaderLibraryBook> get books => _books;
  bool get isLoading => _isLoading;
  bool get isError => _isError;
  String get errorMessage => _errorMessage;
  int get bookCount => _books.length;

  bool hasBookAccess(String bookId) {
    return _books.any((book) => book.bookId == bookId);
  }

  Future<void> getReaderLibrary() async {
    _isLoading = true;
    _isError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await BooksService.getReaderLibrary();

      if (result != null) {
        _books = result;
        _isError = false;
      } else {
        _isError = true;
        _errorMessage = 'Failed to load library';
      }
    } catch (e) {
      _isError = true;
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
