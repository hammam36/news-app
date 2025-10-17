import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:news_app/bindings/app_binding.dart';
import 'package:news_app/routes/app_pages.dart';
// import 'package:news_app/utils/app_colors.dart';
import 'package:news_app/theme/app_theme.dart';
import 'package:news_app/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Modern News',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      initialBinding: AppBindings(), // Binding akan initialize ThemeController
      debugShowCheckedModeBanner: false,
      // FIX: Gunakan approach yang lebih simple dan reliable
      builder: (context, child) {
        return Obx(() {
          // Cek jika ThemeController sudah ter-register
          if (Get.isRegistered<ThemeController>()) {
            final themeController = Get.find<ThemeController>();
            return Theme(
              data: themeController.isDarkMode.value ? AppTheme.darkTheme : AppTheme.lightTheme,
              child: child!,
            );
          } else {
            // Fallback ke system theme jika controller belum ready
            final systemDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
            return Theme(
              data: systemDark ? AppTheme.darkTheme : AppTheme.lightTheme,
              child: child!,
            );
          }
        });
      },
    );
  }
}