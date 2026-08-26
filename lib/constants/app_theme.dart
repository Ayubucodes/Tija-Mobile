// ignore_for_file: overridden_fields
// import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class AppTheme {
  static AppTheme of(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Color(0x00000000),
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarContrastEnforced: true,
        ),
      );
      return DarkModeTheme();
    } else {
      final lightTheme = LightModeTheme();
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Color(0x00000000),
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Color(0xFFE8E5DE),
          systemNavigationBarContrastEnforced: true,
        ),
      );
      return lightTheme;
    }
  }

  final lightTheme = Color(0xFF9E9E9E);
  final darkTheme = Color(0xFF1C1C1C);

  late Color primaryColor;
  late Color secondaryColor;
  late Color tertiaryColor;
  late Color alternate;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color primaryText;
  late Color secondaryText;
  late Color primaryBtnText;
  late Color lineColor;
  late Color bottomNavigationColor;
  late Color actionColor;
  late Color inputFilledColor;
  late Color balanceCardColor;
  late Color customCardText;
  late Color customCardColor;
  late Color bottomNavigationTextColor;
  late Color borderColor;

  Typography get typography => ThemeTypography(this);

  TextStyle get title1 => typography.title1;
  TextStyle get titlesmall => typography.titlesmall;
  TextStyle get labelSmall => typography.labelSmall;
}

class LightModeTheme extends AppTheme {
  @override
  late Color primaryColor = const Color(0xFF4E220F);
  @override
  late Color secondaryColor = const Color(0xFF9D6638);
  @override
  late Color tertiaryColor = const Color(0xFFB0BA99);
  @override
  late Color alternate = const Color(0xFFE0E0E0);
  @override
  late Color secondaryBackground = const Color(0xFFF3F0EA); // grain-toned, not pure white
  @override
  late Color primaryBackground = const Color(0xFFE8E5DE); 
  @override
  late Color primaryText = const Color(0xFF1A1A1A);
  @override
  late Color secondaryText = const Color(0xFF888888);
  @override
  late Color primaryBtnText = const Color(0xFFFFFFFF);
  @override
  late Color lineColor = const Color(0xFFE0E0E0);
  @override
  late Color bottomNavigationColor = const Color(0xFFFFFFFF);
  @override
  late Color actionColor = const Color(0xFF9D6638);
  @override
  late Color inputFilledColor = const Color(0xFFF3F0EA);
  @override
  late Color balanceCardColor = const Color(0xFF4E220F);
  @override
  late Color customCardText = const Color(0xFF1A1A1A);
  @override
  late Color customCardColor = const Color(0xFFF7F1DE);
  @override
  late Color bottomNavigationTextColor = const Color(0xFF9D6638);
  @override
  late Color borderColor = const Color.fromARGB(172, 170, 170, 170);
}

class DarkModeTheme extends AppTheme {
  @override
  late Color primaryColor = const Color(0xFF9D6638);
  @override
  late Color secondaryColor = const Color(0xFFB0BA99);
  @override
  late Color tertiaryColor = const Color(0xFF4E220F);
  @override
  late Color alternate = const Color(0xFF3A3A3A);
  @override
  late Color primaryBackground = const Color(0xFF1C1C1C);
  @override
  late Color secondaryBackground = const Color(0xFF2C2C2C);
  @override
  late Color primaryText = const Color(0xFFFFFFFF);
  @override
  late Color secondaryText = const Color(0xFFAAAAAA);
  @override
  late Color primaryBtnText = const Color(0xFFFFFFFF);
  @override
  late Color lineColor = const Color(0xFF3A3A3A);
  @override
  late Color bottomNavigationColor = const Color(0xFF2C2C2C);
  @override
  late Color actionColor = const Color(0xFF9D6638);
  @override
  late Color inputFilledColor = const Color(0xFF2C2C2C);
  @override
  late Color balanceCardColor = const Color(0xFF9D6638);
  @override
  late Color customCardText = const Color(0xFFFFFFFF);
  @override
  late Color customCardColor = const Color(0xFF2C2C2C);
  @override
  late Color bottomNavigationTextColor = const Color(0xFF9D6638);
  @override
  late Color borderColor = const Color.fromARGB(68, 170, 170, 170);
}

abstract class Typography {
  TextStyle get title1;
  TextStyle get titlesmall;
  TextStyle get labelSmall;
}

class ThemeTypography extends Typography {
  ThemeTypography(this.theme);

  final AppTheme theme;

  @override
  TextStyle get labelSmall => TextStyle(
    color: theme.primaryBtnText,
    fontWeight: FontWeight.normal,
    fontSize: 8,
  );

  @override
  TextStyle get title1 => TextStyle(
    color: theme.primaryBtnText,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  @override
  TextStyle get titlesmall => TextStyle(
    color: theme.primaryBtnText,
    fontWeight: FontWeight.normal,
    fontSize: 12,
  );
}

/// Concrete [ThemeData] objects consumed by [MaterialApp.theme] and
/// [MaterialApp.darkTheme]. [AppTheme.of] uses the resulting brightness
/// to select the right colour palette.
class AppThemeData {
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF9D6638),
      primary: const Color(0xFF9D6638),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    fontFamily: 'OpenSans',
    useMaterial3: true,
  );

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF9D6638),
      primary: const Color(0xFF9D6638),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF1C1C1C),
    fontFamily: 'OpenSans',
    useMaterial3: true,
  );
}
