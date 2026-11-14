import 'package:flutter/material.dart';

class GiaoDienApp {
  static const Color mauChinh = Color(0xFFE07852);
  static const Color mauChiTieu = Color(0xFFE07852);
  static const Color mauNenSang = Color(0xFFF7F8F4);
  static const Color mauChuToiSang = Color(0xFF1E232A);

  // Tông màu Dark Mode Đêm huyền bí chuẩn theo ảnh
  static const Color mauNenToi = Color(0xFF0F172A);
  static const Color mauTheToi = Color(0xFF1E293B);
  static const Color mauChuToiDark = Color(0xFFF8FAFC);

  static ThemeData get themeSang {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      primaryColor: mauChinh,
      colorScheme: ColorScheme.fromSeed(
        seedColor: mauChinh,
        primary: mauChinh,
        surface: Colors.transparent,
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: mauChuToiSang,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: mauChuToiSang),
      ),
    );
  }

  static ThemeData get themeToi {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      primaryColor: mauChinh,
      colorScheme: ColorScheme.fromSeed(
        seedColor: mauChinh,
        primary: mauChinh,
        surface: Colors.transparent,
        brightness: Brightness.dark,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: mauChuToiDark,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: mauChuToiDark),
      ),
    );
  }
}
