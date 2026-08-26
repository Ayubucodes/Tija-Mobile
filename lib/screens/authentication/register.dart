import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tija/components/action_button.dart';
import 'package:tija/components/input_field.dart';
import 'package:tija/components/loading_overlay.dart';
import 'package:tija/components/shake_error.dart';
import 'package:tija/constants/app_color.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/mixins/authentication_mixin.dart';
import 'package:tija/states/auth_state.dart';
import 'package:tija/states/books_state.dart';
import 'package:tija/states/author_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin, AuthenticationMixin {
  bool _agreedToPrivacyPolicy = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final width = MediaQuery.of(context).size.width;
    return Consumer<AuthState>(
      builder: (_, authState, __) => Consumer<BooksState>(
        builder: (_, booksState, __) => Consumer<AuthorState>(
          builder: (_, authorState, __) => LoadingOverlay(
            isVisible:
                authState.isLoading ||
                booksState.isLoading ||
                booksState.isLoadingMostPopular ||
                authorState.isLoading ||
                authorState.isDashboardLoading,
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
                          SizedBox(height: width / 6),

                          // Title
                          Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: width / 14,
                              fontWeight: FontWeight.w700,
                              color: theme.primaryText,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: width / 20),

                          // Tab Bar
                          Container(
                            color: Colors.transparent,
                            child: TabBar(
                              controller: tabController,
                              labelColor: AppColor.defaultSecondaryColor,
                              unselectedLabelColor: theme.secondaryText,
                              indicatorColor: AppColor.defaultSecondaryColor,
                              indicatorWeight: 2.5,
                              labelStyle: TextStyle(
                                fontSize: width / 26,
                                fontWeight: FontWeight.w600,
                              ),
                              unselectedLabelStyle: TextStyle(
                                fontSize: width / 26,
                                fontWeight: FontWeight.w400,
                              ),
                              tabs: const [
                                Tab(text: 'Reader'),
                                Tab(text: 'Author'),
                              ],
                            ),
                          ),
                          SizedBox(height: width / 16),
                          // Name field
                          ShakeError(
                            key: nameShakeKey,
                            duration: const Duration(milliseconds: 500),
                            shakeCount: 3,
                            shakeOffset: 10,
                            child: InputField(
                              hintText: 'Enter FullName',
                              controller: nameController,
                              keyboardType: TextInputType.name,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  nameShakeKey.currentState?.shake();
                                  return '';
                                }
                                return null;
                              },
                              prefixIcon: Icon(
                                Iconsax.user,
                                color: const Color(0xFFAAAAAA),
                                size: 20,
                              ),
                            ),
                          ),
                          SizedBox(height: width / 12),

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
                          SizedBox(height: width / 12),

                          // Phone number field
                          ShakeError(
                            key: phoneShakeKey,
                            duration: const Duration(milliseconds: 500),
                            shakeCount: 3,
                            shakeOffset: 10,
                            child: InputField(
                              hintText: 'Enter Phone Number',
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  phoneShakeKey.currentState?.shake();
                                  return '';
                                }
                                return null;
                              },
                              prefixIcon: Icon(
                                Iconsax.call,
                                color: const Color(0xFFAAAAAA),
                                size: 20,
                              ),
                            ),
                          ),
                          SizedBox(height: width / 12),
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
                              prefixIcon: Icon(
                                Iconsax.lock,
                                color: const Color(0xFFAAAAAA),
                                size: 20,
                              ),
                            ),
                          ),
                          SizedBox(height: width / 12),

                          // Privacy Policy Checkbox
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _agreedToPrivacyPolicy,
                                onChanged: (value) {
                                  setState(() {
                                    _agreedToPrivacyPolicy = value ?? false;
                                  });
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final url = Uri.parse(
                                      'https://ebooks.tija.co.tz/privacy',
                                    );
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(top: width / 45),
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'I agree to the ',
                                            style: TextStyle(
                                              fontSize: width / 30,
                                              color: theme.secondaryText,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Privacy Policy',
                                            style: TextStyle(
                                              fontSize: width / 30,
                                              color: AppColor
                                                  .defaultSecondaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: width / 12),

                          // Sign Up button
                          ActionButton(
                            text: 'Sign Up',
                            onPressed: _agreedToPrivacyPolicy
                                ? handleSignUp
                                : null,
                          ),
                          SizedBox(height: width / 13),

                          // Login link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already Have An Account?',
                                style: TextStyle(
                                  fontSize: width / 28,
                                  color: theme.secondaryText,
                                ),
                              ),
                              TextButton(
                                onPressed: navigateToLogin,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.only(left: width / 90),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
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
        ),
      ),
    );
  }
}
