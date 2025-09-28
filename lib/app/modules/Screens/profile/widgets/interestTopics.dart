import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:vropay_final/app/modules/Screens/profile/controllers/profile_controller.dart';

class InterestSelectionDialog extends StatelessWidget {
  final ProfileController profileController;
  final RxString selectedValue;

  const InterestSelectionDialog({
    Key? key,
    required this.profileController,
    required this.selectedValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Interests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Obx(() => Container(
                  height: 300,
                  child: ListView(
                    children: profileController.interests.map((interest) {
                      final isSelected = profileController.selectedInterests.contains(interest);
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? Color(0xFFEAF1FF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected ? Border.all(color: Color(0xFF4D84F7), width: 1) : null,
                        ),
                        child: CheckboxListTile(
                          title: Text(
                            interest,
                            style: TextStyle(
                              color: isSelected ? Color(0xFF4D84F7) : Colors.black,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          value: isSelected,
                          activeColor: Color(0xFF4D84F7),
                          onChanged: (bool? value) {
                            profileController.toggleInterest(interest);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                )),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    profileController.saveSelectedInterests();
                    Get.back();
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
