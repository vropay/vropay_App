import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Components/top_navbar.dart';
import '../../../../../Components/bottom_navbar.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: const [
            CustomTopNavBar(),
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
    );
  }
}
