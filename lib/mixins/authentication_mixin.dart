import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/shake_error.dart';
import 'package:tija/screens/authentication/login.dart';
import 'package:tija/screens/authentication/register.dart';
import 'package:tija/states/auth_state.dart';
import 'package:tija/utils/app_util.dart';

mixin AuthenticationMixin<T extends StatefulWidget> on State<T> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final emailShakeKey = GlobalKey<ShakeErrorState>();
  final passwordShakeKey = GlobalKey<ShakeErrorState>();

  late final TabController tabController;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final nameShakeKey = GlobalKey<ShakeErrorState>();
  final phoneShakeKey = GlobalKey<ShakeErrorState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    tabController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      emailShakeKey.currentState?.shake();
      return '';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      passwordShakeKey.currentState?.shake();
      return '';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> handleLogin() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final success = await context.read<AuthState>().onLogin(
      username: emailController.text.trim(),
      password: passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } else {
      AppUtil.showToastMessage(
        isError: true,
        message: context.read<AuthState>().errorMessage,
      );
    }
  }

  Future<void> handleSignUp() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final isAuthor = tabController.index == 1;
    final success = isAuthor
        ? await context.read<AuthState>().onRegisterAuthor(
            fullName: nameController.text.trim(),
            email: emailController.text.trim(),
            phoneNumber: phoneController.text.trim(),
            password: passwordController.text,
          )
        : await context.read<AuthState>().onRegister(
            fullName: nameController.text.trim(),
            email: emailController.text.trim(),
            phoneNumber: phoneController.text.trim(),
            password: passwordController.text,
          );

    if (!mounted) return;

    if (success) {
      final loginSuccess = await context.read<AuthState>().onLogin(
        username: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      if (loginSuccess) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        AppUtil.showToastMessage(
          isError: false,
          message: 'Account created! Please log in.',
        );
        navigateToLogin();
      }
    } else {
      AppUtil.showToastMessage(
        isError: true,
        message: context.read<AuthState>().errorMessage,
      );
    }
  }

  void navigateToRegister() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  void navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}
