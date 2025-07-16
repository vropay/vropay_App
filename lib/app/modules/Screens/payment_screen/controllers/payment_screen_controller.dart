import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum PaymentMethod { card, upi }

class PaymentScreenController extends GetxController {
  var selectedMethod = Rx<PaymentMethod?>(null);

  // Card form
  final cardNumber = TextEditingController();
  final cvv = TextEditingController();
  final expiry = TextEditingController();
  final cardHolder = TextEditingController();
  var isCardValid = false.obs;
  var showCardError = false.obs;
  var isCardFormFilled = false.obs;


  // UPI form
  final upiId = TextEditingController();
  var isUpiValid = false.obs;
  var showUpiError = false.obs;
  var selectedUpiApp = ''.obs;

  final upiApps = [
    {"name": "GPay", "image": "assets/icons/gpay.png"},
    {"name": "Paytm", "image": "assets/icons/paytm.png"},
    {"name": "PhonePe", "image": "assets/icons/phonepe.png"},
  ].obs;


  void switchMethod(PaymentMethod method) {
    if (selectedMethod.value == method) {
      selectedMethod.value = null;
    } else {
      selectedMethod.value = method;
    }
  }

  void validateCard() {
    bool valid = cardNumber.text.length == 12 &&
        cvv.text.length == 3 &&
        expiry.text.isNotEmpty &&
        cardHolder.text.isNotEmpty;
    isCardValid.value = valid;
    showCardError.value = !valid;
  }

  void validateUpi() {
    bool valid = upiId.text.contains("@");
    isUpiValid.value = valid;
    showUpiError.value = !valid;
  }

  void selectUpiApp(String app) {
    selectedUpiApp.value = app;
  }

  void updateCardFormStatus() {
    isCardFormFilled.value =
        cardNumber.text.length == 12 &&
            cvv.text.length == 3 &&
            expiry.text.isNotEmpty &&
            cardHolder.text.isNotEmpty;
  }

  bool get isUpiFormFilled =>
      (upiId.text.contains("@") || selectedUpiApp.value.isNotEmpty);
}
