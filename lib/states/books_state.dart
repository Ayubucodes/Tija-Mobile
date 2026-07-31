import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tija/models/books_model.dart';
import 'package:tija/services/books_services.dart';
import 'package:tija/services/review_service.dart';

class BooksState extends ChangeNotifier {
  Books? _books;
  bool _isLoading = false;
  bool _isError = false;
  String _errorMessage = '';

  BookDetail? _bookDetail;
  bool _isLoadingDetail = false;
  bool _isErrorDetail = false;
  String _errorMessageDetail = '';

  List<Genre> _genres = [];
  bool _isLoadingGenres = false;
  bool _isErrorGenres = false;
  String _errorMessageGenres = '';

  // Separate state for related books
  List<Item> _relatedBooks = [];
  bool _isLoadingRelated = false;
  bool _isErrorRelated = false;
  String _errorMessageRelated = '';

  // State for uploading books
  bool _isUploading = false;
  bool _isUploadError = false;
  String _uploadErrorMessage = '';
  BookDetail? _uploadedBook;

  // State for file upload responses
  bool _isUploadingFiles = false;
  bool _isUploadFilesError = false;
  String _uploadFilesErrorMessage = '';
  Map<String, dynamic>? _bookFileUploadResponse;
  Map<String, dynamic>? _coverUploadResponse;

  // State for updating book
  bool _isUpdatingBook = false;
  bool _isUpdateBookError = false;
  String _updateBookErrorMessage = '';
  BookDetail? _updatedBook;

  // State for deleting book
  bool _isDeletingBook = false;
  bool _isDeleteBookError = false;
  String _deleteBookErrorMessage = '';

  // State for submitting book for review
  bool _isSubmittingBook = false;
  bool _isSubmitBookError = false;
  String _submitBookErrorMessage = '';

  // State for search
  Books? _searchResults;
  bool _isSearching = false;
  bool _isSearchError = false;
  String _searchErrorMessage = '';

  // State for reviews
  Reviews? _reviews;
  bool _isLoadingReviews = false;
  bool _isErrorReviews = false;
  String _errorMessageReviews = '';

  // State for author books
  Books? _authorBooks;
  bool _isLoadingAuthorBooks = false;
  bool _isErrorAuthorBooks = false;
  String _errorMessageAuthorBooks = '';

  Books? get books => _books;
  List<Item> get items => _books?.items ?? [];
  bool get isLoading => _isLoading;
  bool get isError => _isError;
  String get errorMessage => _errorMessage;

  BookDetail? get bookDetail => _bookDetail;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isErrorDetail => _isErrorDetail;
  String get errorMessageDetail => _errorMessageDetail;

  List<Genre> get genres => _genres;
  bool get isLoadingGenres => _isLoadingGenres;
  bool get isErrorGenres => _isErrorGenres;
  String get errorMessageGenres => _errorMessageGenres;

  List<Item> get relatedBooks => _relatedBooks;
  bool get isLoadingRelated => _isLoadingRelated;
  bool get isErrorRelated => _isErrorRelated;
  String get errorMessageRelated => _errorMessageRelated;

  bool get isUploading => _isUploading;
  bool get isUploadError => _isUploadError;
  String get uploadErrorMessage => _uploadErrorMessage;
  BookDetail? get uploadedBook => _uploadedBook;

  bool get isUploadingFiles => _isUploadingFiles;
  bool get isUploadFilesError => _isUploadFilesError;
  String get uploadFilesErrorMessage => _uploadFilesErrorMessage;
  Map<String, dynamic>? get bookFileUploadResponse => _bookFileUploadResponse;
  Map<String, dynamic>? get coverUploadResponse => _coverUploadResponse;

  Books? get searchResults => _searchResults;
  List<Item> get searchItems => _searchResults?.items ?? [];
  bool get isSearching => _isSearching;
  bool get isSearchError => _isSearchError;
  String get searchErrorMessage => _searchErrorMessage;

  Reviews? get reviews => _reviews;
  List<Review> get reviewItems => _reviews?.items ?? [];
  bool get isLoadingReviews => _isLoadingReviews;
  bool get isErrorReviews => _isErrorReviews;
  String get errorMessageReviews => _errorMessageReviews;

  Books? get authorBooks => _authorBooks;
  List<Item> get authorBooksItems => _authorBooks?.items ?? [];
  bool get isLoadingAuthorBooks => _isLoadingAuthorBooks;
  bool get isErrorAuthorBooks => _isErrorAuthorBooks;
  String get errorMessageAuthorBooks => _errorMessageAuthorBooks;

  bool get isUpdatingBook => _isUpdatingBook;
  bool get isUpdateBookError => _isUpdateBookError;
  String get updateBookErrorMessage => _updateBookErrorMessage;
  BookDetail? get updatedBook => _updatedBook;

  bool get isDeletingBook => _isDeletingBook;
  bool get isDeleteBookError => _isDeleteBookError;
  String get deleteBookErrorMessage => _deleteBookErrorMessage;

  bool get isSubmittingBookForReview => _isSubmittingBook;
  bool get isSubmitBookError => _isSubmitBookError;
  String get submitBookErrorMessage => _submitBookErrorMessage;

  Future<void> onGetBooks({int page = 1, int pageSize = 10}) async {
    _isLoading = true;
    _isError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await BooksService.onGetBooks(
        page: page,
        pageSize: pageSize,
      );

      if (result != null) {
        _books = result;
        _isError = false;
      } else {
        _isError = true;
        _errorMessage = 'Failed to load books.';
      }
    } catch (e) {
      _isError = true;
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> onGetRelatedBooks(String genreId) async {
    _isLoadingRelated = true;
    _isErrorRelated = false;
    _errorMessageRelated = '';
    notifyListeners();

    try {
      final result = await BooksService.onGetBooks(
        page: 1,
        pageSize: 5,
        genreId: genreId,
      );

      if (result != null) {
        _relatedBooks = result.items;
        _isErrorRelated = false;
      } else {
        _isErrorRelated = true;
        _errorMessageRelated = 'Failed to load related books.';
      }
    } catch (e) {
      _isErrorRelated = true;
      _errorMessageRelated = e.toString();
    }

    _isLoadingRelated = false;
    notifyListeners();
  }

  Future<void> onGetBookById(String id) async {
    _isLoadingDetail = true;
    _isErrorDetail = false;
    _errorMessageDetail = '';
    notifyListeners();

    try {
      final result = await BooksService.onGetBookById(id);

      if (result != null) {
        _bookDetail = result;
        _isErrorDetail = false;
      } else {
        _isErrorDetail = true;
        _errorMessageDetail = 'Failed to load book details.';
      }
    } catch (e) {
      _isErrorDetail = true;
      _errorMessageDetail = e.toString();
    }

    _isLoadingDetail = false;
    notifyListeners();
  }

  void clearData() {
    _books = null;
    _isError = false;
    _errorMessage = '';
    notifyListeners();
  }

  void clearBookDetail() {
    _bookDetail = null;
    _isErrorDetail = false;
    _errorMessageDetail = '';
    notifyListeners();
  }

  Future<void> onGetGenres() async {
    _isLoadingGenres = true;
    _isErrorGenres = false;
    _errorMessageGenres = '';
    notifyListeners();

    try {
      final result = await BooksService.onGetGenres();

      if (result != null) {
        _genres = result;
        _isErrorGenres = false;
      } else {
        _isErrorGenres = true;
        _errorMessageGenres = 'Failed to load genres.';
      }
    } catch (e) {
      _isErrorGenres = true;
      _errorMessageGenres = e.toString();
    }

    _isLoadingGenres = false;
    notifyListeners();
  }

  Future<bool> uploadBook({
    required String title,
    required String description,
    required double priceTzs,
    required int totalPages,
    required List<String> genreIds,
  }) async {
    _isUploading = true;
    _isUploadError = false;
    _uploadErrorMessage = '';
    _uploadedBook = null;
    notifyListeners();

    try {
      final result = await BooksService.uploadBook(
        title: title,
        description: description,
        priceTzs: priceTzs,
        totalPages: totalPages,
        genreIds: genreIds,
      );

      if (result != null) {
        _uploadedBook = result;
        _isUploadError = false;
      } else {
        _isUploadError = true;
        _uploadErrorMessage = 'Failed to upload book.';
      }
    } catch (e) {
      _isUploadError = true;
      _uploadErrorMessage = e.toString();
    }

    _isUploading = false;
    notifyListeners();
    return !_isUploadError;
  }

  Future<bool> uploadBookFile(String bookId, File file) async {
    _isUploadingFiles = true;
    _isUploadFilesError = false;
    _uploadFilesErrorMessage = '';
    _bookFileUploadResponse = null;
    notifyListeners();

    try {
      final result = await BooksService.uploadBookFile(bookId, file);

      if (result != null) {
        _bookFileUploadResponse = result;

        // Check if response contains errors (validation error from server)
        if (result.containsKey('errors') && result['errors'] is Map) {
          final errors = result['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            _isUploadFilesError = true;
            // Extract the first error message
            final firstErrorKey = errors.keys.first;
            final errorMessages = errors[firstErrorKey];
            if (errorMessages is List && errorMessages.isNotEmpty) {
              _uploadFilesErrorMessage = errorMessages.first.toString();
            } else {
              _uploadFilesErrorMessage = errorMessages.toString();
            }
          } else {
            _isUploadFilesError = false;
          }
        } else if (result.containsKey('title') &&
            result.containsKey('status')) {
          // Check if it's an error response with title and status
          if (result['status'] != 200 && result['status'] != 201) {
            _isUploadFilesError = true;
            _uploadFilesErrorMessage =
                result['title']?.toString() ?? 'Failed to upload book file.';
          } else {
            _isUploadFilesError = false;
          }
        } else {
          _isUploadFilesError = false;
        }
      } else {
        _isUploadFilesError = true;
        _uploadFilesErrorMessage = 'Failed to upload book file.';
      }
    } catch (e) {
      _isUploadFilesError = true;
      _uploadFilesErrorMessage = e.toString();
    }

    _isUploadingFiles = false;
    notifyListeners();
    return !_isUploadFilesError;
  }

  Future<bool> uploadCover(File file) async {
    _isUploadingFiles = true;
    _isUploadFilesError = false;
    _uploadFilesErrorMessage = '';
    _coverUploadResponse = null;
    notifyListeners();

    try {
      final result = await BooksService.uploadCover(file);

      if (result != null) {
        _coverUploadResponse = result;

        // Check if response contains errors (validation error from server)
        if (result.containsKey('errors') && result['errors'] is Map) {
          final errors = result['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            _isUploadFilesError = true;
            // Extract the first error message
            final firstErrorKey = errors.keys.first;
            final errorMessages = errors[firstErrorKey];
            if (errorMessages is List && errorMessages.isNotEmpty) {
              _uploadFilesErrorMessage = errorMessages.first.toString();
            } else {
              _uploadFilesErrorMessage = errorMessages.toString();
            }
          } else {
            _isUploadFilesError = false;
          }
        } else if (result.containsKey('title') &&
            result.containsKey('status')) {
          // Check if it's an error response with title and status
          if (result['status'] != 200 && result['status'] != 201) {
            _isUploadFilesError = true;
            _uploadFilesErrorMessage =
                result['title']?.toString() ?? 'Failed to upload cover.';
          } else {
            _isUploadFilesError = false;
          }
        } else {
          _isUploadFilesError = false;
        }
      } else {
        _isUploadFilesError = true;
        _uploadFilesErrorMessage = 'Failed to upload cover.';
      }
    } catch (e) {
      _isUploadFilesError = true;
      _uploadFilesErrorMessage = e.toString();
    }

    _isUploadingFiles = false;
    notifyListeners();
    return !_isUploadFilesError;
  }

  Future<void> searchBooks({String? query}) async {
    _isSearching = true;
    _isSearchError = false;
    _searchErrorMessage = '';
    notifyListeners();

    try {
      final result = await BooksService.searchBooks(query: query);

      if (result != null) {
        _searchResults = result;
        _isSearchError = false;
      } else {
        _isSearchError = true;
        _searchErrorMessage = 'Failed to search books.';
      }
    } catch (e) {
      _isSearchError = true;
      _searchErrorMessage = e.toString();
    }

    _isSearching = false;
    notifyListeners();
  }

  Future<void> onGetReviews(String bookId) async {
    _isLoadingReviews = true;
    _isErrorReviews = false;
    _errorMessageReviews = '';
    notifyListeners();

    try {
      final result = await ReviewService.getReviews(bookId);

      if (result != null) {
        _reviews = result;
        _isErrorReviews = false;
      } else {
        _isErrorReviews = true;
        _errorMessageReviews = 'Failed to load reviews.';
      }
    } catch (e) {
      _isErrorReviews = true;
      _errorMessageReviews = e.toString();
    }

    _isLoadingReviews = false;
    notifyListeners();
  }

  void clearReviews() {
    _reviews = null;
    _isErrorReviews = false;
    _errorMessageReviews = '';
    notifyListeners();
  }

  Future<void> getAuthorBooks() async {
    _isLoadingAuthorBooks = true;
    _isErrorAuthorBooks = false;
    _errorMessageAuthorBooks = '';
    notifyListeners();

    try {
      final result = await BooksService.getAuthorBooks();

      if (result != null) {
        _authorBooks = result;
        _isErrorAuthorBooks = false;
      } else {
        _isErrorAuthorBooks = true;
        // _errorMessageAuthorBooks = 'Failed to load your books.';
      }
    } catch (e) {
      _isErrorAuthorBooks = true;
      _errorMessageAuthorBooks = e.toString();
    }

    _isLoadingAuthorBooks = false;
    notifyListeners();
  }

  Future<void> updateBook({
    required String bookId,
    required String title,
    required String description,
    required double priceTzs,
    required String coverImageUrl,
    required String bookFileUrl,
    required int totalPages,
    required List<String> genreIds,
  }) async {
    _isUpdatingBook = true;
    _isUpdateBookError = false;
    _updateBookErrorMessage = '';
    notifyListeners();

    try {
      final result = await BooksService.updateBook(
        bookId: bookId,
        title: title,
        description: description,
        priceTzs: priceTzs,
        coverImageUrl: coverImageUrl,
        bookFileUrl: bookFileUrl,
        totalPages: totalPages,
        genreIds: genreIds,
      );

      if (result != null) {
        _updatedBook = result;
        _isUpdateBookError = false;
      } else {
        _isUpdateBookError = true;
        _updateBookErrorMessage = 'Failed to update book.';
      }
    } catch (e) {
      _isUpdateBookError = true;
      _updateBookErrorMessage = e.toString();
    }

    _isUpdatingBook = false;
    notifyListeners();
  }

  Future<void> deleteBook(String bookId) async {
    _isDeletingBook = true;
    _isDeleteBookError = false;
    _deleteBookErrorMessage = '';
    notifyListeners();

    try {
      final success = await BooksService.deleteBook(bookId);

      if (success) {
        _isDeleteBookError = false;
      } else {
        _isDeleteBookError = true;
        _deleteBookErrorMessage = 'Failed to delete book.';
      }
    } catch (e) {
      _isDeleteBookError = true;
      _deleteBookErrorMessage = e.toString();
    }

    _isDeletingBook = false;
    notifyListeners();
  }

  Future<void> submitBookForReview(String bookId) async {
    _isSubmittingBook = true;
    _isSubmitBookError = false;
    _submitBookErrorMessage = '';
    notifyListeners();

    try {
      final success = await BooksService.submitBookForReview(bookId);

      if (success) {
        _isSubmitBookError = false;
      } else {
        _isSubmitBookError = true;
        _submitBookErrorMessage = 'Failed to submit book for review.';
      }
    } catch (e) {
      _isSubmitBookError = true;
      _submitBookErrorMessage = e.toString();
    }

    _isSubmittingBook = false;
    notifyListeners();
  }
}
