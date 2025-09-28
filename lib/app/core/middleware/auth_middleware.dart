import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:vropay_final/app/core/services/auth_service.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    // If user is authenticated, redirect to home/dashboard
    if (authService.isAuthenticated) {
      return RouteSettings(name: Routes.DASHBOARD);
    }

    return null;
  }
}

class GuestMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    // If user is not authenticated, redirect to onboarding
    if (!authService.isAuthenticated) {
      return RouteSettings(name: Routes.ON_BOARDING);
    }
    return null;
  }
}
