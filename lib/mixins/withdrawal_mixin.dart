import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/action_button.dart';
import 'package:tija/components/custom_dialog.dart';
import 'package:tija/components/input_field.dart';
import 'package:tija/components/shake_error.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/states/payout_state.dart';
import 'package:tija/utils/app_util.dart';

mixin WithdrawalMixin<T extends StatefulWidget> on State<T> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _amountShakeKey = GlobalKey<ShakeErrorState>();
  final _phoneNumberShakeKey = GlobalKey<ShakeErrorState>();

  // Kept for any external checks (e.g. page-level LoadingOverlay elsewhere),
  // but the bottom sheet no longer depends on this for its own spinner.
  bool _isWithdrawing = false;
  bool get isWithdrawing => _isWithdrawing;

  void showWithdrawalBottomSheet() {
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
          bool isSubmitting = _isWithdrawing;

          Future<void> processWithdrawal() async {
            setSheetState(() => isSubmitting = true);
            setState(() => _isWithdrawing = true);

            try {
              final amount = _amountController.text.trim();
              final phoneNumber = _phoneNumberController.text.trim();

              final payoutState = Provider.of<PayoutState>(
                context,
                listen: false,
              );
              final success = await payoutState.requestPayout(
                amountTzs: amount,
                phoneNumber: phoneNumber,
              );

              if (success) {
                AppUtil.showToastMessage(
                  message: 'Withdrawal request submitted successfully!',
                  isError: false,
                );
                if (mounted) {
                  Navigator.of(context).pop();
                  _amountController.clear();
                  _phoneNumberController.clear();
                }
              } else {
                AppUtil.showToastMessage(
                  message: payoutState.errorMessage.isNotEmpty
                      ? payoutState.errorMessage
                      : 'Withdrawal failed. Please try again.',
                  isError: true,
                );
              }
            } catch (e) {
              AppUtil.showToastMessage(
                message: 'Withdrawal failed. Please try again.',
                isError: true,
              );
            }

            // The sheet may have already been popped (success case), so
            // guard both setState calls.
            if (mounted) {
              setState(() => _isWithdrawing = false);
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
                    SizedBox(height: width / 20),
                    Text(
                      'Withdraw Money',
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
                        key: _amountShakeKey,
                        child: InputField(
                          hintText: 'Enter amount',
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Iconsax.money_send),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              _amountShakeKey.currentState?.shake();
                              return 'Please enter amount';
                            }
                            final amount = double.tryParse(value);
                            if (amount == null || amount <= 0) {
                              _amountShakeKey.currentState?.shake();
                              return 'Please enter a valid amount';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: width / 22),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width / 20),
                      child: ShakeError(
                        key: _phoneNumberShakeKey,
                        child: InputField(
                          hintText: 'Enter phone number',
                          controller: _phoneNumberController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Iconsax.call),
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
                        text: 'Withdraw',
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  await processWithdrawal();
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
    _amountController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }
}