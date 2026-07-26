import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:tija/constants/app_preference.dart';
import 'package:tija/screens/authentication/login.dart';
import 'package:tija/states/auth_state.dart';
import 'package:tija/states/reader_library_state.dart';

mixin ProfileMixin<T extends StatefulWidget> on State<T> {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  bool isLoading = false;
  String userEmail = '';
  String userPhone = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final email = await _storage.read(key: AppPreference.email);
    final phone = await _storage.read(key: AppPreference.phoneNumber);

    if (mounted) {
      setState(() {
        userEmail = email ?? '';
        userPhone = phone ?? '';
      });
    }

    // Load reader library data
    if (mounted) {
      context.read<ReaderLibraryState>().getReaderLibrary();
    }
  }

  Future<void> onUpdate() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) setState(() => isLoading = false);
  }

  bool get isAuthor {
    final user = context.read<AuthState>().user;
    return user?.roles.isNotEmpty == true && user!.roles.contains('Author');
  }

  Future<void> onLogout() async {
    await context.read<AuthState>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
