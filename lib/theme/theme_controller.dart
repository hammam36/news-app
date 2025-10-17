import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  var isDarkMode = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Delay initialization sedikit untuk pastikan everything is ready
    Future.delayed(Duration.zero, () {
      initializeTheme();
    });
  }
  
  // Initialize from system preference
  void initializeTheme() {
    try {
      // Check system theme
      final Brightness systemBrightness = Get.mediaQuery.platformBrightness;
      isDarkMode.value = systemBrightness == Brightness.dark;
      print('ThemeController initialized: ${isDarkMode.value ? 'Dark' : 'Light'}');
    } catch (e) {
      // Fallback to light theme if error
      isDarkMode.value = false;
      print('ThemeController fallback to light theme: $e');
    }
  }
  
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    print('Theme toggled to: ${isDarkMode.value ? 'Dark' : 'Light'}');
    update();
  }
  
  void setDarkMode(bool value) {
    isDarkMode.value = value;
    update();
  }
}