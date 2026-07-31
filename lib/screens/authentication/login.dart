import 'package:flutter/material.dart';
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with AuthenticationMixin {
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

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
                        getGreeting(),
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
                        'We are glad to have you back',
                        style: TextStyle(
                          fontSize: width / 18,
                          fontWeight: FontWeight.w500,
                          color: theme.primaryText,
                          letterSpacing: -0.3,
                          height: 1.3,
                        ),
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
                        ),
                      ),
                      SizedBox(height: width / 12),

                      // Password field
                      ShakeError(
                        key: passwordShakeKey,
                        duration: const Duration(milliseconds: 500),
                        shakeCount: 3,
                        shakeOffset: 10,
                        child: InputField(
                          hintText: 'Enter Password',
                          controller: passwordController,
                          isPassword: true,
                          validator: validatePassword,
                        ),
                      ),
                      SizedBox(height: width / 30),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: implement forgot password
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: width / 28,
                              fontWeight: FontWeight.w600,
                              color: AppColor.defaultSecondaryColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: width / 13),

                      // Sign In button
                      ActionButton(text: 'Sign In', onPressed: handleLogin),
                      SizedBox(height: width / 13),

                      // Register link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't Have An Account?",
                            style: TextStyle(
                              fontSize: width / 28,
                              color: theme.secondaryText,
                            ),
                          ),
                          TextButton(
                            onPressed: navigateToRegister,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.only(left: width / 90),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Register',
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
