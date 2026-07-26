import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tija/models/books_model.dart';
import 'package:tija/screens/home/upload_book_files_screen.dart';
import 'package:tija/states/books_state.dart';
import 'package:tija/utils/app_util.dart';

mixin UploadBookMixin<T extends StatefulWidget> on State<T> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController totalPagesController = TextEditingController();

  final Set<String> selectedGenreIds = {};
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

  Future<void> onNext() async {
    if (titleController.text.isEmpty) {
      AppUtil.showToastMessage(isError: true, message: 'Please enter title');
      return;
    }
    if (descriptionController.text.isEmpty) {
      AppUtil.showToastMessage(
        isError: true,
        message: 'Please enter description',
      );
      return;
    }
    if (priceController.text.isEmpty) {
      AppUtil.showToastMessage(isError: true, message: 'Please enter price');
      return;
    }
    if (totalPagesController.text.isEmpty) {
      AppUtil.showToastMessage(
        isError: true,
        message: 'Please enter total pages',
      );
      return;
    }
    if (selectedGenreIds.isEmpty) {
      AppUtil.showToastMessage(
        isError: true,
        message: 'Please select at least one genre',
      );
      return;
    }

    final price = double.tryParse(priceController.text);
    if (price == null) {
      AppUtil.showToastMessage(
        isError: true,
        message: 'Please enter valid price',
      );
      return;
    }

    final totalPages = int.tryParse(totalPagesController.text);
    if (totalPages == null) {
      AppUtil.showToastMessage(
        isError: true,
        message: 'Please enter valid total pages',
      );
      return;
    }

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => UploadBookFilesScreen(
            bookData: {
              'title': titleController.text,
              'description': descriptionController.text,
              'priceTzs': price,
              'totalPages': totalPages,
              'genreIds': selectedGenreIds.toList(),
            },
          ),
        ),
      );
    }
  }
}
