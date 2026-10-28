import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../data/theme/app_colors.dart';
import '../../../data/widgets/common_widgets.dart';
import '../../../routes/app_pages.dart';
import '../controllers/store_setup_controller.dart';
import '../steps/shop_info/shop_info_view.dart';
import '../steps/branding/branding_view.dart';
import '../steps/compliance/compliance_view.dart';
import '../steps/kyc/kyc_view.dart';
import '../steps/review/review_view.dart';

class StoreSetupView extends GetView<StoreSetupController> {
  const StoreSetupView({super.key});

  void _handleBack(BuildContext context) {
    if (controller.currentStep.value > 1) {
      controller.prevStep();
    } else {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Get.offAllNamed(Routes.SELLER_GATE);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 1,
          titleSpacing: 0,
          leading: IconButton(
            icon: Icon(Iconsax.arrow_left_2, color: AppColors.textPrimary, size: 20.sp),
            onPressed: () => _handleBack(context),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 24.h,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Icon(Iconsax.shop, color: AppColors.primary, size: 15.sp),
                ),
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Store Setup',
                    style: GoogleFonts.inter(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Obx(
              () => Container(
                margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
                child: InkWell(
                  onTap: controller.isSavingDraft.value ? null : controller.saveDraft,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        controller.isSavingDraft.value
                            ? SizedBox(
                                width: 11.w,
                                height: 11.w,
                                child: const CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(Iconsax.document_download, size: 13.sp, color: AppColors.textSecondary),
                        SizedBox(width: 4.w),
                        Text(
                          'Draft',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 2.w),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Step Content Body
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingStatus.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  switch (controller.currentStep.value) {
                    case 1:
                      return const ShopInfoView();
                    case 2:
                      return const BrandingView();
                    case 3:
                      return const ComplianceView();
                    case 4:
                      return const KycView();
                    case 5:
                      return const ReviewView();
                    default:
                      return const ShopInfoView();
                  }
                }),
              ),

              // Mobile Docked Bottom Action Bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: AppColors.border, width: 1.w),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Obx(
                  () => Row(
                    children: [
                      if (controller.currentStep.value > 1) ...[
                        AppOutlinedButton(
                          text: 'Back',
                          icon: Icon(Iconsax.arrow_left_2, size: 16.sp),
                          width: 95.w,
                          onPressed: controller.prevStep,
                        ),
                        SizedBox(width: 10.w),
                      ],
                      Expanded(
                        child: AppButton(
                          text: controller.currentStep.value == 5
                              ? 'Submit Application'
                              : 'Continue to Step ${controller.currentStep.value + 1}',
                          isLoading: controller.isSubmitting.value,
                          icon: controller.currentStep.value == 5
                              ? Icon(Iconsax.send_1, size: 18.sp, color: Colors.white)
                              : Icon(Iconsax.arrow_right_3, size: 18.sp, color: Colors.white),
                          onPressed: controller.nextStep,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

