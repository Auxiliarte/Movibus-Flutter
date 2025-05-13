import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.lightPrimaryButton,

    // Usamos extensions del Map<String, dynamic> para almacenar colores personalizados
    colorScheme: ColorScheme.light(
      background: AppColors.lightBackground,
      primary: AppColors.lightPrimaryButton,
      secondary: AppColors.lightSecondaryButton,
      surface: AppColors.lightMenuBackground,
      onSurface: AppColors.lightTextPrimary,
    ),

    dialogBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
    cardColor: const Color(0xFF2A154D),
    secondaryHeaderColor: AppColors.lightBodyBackground,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightInputBackground,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.lightInputBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.lightInputFocus),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: AppColors.lightTextPrimary,
        fontFamily: 'Quicksand',
      ),
      bodySmall: TextStyle(
        color: AppColors.lightTextSecondary,
        fontFamily: 'Quicksand',
      ),
      labelMedium: TextStyle(
        color: AppColors.lightTextDisabled,
        fontFamily: 'Quicksand',
      ),
      titleMedium: TextStyle(
        color: AppColors.lightTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
        fontFamily: 'Quicksand',
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimaryButton,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.lightOutlineButton,
        side: const BorderSide(color: AppColors.lightOutlineButton),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    ),
    switchTheme: SwitchThemeData(
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.lightswithcActive;
        }
        return const Color.fromARGB(255, 223, 223, 223);
      }),
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        return Colors.white; // bolita siempre blanca
      }),
      trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.darkPrimaryButton,

    colorScheme: ColorScheme.dark(
      background: AppColors.darkBackground,
      primary: AppColors.darkPrimaryButton,
      secondary: AppColors.darkSecondaryButton,
      surface: AppColors.darkMenuBackground,
      onSurface: AppColors.darkTextPrimary,
    ),
    dialogBackgroundColor: AppColors.darkbanCoup,
    cardColor: AppColors.darkProfileHeader,

    secondaryHeaderColor: AppColors.darkBodyBackground,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkInputBackground,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.darkInputBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.darkInputFocus),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: AppColors.darkTextPrimary,
        fontFamily: 'Quicksand',
      ),
      bodySmall: TextStyle(
        color: AppColors.darkTextPrimary,
        fontFamily: 'Quicksand',
      ),
      labelMedium: TextStyle(
        color: AppColors.darkTextDisabled,
        fontFamily: 'Quicksand',
      ),
      titleMedium: TextStyle(
        color: AppColors.darkTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
        fontFamily: 'Quicksand',
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimaryButton,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.lightOutlineButton,
        side: const BorderSide(color: AppColors.lightOutlineButton),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    ),
    switchTheme: SwitchThemeData(
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.darkswithcActive;
        }
        return const Color.fromARGB(255, 223, 223, 223);
      }),
      thumbColor: MaterialStateProperty.all(Colors.white),
      trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
    ),
  );
}
