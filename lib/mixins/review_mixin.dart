import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/shake_error.dart';
import 'package:tija/models/books_model.dart';
import 'package:tija/services/review_service.dart';
import 'package:tija/states/books_state.dart';
import 'package:tija/utils/app_util.dart';

mixin ReviewMixin<T extends StatefulWidget> on State<T> {
  int selectedRating = 3;
  final TextEditingController reviewController = TextEditingController();
  bool isSubmitting = false;
  final GlobalKey<ShakeErrorState> reviewShakeKey =
      GlobalKey<ShakeErrorState>();
  bool reviewError = false;

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  Future<void> submitReview(String bookId) async {
    FocusScope.of(context).unfocus();

    if (reviewController.text.trim().isEmpty) {
      setState(() => reviewError = true);
      reviewShakeKey.currentState?.shake();
      return;
    }

    setState(() => isSubmitting = true);

    final result = await ReviewService.submitReview(
      bookId: bookId,
      rating: selectedRating.toString(),
      comment: reviewController.text.trim(),
    );

    if (mounted) {
      setState(() => isSubmitting = false);

      if (result != null) {
        AppUtil.showToastMessage(
          isError: false,
          message: 'Review submitted successfully!',
        );
        Navigator.of(context).pop();
      } else {
        AppUtil.showToastMessage(
          isError: true,
          message: 'Failed to submit review. Please try again.',
        );
      }
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
