import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../shop_info/shop_info_controller.dart';
import '../branding/branding_controller.dart';
import '../compliance/compliance_controller.dart';
import '../kyc/kyc_controller.dart';

class ReviewController extends GetxController {
  final agreedToTerms = true.obs;

  ShopInfoController get shopController => Get.find<ShopInfoController>();
  BrandingController get brandingController => Get.find<BrandingController>();
  ComplianceController get complianceController => Get.find<ComplianceController>();
  KycController get kycController => Get.find<KycController>();

  void toggleTerms(bool? val) {
    agreedToTerms.value = val ?? false;
  }

  bool validate() {
    if (!agreedToTerms.value) {
      Get.snackbar(
        'Terms & Conditions',
        'Please agree to the Alifworld Seller Terms & Merchant Policies',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }
}

