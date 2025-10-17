import 'package:get/get.dart';
import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/theme/theme_controller.dart';
import 'package:news_app/theme/theme_service.dart';

class AppBindings implements Bindings {
  @override
  void dependencies() {
    // Theme Management - GUNAKAN Put BUKAN LazyPut untuk immediate initialization
    Get.put(ThemeController(), permanent: true);
    Get.put(ThemeService(), permanent: true);
    
    // Controllers
    Get.lazyPut<NewsController>(() => NewsController());
    
    // Initialize theme service
    Get.find<ThemeService>().initialize();
  }
}