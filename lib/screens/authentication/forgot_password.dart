import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/action_button.dart';
import 'package:tija/components/input_field.dart';
import 'package:tija/components/loading_overlay.dart';
import 'package:tija/components/shake_error.dart';
import 'package:tija/constants/app_asset.dart';
import 'package:tija/constants/app_color.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/mixins/authentication_mixin.dart';
import 'package:tija/states/auth_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with AuthenticationMixin {
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Consumer<AuthState>(
      builder: (_, authState, __) => LoadingOverlay(
        isVisible: authState.isLoading,
        child: Scaffold(
          backgroundColor: theme.primaryBackground,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width / 15),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: height / 10),

                      // Book GIF
                      Image.asset(
                        AppAssets.BOOK_GIF,
                        width: width / 3,
                        height: width / 3,
                      ),

                      SizedBox(height: height / 40),

                      Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: width / 13,
                          fontWeight: FontWeight.w800,
                          color: theme.primaryText,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),

                      SizedBox(height: width / 22),

                      Text(
                        'Enter your email to receive a password reset link',
                        style: TextStyle(
                          fontSize: width / 22,
                          fontWeight: FontWeight.w400,
                          color: theme.secondaryText,
                          letterSpacing: -0.3,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: width / 10),

                      // Email field
                      ShakeError(
                        key: emailShakeKey,
                        duration: const Duration(milliseconds: 500),
                        shakeCount: 3,
                        shakeOffset: 10,
                        child: InputField(
                          hintText: 'Enter Email',
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: validateEmail,
                          prefixIcon: Icon(
                            Iconsax.sms,
                            color: const Color(0xFFAAAAAA),
                            size: 20,
                          ),
                        ),
                      ),
                      SizedBox(height: width / 13),

                      // Send Reset Link button
                      ActionButton(
                        text: 'Send Reset Link',
                        onPressed: handleForgotPassword,
                      ),
                      SizedBox(height: width / 13),

                      // Back to Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Remember your password?",
                            style: TextStyle(
                              fontSize: width / 28,
                              color: theme.secondaryText,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.only(left: width / 90),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontSize: width / 28,
                                fontWeight: FontWeight.w700,
                                color: AppColor.defaultSecondaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: width / 15),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
