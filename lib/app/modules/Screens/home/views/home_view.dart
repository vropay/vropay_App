import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/app/modules/Screens/home/controllers/home_controller.dart';
import 'package:vropay_final/app/modules/Screens/home/widgets/interestScreen.dart';
import 'package:vropay_final/app/modules/Screens/home/widgets/userDetail.dart';
import 'package:vropay_final/app/modules/Screens/home/widgets/difficultyScreen.dart';
import 'package:vropay_final/app/modules/Screens/home/widgets/communityAccess.dart';
import 'package:vropay_final/app/modules/Screens/home/widgets/notificationPopUp.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        // Show user details form for new users
        if (controller.showUserDetailsForm.value) {
          return Obx(() {
            switch (controller.currentStep.value) {
              case 0:
                return UserDetail();
              case 1:
                return InterestsScreen();
              case 2:
                return DifficultyLevelScreen(
                    onNext: () => controller.nextStep());
              case 3:
                return CommunityAccessScreen(
                    onNext: () => controller.nextStep());
              case 4:
                return NotificationScreen(
                    onFinish: () => controller.nextStep());
              case 5:
                return _SubscriptionScreen();
              default:
                return UserDetail();
            }
          });
        }

        return IndexedStack(
          index: controller.currentIndex.value,
          children: [
            UserDetail(),
            InterestsScreen(),
          ],
        );
      }),
    );
  }
}

// Placeholder screens for onboarding flow
class _DifficultyScreen extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Select Difficulty Level', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.nextStep(),
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityAccessScreen extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Community Access', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.nextStep(),
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationScreen extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Enable Notifications?', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.nextStep(),
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionScreen extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Choose Subscription', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.completeOnboarding(),
              child: Text('Complete'),
            ),
          ],
        ),
      ),
    );
  }
}
