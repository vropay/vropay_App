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
                width: double.infinity,
                child: Text(
                  "Welcome to\nVroPay 💙",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFC7D0D7),
                    fontFamily: GoogleFonts.mPlus2().fontFamily,
                  ),
                ),
              ),
              SizedBox(height: ScreenUtils.height * 0.02),
              Container(
                  width: double.infinity,
                  color: Color(0xFFF7F7F7),
                  child: Image.asset("assets/images/home.png", height: 212)),
              SizedBox(height: ScreenUtils.height * 0.01),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFDEEAF1),
                ),
                child: Column(
                  children: [
                    Row(
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
                    SizedBox(height: ScreenUtils.height * 0.01),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: _genderSelector(),
                    ),
                    SizedBox(height: ScreenUtils.height * 0.01),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
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
                    SizedBox(height: ScreenUtils.height * 0.01),
                    const FaqHelpText()
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12, top: 12),
                child: Image.asset(
                  'assets/images/vropayLogo.png',
                  height: 34,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _genderSelector() {
    final genders = ['female', 'Male', "don't want \nto disclose"];
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: genders.map((gender) {
          final isSelected = gender == controller.selectedLevel.value;
          return GestureDetector(
            onTap: () => controller.selectLevel(gender),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xFF00B8F0) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                gender,
                style: TextStyle(
                  color: isSelected ? Colors.white : Color(0xFF00B8F0),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w300,
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _roleDropdown() {
    final roles = [
      {'value': 'Student', 'icon': 'assets/icons/student.png'},
      {
        'value': 'Working professional',
        'icon': 'assets/icons/workingProfessional.png'
      },
      {'value': 'Business owner', 'icon': 'assets/icons/businessOwner.png'},
    ];

    return Obx(() {
      final selected = controller.selectedRole.value;

      return SizedBox(
        height: ScreenUtils.height * 0.06,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/vectors/profession_dropdown.png',
              fit: BoxFit.fill,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selected.isEmpty ? null : selected,
                  // Remove the default icon so we can position our own
                  icon: const SizedBox.shrink(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1C1C4D),
                  ),
                  alignment: Alignment.center,
                  dropdownColor: const Color(0xFFDEEAF1),
                  hint: const Center(
                    child: Text(
                      "you’re a",
                      style: TextStyle(
                          color: Color(0xFF172B75),
                          fontSize: 17,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  selectedItemBuilder: (context) {
                    return roles.map((role) {
                      return Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              role['icon']!,
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(role['value']!),
                          ],
                        ),
                      );
                    }).toList();
                  },
                  items: roles.map((role) {
                    final isSelected = role['value'] == selected;

                    return DropdownMenuItem<String>(
                      value: role['value'],
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
                              role['icon']!,
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                role['value']!,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedRole.value = value ?? '';
                  },
                ),
              ),
            ),
            // Custom positioned down arrow
            Positioned(
              right: 25, // adjust as needed for your design
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF1C1C4D),
                size: 28,
              ),
            ),
          ],
        ),
      );
    });
  }
}
