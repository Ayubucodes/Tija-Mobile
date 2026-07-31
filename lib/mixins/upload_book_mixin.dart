import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/shake_error.dart';
import 'package:tija/models/books_model.dart';
import 'package:tija/screens/home/upload_book_files_screen.dart';
import 'package:tija/states/books_state.dart';
import 'package:tija/utils/app_util.dart';

mixin UploadBookMixin<T extends StatefulWidget> on State<T> {
  bool isNavigatingToUploadBookFilesScreen = false;
  final formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController totalPagesController = TextEditingController();

  final titleShakeKey = GlobalKey<ShakeErrorState>();
  final descriptionShakeKey = GlobalKey<ShakeErrorState>();
  final priceShakeKey = GlobalKey<ShakeErrorState>();
  final totalPagesShakeKey = GlobalKey<ShakeErrorState>();
  final genreShakeKey = GlobalKey<ShakeErrorState>();

  String? selectedGenreId;
  String? genreError;
  final List<Genre> availableGenres = [];

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    totalPagesController.dispose();
    super.dispose();
  }

  Future<void> loadGenres() async {
    await context.read<BooksState>().onGetGenres();
    if (mounted) {
      setState(() {
        availableGenres.clear();
        availableGenres.addAll(context.read<BooksState>().genres);
      });
    }
  }

  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      titleShakeKey.currentState?.shake();
      return '';
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      descriptionShakeKey.currentState?.shake();
      return '';
    }
    return null;
  }

  String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      priceShakeKey.currentState?.shake();
      return '';
    }
    if (double.tryParse(value) == null) {
      priceShakeKey.currentState?.shake();
      return 'Please enter valid price';
    }
    return null;
  }

  String? validateTotalPages(String? value) {
    if (value == null || value.trim().isEmpty) {
      totalPagesShakeKey.currentState?.shake();
      return '';
    }
    if (int.tryParse(value) == null) {
      totalPagesShakeKey.currentState?.shake();
      return 'Please enter valid total pages';
    }
    return null;
  }

  String? validateGenre(String? value) {
    if (selectedGenreId == null) {
      genreShakeKey.currentState?.shake();
      return '';
    }
    return null;
  }

  Future<void> onNext() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    if (selectedGenreId == null) {
      genreShakeKey.currentState?.shake();
      setState(() {
        genreError = 'Please select a genre';
      });
      return;
    }

    final price = double.tryParse(priceController.text);
    final totalPages = int.tryParse(totalPagesController.text);

    setState(() => isNavigatingToUploadBookFilesScreen = true);

    final booksState = context.read<BooksState>();
    final success = await booksState.uploadBook(
      title: titleController.text,
      description: descriptionController.text,
      priceTzs: price!,
      totalPages: totalPages!,
      genreIds: [selectedGenreId!],
    );

    if (mounted) {
      setState(() => isNavigatingToUploadBookFilesScreen = false);
    }

    if (!success || booksState.uploadedBook == null) {
      AppUtil.showToastMessage(
        isError: true,
        message: booksState.uploadErrorMessage.isNotEmpty
            ? booksState.uploadErrorMessage
            : 'Failed to create book',
      );
      return;
    }

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => UploadBookFilesScreen(
            bookId: booksState.uploadedBook!.id,
            title: titleController.text,
            description: descriptionController.text,
            priceTzs: price!,
            totalPages: totalPages!,
            genreIds: [selectedGenreId!],
          ),
        ),
      );
    }
  }
}
