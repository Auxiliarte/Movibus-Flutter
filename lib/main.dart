import 'package:flutter/material.dart';
import 'package:movibus/screen/coupon_promo_screen.dart';
import 'package:movibus/screen/profile_Editpersonal_screen.dart';
import 'package:movibus/screen/profile_EditPass_screen.dart';
import 'package:movibus/screen/profile_edit_screen.dart';
import 'package:movibus/screen/profile_mail_screen.dart';
import 'package:movibus/screen/route_bus_screen.dart';
import 'package:movibus/screen/router_history.dart';
import 'splash_screen.dart';
import 'package:movibus/auth/login_screen.dart';
import 'package:movibus/auth/register_screen.dart';
import 'package:movibus/auth/reset_pass.dart';
import 'screen/home_screen.dart';
import 'screen/settings.dart';
import 'screen/statistics_screen.dart';
import 'screen/routes_screen.dart';
import 'welcome.dart';
import 'package:movibus/providers/themeprovider.dart';
import 'package:movibus/screen/profile_screen.dart';
import 'package:movibus/screen/location_test_screen.dart';
import 'package:provider/provider.dart';
import 'themes/theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Movibus',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
      routes: {
        '/home': (_) => const HomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/Welcome': (_) => const WelcomeScreen(),
        '/resetPass': (_) => const ResetPasswordScreen(),
        '/settings': (_) => SettingsScreen(),
        '/routes': (_) => const RoutesScreen(),
        '/routesHistory': (_) => const RoutesScreen(),
        '/routesBus': (_) => const BusRouteScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/EditProfile': (_) => const ProfileEditMenu(),
        '/EditProfilePersonal': (_) => const ProfileEditpersonal(),
        '/EditProfilePass': (_) => const ProfileEditPass(),
        '/EditProfileMail': (_) => const ProfileEditMail(),
        '/couponHistory': (_) => const CouponPromoHistorialScreen(),
        '/statistics': (_) => const StatisticsScreen(),
        '/locationTest': (_) => const LocationTestScreen(),
      },
    );
  }
}
