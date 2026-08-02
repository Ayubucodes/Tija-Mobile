import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:tija/constants/app_asset.dart';
import 'package:tija/constants/app_preference.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/states/auth_state.dart';

class SplashScreenOne extends StatefulWidget {
  const SplashScreenOne({super.key});

  @override
  State<SplashScreenOne> createState() => _SplashScreenOneState();
}

class _SplashScreenOneState extends State<SplashScreenOne> {
  bool _navigated = false;
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  void initState() {
    super.initState();
    _waitForGifThenNavigate();
  }

  Future<void> _waitForGifThenNavigate() async {
    try {
      // Load the raw bytes of the gif from assets.
      final ByteData data = await rootBundle.load(AppAssets.SPRASH_GIF);
      final Uint8List bytes = data.buffer.asUint8List();

      // Decode it as a multi-frame codec so we can read every frame's duration.
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);

      Duration totalDuration = Duration.zero;
      for (int i = 0; i < codec.frameCount; i++) {
        final ui.FrameInfo frameInfo = await codec.getNextFrame();
        totalDuration += frameInfo.duration;
      }

      // Fallback in case duration comes back as zero (e.g. static image).
      if (totalDuration == Duration.zero) {
        totalDuration = const Duration(seconds: 3);
      }

      // Gif has now fully loaded/decoded — wait out its full playback length,
      // then navigate.
      await Future.delayed(totalDuration);
      _checkAuthAndNavigate();
    } catch (e) {
      // If decoding fails for any reason, don't strand the user on splash.
      await Future.delayed(const Duration(seconds: 3));
      _checkAuthAndNavigate();
    }
  }

  Future<void> _checkAuthAndNavigate() async {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Center(
        child: Image.asset(
          AppAssets.SPRASH_GIF,
          width: MediaQuery.of(context).size.width * 0.6,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
