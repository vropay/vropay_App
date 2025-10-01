import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vropay_final/app/core/network/api_client.dart';
import 'package:vropay_final/app/core/services/auth_service.dart';
import 'package:vropay_final/app/core/services/forum_service.dart';
import 'package:vropay_final/app/core/services/knowledge_service.dart';
import 'package:vropay_final/app/core/services/learn_service.dart';
import 'package:vropay_final/app/core/services/user_service.dart';

import 'Themes/themes.dart';
import 'app/modules/common/controller/bottom_navbar_controller.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.config(enableLog: false);

  // Disable debug logs in release mode
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // Initialize GetStorage
  await GetStorage.init();

  // Initialize API client
  ApiClient().init();

  // Initialize all services
  Get.put(AuthService(), permanent: true);
  Get.put(UserService(), permanent: true);
  Get.put(KnowledgeService(), permanent: true);
  Get.put(ForumService(), permanent: true);
  Get.put(LearnService(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'VroPay App',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      getPages: AppPages.routes,
      initialRoute: AppPages.INITIAL,

      // Add these configurations for better hot reload
      builder: (context, child) {
        // Initialize the controller here for better hot reload
        Get.put(BottomNavController(), permanent: true);
        return child!;
      },
    );
  }
}
