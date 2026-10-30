import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/coupon_model.dart';
import '../../../data/services/api_service.dart';

class CouponsController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final isLoading = true.obs;
  final isSubmitting = false.obs;
  final coupons = <CouponModel>[].obs;

  // Inline "New coupon" Form State & Fields (Matches Web Panel)
  final showNewCouponForm = false.obs;
  final codeController = TextEditingController();
  final descriptionController = TextEditingController();
  final discountType = 'Percentage'.obs; // 'Percentage' | 'Fixed'
  final discountValueController = TextEditingController();
  final minOrderMinorController = TextEditingController();
  final usageLimitController = TextEditingController();
  final startsAt = Rxn<DateTime>();
  final endsAt = Rxn<DateTime>();
  final isActive = true.obs;

  final List<String> discountTypeList = ['Percentage', 'Fixed'];

  @override
  void onInit() {
    super.onInit();
    initDefaultDates();
    fetchCoupons();
  }

  void initDefaultDates() {
    final now = DateTime.now();
    startsAt.value = now;
    endsAt.value = now.add(const Duration(hours: 1));
  }

  @override
  void onClose() {
    codeController.dispose();
    descriptionController.dispose();
    discountValueController.dispose();
    minOrderMinorController.dispose();
    usageLimitController.dispose();
    super.onClose();
  }

  void toggleNewCouponForm() {
    showNewCouponForm.value = !showNewCouponForm.value;
    if (showNewCouponForm.value) {
      initDefaultDates();
    } else {
      clearForm();
    }
  }

  void clearForm() {
    codeController.clear();
    descriptionController.clear();
    discountType.value = 'Percentage';
    discountValueController.clear();
    minOrderMinorController.clear();
    usageLimitController.clear();
    initDefaultDates();
    isActive.value = true;
  }

  Future<void> fetchCoupons() async {
    isLoading.value = true;
    try {
      final list = await _api.getCoupons();
      coupons.value = list
          .map((item) => CouponModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {}
    isLoading.value = false;
  }

  /// Create Coupon (`POST /seller/coupons`)
  Future<bool> submitCoupon() async {
    final code = codeController.text.trim().toUpperCase();
    final discVal = int.tryParse(discountValueController.text.trim()) ?? 0;

    if (code.isEmpty) {
      Get.snackbar(
        'Field Required',
        'Please enter a coupon code.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
      );
      return false;
    }

    if (discVal <= 0) {
      Get.snackbar(
        'Field Required',
        discountType.value == 'Percentage'
            ? 'Please enter a percentage discount (e.g. 10 for 10%).'
            : 'Please enter discount amount in minor units (e.g. 5000 for ৳50).',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
      );
      return false;
    }

    if (discountType.value == 'Percentage' && discVal > 100) {
      Get.snackbar(
        'Invalid Value',
        'Percentage discount cannot exceed 100%.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }

    final minOrder = int.tryParse(minOrderMinorController.text.trim()) ?? 0;
    final usage = int.tryParse(usageLimitController.text.trim());

    final Map<String, dynamic> payload = {
      'code': code,
      'type': discountType.value == 'Percentage' ? 'percent' : 'flat',
      'value': discVal,
      'minOrderMinor': minOrder,
      'isActive': isActive.value,
    };

    if (usage != null && usage > 0) {
      payload['usageLimit'] = usage;
    }

    if (startsAt.value != null) {
      payload['startsAt'] = startsAt.value!.toIso8601String();
    }

    if (endsAt.value != null) {
      payload['endsAt'] = endsAt.value!.toIso8601String();
    }

    isSubmitting.value = true;
    final res = await _api.createCoupon(payload);
    isSubmitting.value = false;

    if (res != null && res['error'] == null) {
      clearForm();
      showNewCouponForm.value = false;

      Get.snackbar(
        'Coupon Created',
        'Coupon "$code" created successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
      await fetchCoupons();
      return true;
    } else {
      final errorMsg = res?['error']?.toString() ??
          'Could not create coupon. Check code uniqueness.';
      Get.snackbar(
        'Failed',
        errorMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// Toggle Coupon Status (`PUT /seller/coupons/{id}`)
  Future<void> toggleCouponActive(CouponModel coupon) async {
    final updatedActive = !coupon.isActive;
    final ok = await _api.updateCoupon(coupon.id, {'isActive': updatedActive});
    if (ok != null && ok['error'] == null) {
      await fetchCoupons();
    } else {
      Get.snackbar(
        'Update Failed',
        'Could not update coupon status.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  /// Delete Coupon (`DELETE /seller/coupons/{id}`)
  Future<void> deleteCoupon(String id) async {
    final ok = await _api.deleteCoupon(id);
    if (ok) {
      coupons.removeWhere((c) => c.id == id);
      Get.snackbar(
        'Deleted',
        'Coupon removed successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Delete Failed',
        'Could not delete coupon.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
