import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Orange Theme
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8C61);
  static const Color primaryDark = Color(0xFFE55A2B);
  
  // Secondary Colors - Green Theme
  static const Color secondary = Color(0xFF00D9A3);
  static const Color secondaryLight = Color(0xFF2FFFBE);
  static const Color secondaryDark = Color(0xFF00B589);
  
  // Accent Colors
  static const Color accent = Color(0xFFFFC857);
  static const Color accentLight = Color(0xFFFFD97D);
  
  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF0F1419);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A1F26);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A1D29);
  static const Color textPrimaryDark = Color(0xFFE8EAED);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textSecondaryDark = Color(0xFF9AA0A6);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textHintDark = Color(0xFF5F6368);
  
  // UI Elements
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF2D3339);
  static const Color divider = Color(0xFFEEF0F2);
  static const Color dividerDark = Color(0xFF2D3339);
  
  // Status Colors
  static const Color success = Color(0xFF00D9A3);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  
  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x40000000);
  
  // Gradients - Orange to Green
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B35),
      Color(0xFFFF8C61),
    ],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00D9A3),
      Color(0xFF2FFFBE),
    ],
  );
  
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B35),
      Color(0xFFFF8C61),
      Color(0xFFFFC857),
      Color(0xFF00D9A3),
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFFFBF7),
    ],
  );
  
  static const LinearGradient cardGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1F26),
      Color(0xFF1F2530),
    ],
  );
  
  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment(-1.0, 0.0),
    end: Alignment(1.0, 0.0),
    colors: [
      Color(0xFFE5E7EB),
      Color(0xFFF3F4F6),
      Color(0xFFE5E7EB),
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient shimmerGradientDark = LinearGradient(
    begin: Alignment(-1.0, 0.0),
    end: Alignment(1.0, 0.0),
    colors: [
      Color(0xFF2D3339),
      Color(0xFF3D4349),
      Color(0xFF2D3339),
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  // Glass Morphism Effect Colors
  static Color glassLight = Colors.white.withOpacity(0.7);
  static Color glassDark = Colors.black.withOpacity(0.3);
  
  // Mesh Gradient Background (for advanced effects)
  static const List<Color> meshColors = [
    Color(0xFFFF6B35),
    Color(0xFF00D9A3),
    Color(0xFFFFC857),
    Color(0xFFFF8C61),
  ];
  
  // Get adaptive colors based on brightness
  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
      ? textPrimaryDark 
      : textPrimary;
  }
  
  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
      ? textSecondaryDark 
      : textSecondary;
  }
  
  static Color getTextHint(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
      ? textHintDark 
      : textHint;
  }
  
  static Color getBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
      ? backgroundDark 
      : background;
  }
  
  static Color getSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
      ? surfaceDark 
      : surface;
  }
  
  static Color getBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
      ? borderDark 
      : border;
  }
  
  static Color getDivider(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
      ? dividerDark 
      : divider;
  }
  
  static LinearGradient getCardGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
      ? cardGradientDark 
      : cardGradient;
  }
  
  static LinearGradient getShimmerGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
      ? shimmerGradientDark 
      : shimmerGradient;
  }
  
  static Color getGlass(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
      ? glassDark 
      : glassLight;
  }
}

// Extension untuk gradient scaling dengan opacity
extension GradientExtension on LinearGradient {
  LinearGradient scale(double opacity) {
    return LinearGradient(
      colors: colors.map((color) => color.withOpacity(opacity)).toList(),
      begin: begin,
      end: end,
      stops: stops,
    );
  }
  
  LinearGradient withOpacities(List<double> opacities) {
    assert(opacities.length == colors.length);
    return LinearGradient(
      colors: List.generate(
        colors.length, 
        (i) => colors[i].withOpacity(opacities[i])
      ),
      begin: begin,
      end: end,
      stops: stops,
    );
  }
}