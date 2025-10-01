import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:vropay_final/app/core/services/auth_service.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    try {
      final authService = Get.find<AuthService>();

      // If user is authenticated, redirect to home/dashboard
      if (authService.isLoggedIn.value &&
          authService.authToken.value.isNotEmpty) {
        return RouteSettings(name: Routes.DASHBOARD);
      }
    } catch (e) {
      // If AuthService is not initialized yet, allow navigation to continue
      print('AuthMiddleware: AuthService not ready yet, allowing navigation');
    }

    return null;
  }
}

class GuestMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    try {
      final authService = Get.find<AuthService>();

      // If user is not authenticated, redirect to onboarding
      if (!authService.isLoggedIn.value ||
          authService.authToken.value.isEmpty) {
        return RouteSettings(name: Routes.ON_BOARDING);
      }
    } catch (e) {
      // If AuthService is not initialized yet, redirect to onboarding
      print(
          'GuestMiddleware: AuthService not ready yet, redirecting to onboarding');
      return RouteSettings(name: Routes.ON_BOARDING);
    }
    return null;
  }
}
