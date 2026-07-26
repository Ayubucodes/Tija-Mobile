import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tija/components/action_button.dart';
import 'package:tija/components/custom_dialog.dart';
import 'package:tija/components/input_field.dart';
import 'package:tija/components/shake_error.dart';
import 'package:tija/constants/app_preference.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/services/payment_service.dart';
import 'package:tija/utils/app_util.dart';

mixin PaymentMixin<T extends StatefulWidget> on State<T> {
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  final _phoneNumberShakeKey = GlobalKey<ShakeErrorState>();
  bool _isPaymentProcessing = false;

  bool get isPaymentProcessing => _isPaymentProcessing;

  void showPhoneNumberBottomSheet(String bookId) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;

    CustomDialog.bottomSheetModal(
      context,
      height: height * 0.80,
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: width / 20),
            Text(
              'Enter Phone Number',
              style: TextStyle(
                fontSize: width / 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.of(context).primaryText,
              ),
            ),
            SizedBox(height: width / 15),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width / 20),
              child: ShakeError(
                key: _phoneNumberShakeKey,
                child: InputField(
                  hintText: 'Enter your phone number',
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      _phoneNumberShakeKey.currentState?.shake();
                      return 'Please enter your phone number';
                    }
                    if (value.length < 10) {
                      _phoneNumberShakeKey.currentState?.shake();
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
              ),
            ),
            SizedBox(height: width / 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ActionButton(
                text: 'Proceed to Pay',
                onPressed: _isPaymentProcessing
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          await _processPayment(bookId);
                        }
                      },
                isLoading: _isPaymentProcessing,
              ),
            ),
            SizedBox(height: width / 20),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment(String bookId) async {
    setState(() => _isPaymentProcessing = true);

    try {
      final phoneNumber = _phoneNumberController.text.trim();

      // Save phone number to secure storage
      const storage = FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );
      await storage.write(key: AppPreference.phoneNumber, value: phoneNumber);

      final (success, errorMessage) = await PaymentService.initiatePayment(
        bookId: bookId,
        phoneNumber: phoneNumber,
      );

      if (success) {
        AppUtil.showToastMessage(
          message: 'Payment initiated successfully!',
          isError: false,
        );
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        AppUtil.showToastMessage(message: errorMessage, isError: true);
      }
    } catch (e) {
      AppUtil.showToastMessage(
        message: 'Payment failed. Please try again.',
        isError: true,
      );
    }

    setState(() => _isPaymentProcessing = false);
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }
}
