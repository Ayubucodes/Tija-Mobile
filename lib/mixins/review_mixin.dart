import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tija/models/books_model.dart';
import 'package:tija/states/books_state.dart';

mixin ReviewMixin<T extends StatefulWidget> on State<T> {
  int selectedRating = 3;
  final TextEditingController reviewController = TextEditingController();
  bool isSubmitting = false;

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  Future<void> submitReview(String bookId) async {
    FocusScope.of(context).unfocus();
    setState(() => isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => isSubmitting = false);
      Navigator.of(context).pop();
    }
  }

  void loadBook(String bookId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksState>().onGetBookById(bookId);
    });
  }

  void clearBook() {
    context.read<BooksState>().clearBookDetail();
  }
}
