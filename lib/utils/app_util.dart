import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tija/constants/app_color.dart';

class AppUtil {
  AppUtil._();

  static showToastMessage({
    required String message,
    bool isError = true,
    ToastGravity? position = ToastGravity.BOTTOM,
  }) {
    if (message.isNotEmpty) {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: position,
        textColor: Colors.white,
        fontSize: 16,
        backgroundColor: isError
            ? AppColor.defaultErrorColor
            : AppColor.defaultSuccessColor,
      );
    }
  }
}
