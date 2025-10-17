import 'package:get/get.dart';
import 'package:news_app/theme/theme_controller.dart';

class ThemeService extends GetxService {
  static ThemeService get instance => Get.find();
  
  ThemeController get _themeController => Get.find<ThemeController>();
  
  // Initialize theme service
  void initialize() {
    _themeController.initializeTheme();
  }
  
  // Get current theme mode
  bool get isDarkMode => _themeController.isDarkMode.value;
  
  // Toggle theme
  void toggleTheme() {
    _themeController.toggleTheme();
  }
  
  // Set specific theme
  void setDarkMode(bool isDark) {
    _themeController.setDarkMode(isDark);
  }
}