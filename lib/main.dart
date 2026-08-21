import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tija/components/custom_bottom_navigation.dart';
import 'package:tija/constants/app_config.dart';
import 'package:tija/constants/app_theme.dart';
import 'package:tija/screens/authentication/login.dart';
import 'package:tija/screens/onboarding/splash_screen_one.dart';
import 'package:tija/states/auth_state.dart';
import 'package:tija/states/author_state.dart';
import 'package:tija/states/books_state.dart';
import 'package:tija/states/payout_state.dart';
import 'package:tija/states/reader_library_state.dart';
import 'package:tija/states/reader_state.dart';
import 'package:tija/states/theme_state.dart';
import 'package:tija/states/connectivity_state.dart';
import 'package:tija/widgets/session_timeout_listener.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeState = ThemeState();
  await themeState.initialize();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeState),
        ChangeNotifierProvider(create: (_) => ConnectivityState()),
        ChangeNotifierProvider(create: (_) => BooksState()),
        ChangeNotifierProvider(
          create: (context) => AuthState(context.read<ConnectivityState>()),
        ),
        ChangeNotifierProvider(create: (_) => AuthorState()),
        ChangeNotifierProvider(create: (_) => ReaderState()),
        ChangeNotifierProvider(create: (_) => ReaderLibraryState()),
        ChangeNotifierProvider(create: (_) => PayoutState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeState>();
    final authState = context.watch<AuthState>();

    return SessionTimeoutListener(
      duration: Duration(
        seconds: AppConfiguration.sessionInactiveTimeInSeconds,
      ),
      noInactivity: authState.noInactivityTimeout,
      onTimeOut: () async {
        if (!authState.noInactivityTimeout) {
          await authState.logout();
          authState.onSetAppNoInactivityStatus(inactivityStatus: true);
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      },
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Tija',
        debugShowCheckedModeBanner: false,
        themeMode: themeState.themeMode,
        theme: AppThemeData.light,
        darkTheme: AppThemeData.dark,
        initialRoute: '/splash_one',
        routes: {
          '/splash_one': (_) => const SplashScreenOne(),
          // '/splash_two': (_) => const SplashScreenTwo(),
          '/login': (_) => const LoginScreen(),
          '/home': (_) => const CustomBottomNavigation(),
        },
      ),
    );
  }
}
