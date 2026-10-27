import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/onboarding_status_model.dart';
import '../../../data/services/api_service.dart';
import '../../../routes/app_pages.dart';

class OnboardingPendingController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final ApiService _api = Get.find<ApiService>();

  final shopName = 'Your Shop'.obs;
  final isCheckingStatus = false.obs;
  late final AnimationController radarAnimController;

  @override
  void onInit() {
    super.onInit();
    radarAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    final args = Get.arguments;
    if (args is Map && args['shopName'] != null && (args['shopName'] as String).isNotEmpty) {
      shopName.value = args['shopName'];
    }
    refreshStatus(silent: true);
  }

  @override
  void onClose() {
    radarAnimController.dispose();
    super.onClose();
  }

  Future<void> refreshStatus({bool silent = false}) async {
    isCheckingStatus.value = true;
    try {
      final res = await _api.getOnboardingStatus();
      isCheckingStatus.value = false;

      if (res != null) {
        final statusModel = OnboardingStatusModel.fromJson(res);
        if (statusModel.seller.shopName.isNotEmpty) {
          shopName.value = statusModel.seller.shopName;
        }

        if (statusModel.isApproved) {
          Get.snackbar(
            'Application Approved!',
            'Congratulations, your merchant store has been approved.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          Get.offAllNamed(Routes.HOME);
          return;
        }

        if (statusModel.isRejected) {
          Get.snackbar(
            'Application Needs Update',
            statusModel.seller.rejectionReason ?? 'Please update your compliance details or KYC docs.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          Get.offAllNamed(Routes.STORE_SETUP);
          return;
        }

        if (!silent) {
          Get.snackbar(
            'Verification In Progress',
            'Your application is currently under review by our compliance team.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.black87,
            colorText: Colors.white,
          );
        }
      }
    } catch (_) {
      isCheckingStatus.value = false;
    }
  }

  Future<void> logout() async {
    await _api.logout();
    Get.offAllNamed(Routes.SELLER_GATE);
  }
}
