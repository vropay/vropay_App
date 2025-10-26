import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import '../../../../../Components/top_navbar.dart';
import '../../../../../Components/bottom_navbar.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtils.setContext(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        // Prevent back button from closing main screen
        if (didPop) return;
        // Do nothing - stay on current screen
      },
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(ScreenUtils.height * 0.15),
            child: CustomTopNavBar(isMainScreen: true)),
        body: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'DashboardView is working',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomBottomNavBar(),
      ),
    );
  }
}
