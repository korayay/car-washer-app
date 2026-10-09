import 'package:flutter/material.dart';

class AppTheme {
  // Ana renk paleti - Modern türkuaz/cyan tonu
  static const Color primaryColor = Color(0xFF00BCD4); // Cyan 500 
  static const Color primaryDark = Color(0xFF0097A7); // Cyan 700
  static const Color primaryLight = Color(0xFF26C6DA); // Cyan 400
  static const Color secondaryColor = Color(0xFF00E676); // Green Accent 400
  static const Color accentColor = Color(0xFFFF5722); // Deep Orange 500
  
  // Arka plan ve yüzey renkleri
  static const Color backgroundColor = Color(0xFFF8FAFB);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color successColor = Color(0xFF38A169);
  static const Color warningColor = Color(0xFFED8936);
  
  // Metin renkleri
  static const Color onSurfaceColor = Color(0xFF1A202C);
  static const Color textPrimaryColor = Color(0xFF2D3748);
  static const Color textSecondaryColor = Color(0xFF718096);
  
  // Yeşil tema renkleri (çevre dostu özellik için)
  static const Color greenPrimary = Color(0xFF48BB78);
  static const Color greenSecondary = Color(0xFF68D391);
  static const Color greenLight = Color(0xFFF0FFF4);
  
  // Gri tonları - Tailwind CSS inspired
  static const Color grey50 = Color(0xFFF7FAFC);
  static const Color grey100 = Color(0xFFEDF2F7);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E0);
  static const Color grey400 = Color(0xFFA0AEC0);
  static const Color grey500 = Color(0xFF718096);
  static const Color grey600 = Color(0xFF4A5568);
  static const Color grey700 = Color(0xFF2D3748);
  static const Color grey800 = Color(0xFF1A202C);
  static const Color grey900 = Color(0xFF171923);

  // Gradient renkleri
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryColor],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [greenSecondary, greenPrimary],
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      
      // AppBar Teması
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: onSurfaceColor,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          color: onSurfaceColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Buton Teması
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined Button Teması
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: primaryColor),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Card Teması
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Input Decoration Teması
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: grey100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Text Teması
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: onSurfaceColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: onSurfaceColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: onSurfaceColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: textSecondaryColor,
        ),
      ),
      
      // Floating Action Button Teması
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      
      // Bottom Navigation Bar Teması
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryColor,
        unselectedItemColor: grey500,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      
      // Dark tema için özel ayarlar
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      
      cardTheme: const CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        color: Color(0xFF2D2D2D),
      ),
    );
  }
} 