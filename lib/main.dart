import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Themes/themes.dart';
import 'app/modules/common/controller/bottom_navbar_controller.dart';
import 'app/routes/app_pages.dart';

void main() {
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
