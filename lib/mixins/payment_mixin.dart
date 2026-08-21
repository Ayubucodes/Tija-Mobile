import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/action_button.dart';
import 'package:tija/components/custom_dialog.dart';
import 'package:tija/components/input_field.dart';
import 'package:tija/components/shake_error.dart';
import 'package:tija/constants/app_asset.dart';
import 'package:tija/constants/app_preference.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/services/payment_service.dart';
import 'package:tija/states/reader_library_state.dart';
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
      body: StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          // Local loading flag that lives with the sheet itself, so any
          // spinner/disabled-state UI renders inside the sheet's own
          // widget tree (i.e. on top of the sheet), instead of relying on
          // a page-level LoadingOverlay that sits *underneath* the modal
          // bottom sheet's OverlayEntry and therefore never visibly covers it.
          bool isSubmitting = _isPaymentProcessing;

          Future<void> processPayment() async {
            setSheetState(() => isSubmitting = true);
            setState(() => _isPaymentProcessing = true);

            try {
              final phoneNumber = _phoneNumberController.text.trim();

              // Save phone number to secure storage
              const storage = FlutterSecureStorage(
                aOptions: AndroidOptions(encryptedSharedPreferences: true),
              );
              await storage.write(
                key: AppPreference.phoneNumber,
                value: phoneNumber,
              );

              final (
                success,
                errorMessage,
              ) = await PaymentService.initiatePayment(
                bookId: bookId,
                phoneNumber: phoneNumber,
              );

              if (success) {
                AppUtil.showToastMessage(
                  message: 'Payment initiated',
                  isError: false,
                );
                // Refresh reader library to update UI immediately
                if (mounted) {
                  context.read<ReaderLibraryState>().getReaderLibrary();
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

            // The sheet may have already been popped (success case), so
            // guard both setState calls.
            if (mounted) {
              setState(() => _isPaymentProcessing = false);
            }
            // setSheetState is safe to skip if the sheet is gone; wrap
            // defensively since StatefulBuilder has no `mounted` of its own.
            try {
              setSheetState(() => isSubmitting = false);
            } catch (_) {
              // Sheet already disposed (e.g. after a successful pop) — ignore.
            }
          }

          return AbsorbPointer(
            absorbing: isSubmitting,
            child: Opacity(
              opacity: isSubmitting ? 0.6 : 1.0,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: width / 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(AppAssets.AIRTEL_LOGO, width: width / 5),
                        SizedBox(width: width / 20),
                        Image.asset(AppAssets.YAS_LOGO, width: width / 5),
                        SizedBox(width: width / 20),
                        Image.asset(AppAssets.HALOTEL_LOGO, width: width / 5),
                      ],
                    ),
                    SizedBox(height: width / 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width / 20),
                      child: ShakeError(
                        key: _phoneNumberShakeKey,
                        child: InputField(
                          hintText: 'Enter payment number',
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
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  await processPayment();
                                }
                              },
                      ),
                    ),
                    SizedBox(height: width / 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }
}
