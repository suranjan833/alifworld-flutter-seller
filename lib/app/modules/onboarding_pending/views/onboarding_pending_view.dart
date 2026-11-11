import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../data/services/env_config.dart';
import '../../../data/theme/app_colors.dart';
import '../../../data/widgets/common_widgets.dart';
import '../../../data/widgets/exit_dialog.dart';
import '../controllers/onboarding_pending_controller.dart';

class OnboardingPendingView extends GetView<OnboardingPendingController> {
  const OnboardingPendingView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await handleAppExit(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 26.h,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text(
                'SELLER',
                style: GoogleFonts.inter(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Pulsing Verification Animation
              const _PulsingRadarWidget(),
              SizedBox(height: 24.h),

              // Eyebrow
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.clock, size: 14.sp, color: AppColors.warning),
                    SizedBox(width: 6.w),
                    Text(
                      'APPLICATION UNDER REVIEW',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.warning,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),

              // Title
              Obx(
                () => Text(
                  'Your shop "${controller.shopName.value}" is pending approval',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              // Subtitle
              Text(
                'Our compliance team is thoroughly reviewing your documents and store information. Approvals typically take 24–48 business hours.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 28.h),

              // Pending Steps Timeline Card
              Container(
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What happens next?',
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildStepRow(
                      number: 1,
                      title: 'Legal & KYC Verification',
                      desc: 'Our compliance officers verify your National ID and business certificates.',
                      status: 'In Progress',
                      isCurrent: true,
                    ),
                    _buildStepRow(
                      number: 2,
                      title: 'Merchant Account Setup',
                      desc: 'We configure your payout cycle, shipping hubs, and product inventory limits.',
                      status: 'Pending',
                      isCurrent: false,
                    ),
                    _buildStepRow(
                      number: 3,
                      title: 'Go Live on Alifworld',
                      desc: 'Your shop goes live to millions of active buyers across Bangladesh.',
                      status: 'Final Step',
                      isCurrent: false,
                      isLast: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Action Buttons
              Obx(
                () => AppButton(
                  text: 'Check Approval Status',
                  isLoading: controller.isCheckingStatus.value,
                  icon: const Icon(Iconsax.refresh, color: Colors.white),
                  onPressed: controller.refreshStatus,
                ),
              ),
              SizedBox(height: 10.h),
              AppOutlinedButton(
                text: 'Contact Seller Support',
                icon: const Icon(Iconsax.message_question),
                width: double.infinity,
                onPressed: () {
                  Get.snackbar(
                    'Support Hotline',
                    'Alifworld Seller Support: ${EnvConfig.supportEmail} | ${EnvConfig.supportPhone}',
                    snackPosition: SnackPosition.TOP,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildStepRow({
    required int number,
    required String title,
    required String desc,
    required String status,
    required bool isCurrent,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: isCurrent ? AppColors.primary : AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrent ? AppColors.primary : AppColors.borderStrong,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: isCurrent ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 38.h,
                color: AppColors.border,
              ),
          ],
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      status,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: isCurrent ? AppColors.primary : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PulsingRadarWidget extends GetView<OnboardingPendingController> {
  const _PulsingRadarWidget();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.radarAnimController,
      builder: (context, child) {
        return SizedBox(
          width: 140.w,
          height: 140.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ripple
              Transform.scale(
                scale: 1.0 + (controller.radarAnimController.value * 0.4),
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(
                        alpha: (1 - controller.radarAnimController.value) * 0.2),
                  ),
                ),
              ),
              // Inner circle
              Container(
                width: 90.w,
                height: 90.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
              // Center icon
              Container(
                width: 64.w,
                height: 64.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: Icon(
                  Iconsax.shield_tick,
                  color: Colors.white,
                  size: 32.sp,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
