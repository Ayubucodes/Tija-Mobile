import 'package:flutter/material.dart';
import 'package:tija/constants/app_theme.dart';

class CustomDialog {
  static bottomSheetModal(
    BuildContext context, {
    required Widget body,
    required double height,
  }) {
    return showModalBottomSheet(
      backgroundColor: AppTheme.of(context).primaryBackground,
      elevation: 3,
      showDragHandle: true,
      isDismissible: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 0,
          ),
          child: SingleChildScrollView(
            child: body,
          ),
        );
      },
    );
  }
}
