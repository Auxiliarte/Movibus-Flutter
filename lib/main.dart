import 'package:flutter/material.dart';
import 'package:moventra/screen/coupon_promo_screen.dart';
import 'package:moventra/screen/profile_edit_personal_screen.dart';
import 'package:moventra/screen/profile_edit_pass_screen.dart';
import 'package:moventra/screen/profile_edit_screen.dart';
import 'package:moventra/screen/profile_mail_screen.dart';
import 'package:moventra/screen/route_bus_screen.dart';
import 'package:moventra/screen/router_history.dart';
import 'splash_screen.dart';
import 'package:moventra/auth/login_screen.dart';
import 'package:moventra/auth/register_screen.dart';
import 'package:moventra/auth/reset_pass.dart';
import 'screen/home_screen.dart';
import 'screen/settings.dart';

import 'screen/routes_screen.dart';
import 'welcome.dart';
import 'package:moventra/providers/themeprovider.dart';
import 'package:moventra/screen/profile_screen.dart';
import 'package:moventra/screen/location_test_screen.dart';
import 'package:moventra/screen/location_picker_screen.dart';
import 'package:moventra/screen/region_settings_screen.dart';
import 'package:provider/provider.dart';
import 'themes/theme.dart';
import 'services/region_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar el servicio de regiones
  await RegionService.initialize();
  
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
    return GestureDetector(
      onTap: () {
        // Cerrar el teclado cuando se toca en cualquier lugar
        FocusScope.of(context).unfocus();
      },
      child: MaterialApp(
        title: 'Moventra',
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
          '/regionSettings': (_) => const RegionSettingsScreen(),

          '/locationTest': (_) => const LocationTestScreen(),
          '/locationPicker': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
            return LocationPickerScreen(
              title: args?['title'] ?? 'Seleccionar ubicación',
              initialAddress: args?['initialAddress'],
            );
          },
        },
      ),
    );
  }
}
