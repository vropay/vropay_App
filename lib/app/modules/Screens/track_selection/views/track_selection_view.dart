import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/app/modules/Screens/track_selection/controllers/track_selection_controller.dart';

import '../../../../../Components/bottom_navbar.dart';
import '../../../../../Components/top_navbar.dart';

class TrackSelectionView extends GetView<TrackSelectionController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomTopNavBar(selectedIndex: 2),
                SizedBox(height: 24),
                Row(
                  children: [
                    Text("build\nYour\nDream", style: TextStyle(fontSize: 70, fontWeight: FontWeight.w200, color: Color(0xFFE99041))),
                    Image.asset('assets/images/car.png', height: 186, width: 170,),
                  ],
                ),
                SizedBox(height: 30),
                _trackCard("demo,", "first Demo Class", Color(0xFFDAE9FB)),
                SizedBox(height: 20),
                _trackCard("beginner.", "foundational Learnings", Color(0xFFFAE8B2)),
                SizedBox(height: 20),
                _trackCard("Pro !", "advanced Teachings", Color(0xFFFCE0C0)),
                SizedBox(height: 30),
                Center(child: Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.end,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "yeahh.. ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                          TextSpan(
                            text: "done",
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.black,
                              fontWeight: FontWeight.w200
                            ),
                          ),
                        ],
                      ),
                    ),
                    Image.asset('assets/images/trophyBoy.png', height: 273, width: 210,),
                    SizedBox(height: 8),
                    Text('HUSTLE HARD', style: TextStyle(
                      color: Color(0xFF00BEBE),
                      fontSize: 25,
                    ),),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFCC5D),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // Wraps content tightly
                          children: [
                            Text(
                              "claim your rewards ",
                              style: TextStyle(
                                color: Color(0xFF007C8B),
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 8),
                            Image.asset(
                              'assets/icons/smile.png', // Replace with your actual image path
                              height: 20,
                              width: 20,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                )),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }

  Widget _trackCard(String title1, String title2, Color color) {
    return Center(
      child: Container(
        height: 355,
        width: 304,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title1,
              style: TextStyle(
                fontSize: 50,
                color: Color(0xFFE99041),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: Text(
                title2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w300,
                  color: Colors.black54,
                ),
              ),
            ),
            Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "know more →",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE99041),
                ),
              ),
            ),
          ],
        ),
      ),
    );
}
  }
