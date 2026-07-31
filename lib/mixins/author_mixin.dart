import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tija/screens/home/author_detail_screen.dart';
import 'package:tija/states/author_state.dart';
import 'package:tija/utils/app_util.dart';

mixin AuthorMixin<T extends StatefulWidget> on State<T> {
  bool isNavigatingToAuthorDetail = false;

  Future<void> navigateToAuthorDetail(String authorId) async {
    final authorState = Provider.of<AuthorState>(context, listen: false);
    setState(() => isNavigatingToAuthorDetail = true);
    final success = await authorState.getAuthorById(authorId);
    setState(() => isNavigatingToAuthorDetail = false);
    if (!success) {
      AppUtil.showToastMessage(
        isError: true,
        message: authorState.detailErrorMessage.isNotEmpty
            ? authorState.detailErrorMessage
            : 'Something went wrong',
      );
      return;
    }
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AuthorDetailScreen(authorId: authorId),
        ),
      );
    }
  }
}
