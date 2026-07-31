import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:tija/constants/app_color.dart';

class AppUtil {
  AppUtil._();

  static String formatMoney(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'sw_TZ',
      symbol: 'TZS ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

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
