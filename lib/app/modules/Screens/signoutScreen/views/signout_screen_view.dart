import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/app/modules/Screens/onBoarding/views/on_boarding_view.dart';


class SignoutScreenView extends StatelessWidget {
  const SignoutScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Get.off(() => OnBoardingView());
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/signoutsplash.png',
              height: 400,
              width: 400,
            ),
            const SizedBox(height: 20),
            const Text(
              textAlign: TextAlign.center,
              "come\n soon",
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006DF4),
                fontStyle: FontStyle.italic
              ),
            ),
            const SizedBox(height: 40),
            Image.asset('assets/images/vropayLogo.png',
            height: 40,),
          ],
        ),
      ),
    );
  }
}
