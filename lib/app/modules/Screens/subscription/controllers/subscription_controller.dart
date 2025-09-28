import 'package:get/get.dart';
import 'package:vropay_final/app/modules/Screens/subscription/widgets/free_pop_up.dart';

import '../../../../routes/app_pages.dart';
import '../../TrialTransitionView/trial_transition_view.dart';

enum UserType { student, professional, business }

class SubscriptionController extends GetxController {
  var userType = UserType.student.obs;
  var selectedPlan = 'yearly'.obs;
  var enableTrial = false.obs;
  var isOnboardingFlow = false.obs;

  bool _navigating = false;

  @override
  void onInit() {
    super.onInit();
    // Check if this is part of onboarding flow
    final args = Get.arguments;
    if (args != null && args['isOnboarding'] == true) {
      isOnboardingFlow.value = true;
    }
  }

  void toggleTrial(bool value) {
    enableTrial.value = value;

    if (value && !_navigating) {
      _navigating = true;

      Get.dialog(
        FreePopUp(
          onYesPressed: () {
            Get.toNamed(Routes.PAYMENT_SCREEN);
            _navigating = false;
          },
          onSkipPressed: () {
            if (isOnboardingFlow.value) {
              Get.offAllNamed(Routes.PROFILE);
            } else {
              Get.to(() => TrialTransitionView());
              Future.delayed(const Duration(seconds: 3), () {
                Get.offAllNamed(Routes.DASHBOARD);
              });
            }
            _navigating = false;
          },
        ),
        barrierDismissible: false,
      );
    }
  }

  void selectPlan(String plan) => selectedPlan.value = plan;
  void setUserType(UserType type) => userType.value = type;
}
