import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import 'package:vropay_final/app/modules/Screens/home/widgets/curvedTextField.dart';
import '../../onBoarding/widgets/faq_help.dart';
import '../controllers/home_controller.dart';

class UserDetail extends GetView<HomeController> {
  const UserDetail({super.key});

  @override
  Widget build(BuildContext context) {
    // Set the context for ScreenUtils
    ScreenUtils.setContext(context);
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: ScreenUtils.height * 0.02),
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(left: 44),
                margin: EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 48.69,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFC7D0D7),
                      fontFamily: GoogleFonts.mPlus2().fontFamily,
                    ),
                    children: [
                      TextSpan(text: "Welcome to\nVroPay "),
                      TextSpan(
                        text: "💙",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFC7D0D7),
                          fontFamily: GoogleFonts.mPlus2().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: ScreenUtils.height * 0.02),
              Container(
                  width: double.infinity,
                  color: Color(0xFFF7F7F7),
                  padding: EdgeInsets.only(left: 38),
                  child: Image.asset("assets/images/home.png", height: 212)),
              SizedBox(height: ScreenUtils.height * 0.01),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDEEAF1),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 53.0, right: 55, top: 11, bottom: 11),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: ScreenUtils.width * 0.3,
                              child: CurvedTextField(
                                controller: controller.firstNameController,
                                hint: 'first name',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CurvedTextField(
                              controller: controller.lastNameController,
                              hint: 'last name',
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ScreenUtils.height * 0.01),
                    Padding(
                      padding: EdgeInsets.only(left: 73, right: 69),
                      child: _genderSelector(),
                    ),
                    SizedBox(height: ScreenUtils.height * 0.01),
                    Padding(
                      padding: EdgeInsets.only(left: 63, right: 69),
                      child: _roleDropdown(),
                    ),
                    SizedBox(height: ScreenUtils.height * 0.04),
                    ElevatedButton(
                      onPressed: () {
                        if (controller.isUserDetailValid()) {
                          controller.nextPage();
                        } else {
                          Get.snackbar("Incomplete",
                              "Please fill in all required fields");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF172B75),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(38),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("proceed",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_right_alt,
                            color: Colors.white,
                            size: 25,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ScreenUtils.height * 0.021),
                    const FaqHelpText(),
                    SizedBox(height: ScreenUtils.height * 0.014),
                  ],
                ),
              ),
              SizedBox(height: ScreenUtils.height * 0.031),
              Padding(
                padding: const EdgeInsets.only(bottom: 12, top: 12),
                child: Image.asset(
                  'assets/images/vropayLogo.png',
                  height: 34,
                ),
              ),
              SizedBox(height: ScreenUtils.height * 0.026),
            ],
          ),
        ),
      ),
    );
  }

  Widget _genderSelector() {
    // Define genders and their custom sizes in parallel arrays
    final genders = ['female', 'Male', "don't want \nto disclose"];
    final genderSizes = [
      16.0,
      16.0,
      10.0
    ]; // Custom font sizes for each gender option
    final genderSelectedSizes = [19.0, 19.0, 13.0];

    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(genders.length, (index) {
          final gender = genders[index];
          final customSize = genderSizes[index];
          final customSelectedSize = genderSelectedSizes[index];
          final isSelected = gender == controller.selectedLevel.value;
          return GestureDetector(
            onTap: () => controller.selectLevel(gender),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xFF00B8F0) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                gender,
                style: TextStyle(
                  color: isSelected ? Colors.white : Color(0xFF00B8F0),
                  fontWeight: isSelected ? FontWeight.w400 : FontWeight.w300,
                  fontSize: isSelected ? customSelectedSize : customSize,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
            ),
          );
        }),
      );
    });
  }

  Widget _roleDropdown() {
    final roles = [
      {
        'value': 'Student',
        'icon': 'assets/icons/student.png',
        'color': Color(0xFF00B8F0),
        'size': 10.69
      },
      {
        'value': 'Working professional',
        'icon': 'assets/icons/workingProfessional.png',
        'color': Color(0xFF172B75),
        'size': 10.69
      },
      {
        'value': 'Business owner',
        'icon': 'assets/icons/businessOwner.png',
        'color': Color(0xFF00B8F0),
        'size': 10.69
      },
    ];

    return Obx(() {
      final selected = controller.selectedRole.value;

      return Material(
        color: Colors.transparent,
        child: SizedBox(
          height: ScreenUtils.height * 0.06,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/vectors/profession_dropdown.png',
                fit: BoxFit.fill,
                height: ScreenUtils.height * 0.06,
              ),
              PopupMenuButton<String>(
                offset: Offset(
                    6, ScreenUtils.height * 0.06), // Opens exactly at bottom
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                color: const Color(0xFFDEEAF1),
                child: Container(
                  height: ScreenUtils.height * 0.06,
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      left: 25, top: 5, bottom: 5, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (selected.isNotEmpty) ...[
                        Row(
                          children: [
                            Image.asset(
                              roles.firstWhere((role) =>
                                  role['value'] == selected)['icon'] as String,
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              selected,
                              style: TextStyle(
                                color: roles.firstWhere((role) =>
                                        role['value'] == selected)['color']
                                    as Color,
                                fontSize: roles.firstWhere((role) =>
                                        role['value'] == selected)['size']
                                    as double,
                                fontFamily: GoogleFonts.poppins().fontFamily,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          "you're a",
                          style: TextStyle(
                              color: Color(0xFF172B75),
                              fontSize: 17,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF1C1C4D),
                        size: 28,
                      ),
                    ],
                  ),
                ),
                itemBuilder: (context) => roles.map((role) {
                  final isSelected = role['value'] == selected;
                  return PopupMenuItem<String>(
                    value: role['value'] as String,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE5EBFF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      child: Row(
                        children: [
                          Image.asset(
                            role['icon'] as String,
                            width: 24,
                            height: 24,
                          ),
                          SizedBox(width: ScreenUtils.width * 0.01),
                          Flexible(
                            child: Text(
                              role['value'] as String,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: role['color'] as Color,
                                fontSize: role['size'] as double,
                                fontFamily: GoogleFonts.poppins().fontFamily,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onSelected: (value) {
                  controller.selectedRole.value = value;
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
