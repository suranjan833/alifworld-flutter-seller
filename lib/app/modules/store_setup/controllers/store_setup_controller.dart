import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/onboarding_status_model.dart';
import '../../../data/services/api_service.dart';
import '../../../routes/app_pages.dart';
import '../steps/branding/branding_controller.dart';
import '../steps/compliance/compliance_controller.dart';
import '../steps/kyc/kyc_controller.dart';
import '../steps/review/review_controller.dart';
import '../steps/shop_info/shop_info_controller.dart';

class StoreSetupController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final currentStep = 1.obs; // 1 to 5
  final isLoadingStatus = false.obs;
  final isSavingDraft = false.obs;
  final isSubmitting = false.obs;

  final onboardingStatus = Rxn<OnboardingStatusModel>();

  late final ShopInfoController shopInfoController;
  late final BrandingController brandingController;
  late final ComplianceController complianceController;
  late final KycController kycController;
  late final ReviewController reviewController;

  @override
  void onInit() {
    super.onInit();
    shopInfoController = Get.put(ShopInfoController());
    brandingController = Get.put(BrandingController());
    complianceController = Get.put(ComplianceController());
    kycController = Get.put(KycController());
    reviewController = Get.put(ReviewController());

    loadOnboardingStatus();
  }

  Future<void> loadOnboardingStatus() async {
    isLoadingStatus.value = true;
    try {
      final res = await _api.getOnboardingStatus();
      if (res != null) {
        final statusModel = OnboardingStatusModel.fromJson(res);
        onboardingStatus.value = statusModel;

        // If already approved, directly proceed to seller dashboard
        if (statusModel.isApproved) {
          Get.snackbar(
            'Store Approved',
            'Your seller store is already verified and active.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          Get.offAllNamed(Routes.HOME);
          return;
        }

        // If pending admin review
        if (statusModel.isPending) {
          Get.offNamed(
            Routes.ONBOARDING_PENDING,
            arguments: {'shopName': statusModel.seller.shopName},
          );
          return;
        }

        // Pre-fill Step 1: Shop Info
        if (statusModel.seller.shopName.isNotEmpty) {
          shopInfoController.nameController.text = statusModel.seller.shopName;
        }
        if (statusModel.seller.slug.isNotEmpty) {
          shopInfoController.slugController.text = statusModel.seller.slug;
        }
        if (statusModel.seller.description.isNotEmpty) {
          shopInfoController.descController.text =
              statusModel.seller.description;
        }

        // Pre-fill Step 2: Branding
        if (statusModel.seller.logoUrl != null &&
            statusModel.seller.logoUrl!.isNotEmpty) {
          brandingController.logoUrl.value = statusModel.seller.logoUrl;
          brandingController.logoFileName.value = 'store_logo.png';
        }
        if (statusModel.seller.bannerUrl != null &&
            statusModel.seller.bannerUrl!.isNotEmpty) {
          brandingController.bannerUrl.value = statusModel.seller.bannerUrl;
          brandingController.bannerFileName.value = 'store_banner.jpg';
        }
        if (statusModel.seller.policies.isNotEmpty) {
          brandingController.policiesController.text =
              statusModel.seller.policies;
        }

        // Load geo divisions from API then configure compliance
        List<Map<String, dynamic>> geoDivisions = [];
        try {
          final rawDivisions = await _api.getDivisions();
          geoDivisions = rawDivisions
              .map(
                (d) => {
                  'id': d['id']?.toString() ?? '',
                  'name': d['name']?.toString() ?? '',
                },
              )
              .where((d) => d['name']!.isNotEmpty)
              .toList();
        } catch (_) {}

        // Pre-fill Step 3: Compliance (fully dynamic from API)
        complianceController.configureFromBackend(
          fields: statusModel.complianceFields,
          values: statusModel.values,
          geoDivisions: geoDivisions,
        );

        // Pre-fill Step 4: KYC Documents
        kycController.configureFromBackend(
          backendFields: statusModel.kycFields,
          uploadedDocs: statusModel.docs,
        );

        // Per §6: Wizard always starts at step 1, prefilled with existing draft data
        currentStep.value = 1;

        // Show rejection reason if status is 'rejected'
        if (statusModel.seller.status == OnboardingStatus.rejected &&
            statusModel.seller.rejectionReason != null &&
            statusModel.seller.rejectionReason!.isNotEmpty) {
          await Future.delayed(const Duration(milliseconds: 600));
          Get.snackbar(
            'Application Needs Update',
            'Reason: ${statusModel.seller.rejectionReason}. Please update the required details and resubmit.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            duration: const Duration(seconds: 6),
          );
        }
      }
    } catch (_) {
    } finally {
      isLoadingStatus.value = false;
    }
  }

  void goToStep(int step) {
    if (step >= 1 && step <= 5) {
      currentStep.value = step;
    }
  }

  void nextStep() async {
    bool isValid = false;
    switch (currentStep.value) {
      case 1:
        isValid = shopInfoController.validate();
        break;
      case 2:
        isValid = brandingController.validate();
        break;
      case 3:
        isValid = complianceController.validate();
        break;
      case 4:
        isValid = kycController.validate();
        break;
      case 5:
        isValid = reviewController.validate();
        break;
    }

    if (isValid) {
      if (currentStep.value < 5) {
        // Auto-save draft on step transition
        saveDraft(silent: true);
        currentStep.value++;
      } else {
        submitApplication();
      }
    }
  }

  void prevStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
    }
  }

  Map<String, dynamic> _buildDraftPayload() {
    final payload = <String, dynamic>{
      'shopName': shopInfoController.nameController.text.trim(),
      'slug': shopInfoController.slugController.text.trim(),
      'description': shopInfoController.descController.text.trim(),
      'policies': brandingController.policiesController.text.trim(),
      'compliance': complianceController.toCompliancePayload(),
    };

    if (brandingController.logoUrl.value != null &&
        brandingController.logoUrl.value!.isNotEmpty) {
      payload['logoUrl'] = brandingController.logoUrl.value!;
    }
    if (brandingController.bannerUrl.value != null &&
        brandingController.bannerUrl.value!.isNotEmpty) {
      payload['bannerUrl'] = brandingController.bannerUrl.value!;
    }

    return payload;
  }

  Future<void> saveDraft({bool silent = false}) async {
    isSavingDraft.value = true;
    try {
      final payload = _buildDraftPayload();
      final res = await _api.saveOnboardingDraft(payload);

      isSavingDraft.value = false;

      if (!silent) {
        if (res != null) {
          Get.snackbar(
            'Draft Saved',
            'Your store setup progress has been saved to the cloud.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.black87,
            colorText: Colors.white,
            margin: const EdgeInsets.all(12),
            duration: const Duration(seconds: 2),
          );
        } else {
          Get.snackbar(
            'Saved Locally',
            'Your changes are preserved locally.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.black87,
            colorText: Colors.white,
            margin: const EdgeInsets.all(12),
          );
        }
      }
    } catch (e) {
      isSavingDraft.value = false;
    }
  }

  Future<void> submitApplication() async {
    if (!reviewController.validate()) return;
    if (!shopInfoController.validate()) {
      currentStep.value = 1;
      return;
    }
    if (!brandingController.validate()) {
      currentStep.value = 2;
      return;
    }
    if (!complianceController.validate()) {
      currentStep.value = 3;
      return;
    }
    if (!kycController.validate()) {
      currentStep.value = 4;
      return;
    }

    isSubmitting.value = true;

    try {
      // 1. Ensure latest draft is saved
      final payload = _buildDraftPayload();
      await _api.saveOnboardingDraft(payload);

      // 2. Submit onboarding for verification
      final res = await _api.submitOnboarding();
      isSubmitting.value = false;

      if (res['ok'] == true) {
        Get.snackbar(
          'Application Submitted',
          'Your merchant application is submitted for verification.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offNamed(
          Routes.ONBOARDING_PENDING,
          arguments: {
            'shopName': shopInfoController.nameController.text.trim(),
          },
        );
      } else {
        final missing = res['missing'];
        String msg = res['message'] ?? 'Please complete required steps.';
        if (missing is List && missing.isNotEmpty) {
          msg = 'Missing: ${missing.join(', ')}';
        }
        Get.snackbar(
          'Submission Incomplete',
          msg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      isSubmitting.value = false;
      Get.snackbar(
        'Submission Error',
        'Could not complete submission. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
