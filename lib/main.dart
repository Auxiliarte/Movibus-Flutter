import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'package:movibus/auth/login_screen.dart';
import 'package:movibus/auth/register_screen.dart';
import 'package:movibus/auth/reset_pass.dart';
import 'screen/home_screen.dart';
import 'screen/settings.dart';
import 'screen/routes_screen.dart';
import 'welcome.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movibus',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/home': (_) => const HomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/Welcome': (_) => const WelcomeScreen(),
        '/resetPass': (_) => const ResetPasswordScreen(),
        '/settings': (_) => SettingsScreen(),
        '/routes': (_) => const RoutesScreen(),
      },
    );
  }
}
