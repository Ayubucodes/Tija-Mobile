// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tija/components/circular_process_loader.dart';

class LoadingOverlay extends StatefulWidget {
  Widget child;
  bool isVisible;

  LoadingOverlay({super.key, required this.child, this.isVisible = false});

  @override
  State<StatefulWidget> createState() => LoadingOverlayState();
}

class LoadingOverlayState extends State<LoadingOverlay> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final lightTheme = const Color(0xFF9E9E9E);
    final darkTheme = const Color(0xFF1C1C1C);

    final lightThemeStyle = SystemUiOverlayStyle(
      systemNavigationBarDividerColor: lightTheme.withOpacity(0.05),
      systemNavigationBarColor: lightTheme.withOpacity(0.05),
      systemNavigationBarIconBrightness: Brightness.dark,
    );

    final darkThemeStyle = SystemUiOverlayStyle(
      systemNavigationBarDividerColor: darkTheme.withOpacity(0.75),
      systemNavigationBarColor: darkTheme.withOpacity(0.8),
      systemNavigationBarIconBrightness: Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? darkThemeStyle : lightThemeStyle,
      child: Stack(
        children: [
          widget.child,
          Visibility(
            visible: widget.isVisible,
            child: Container(
              width: width,
              height: height,
              color: isDark
                  ? Colors.black.withOpacity(0.6)
                  : Colors.white.withOpacity(0.7),
              child: Container(
                margin: EdgeInsets.only(top: width / 8),
                child: const CircularProcessLoader(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
