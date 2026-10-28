import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../data/widgets/step_indicator_widget.dart';
import '../../controllers/store_setup_controller.dart';
import 'branding_controller.dart';

class BrandingView extends GetView<BrandingController> {
  const BrandingView({super.key});

  @override
  Widget build(BuildContext context) {
    final setupController = Get.find<StoreSetupController>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Mobile Step Indicator
          Obx(
            () => StepIndicatorWidget(
              currentStep: setupController.currentStep.value,
              onStepTapped: (step) => setupController.goToStep(step),
            ),
          ),
          SizedBox(height: 16.h),

          // 2. Branding Card matching Web Portal Screenshot
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Branding',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'How your shop looks to customers. Logo and banner are required.',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 20.h),

                // Logo Section
                _buildFieldLabel(label: 'Logo', isRequired: true),
                SizedBox(height: 8.h),
                _buildLogoBox(),
                SizedBox(height: 20.h),

                // Banner Section
                _buildFieldLabel(label: 'Banner', isRequired: true),
                SizedBox(height: 8.h),
                _buildBannerBox(),
                SizedBox(height: 20.h),

                // Shop policies (Optional)
                _buildFieldLabel(label: 'Shop policies', isOptional: true),
                SizedBox(height: 8.h),
                TextField(
                  controller: controller.policiesController,
                  maxLines: 4,
                  minLines: 3,
                  style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    color: const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: '',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(14.w),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Color(0xFFFF630F), width: 1.5),
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Return, shipping and warranty policies shown to customers.',
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildFieldLabel({
    required String label,
    bool isRequired = false,
    bool isOptional = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: GoogleFonts.inter(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFF630F),
            ),
          ),
        if (isOptional)
          Text(
            ' (Optional)',
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              color: const Color(0xFF64748B),
            ),
          ),
      ],
    );
  }

  Widget _buildLogoBox() {
    return Obx(() {
      final hasLocal = controller.logoLocalPath.value != null &&
          controller.logoLocalPath.value!.isNotEmpty;
      final hasRemote = controller.logoUrl.value != null &&
          controller.logoUrl.value!.isNotEmpty;
      final isUploading = controller.isLogoUploading.value;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: isUploading
            ? Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFF630F),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Uploading logo...',
                        style: GoogleFonts.inter(
                          fontSize: 12.5.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : (hasLocal || hasRemote)
                ? Row(
                    children: [
                      // Thumbnail preview
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6.r),
                        child: Container(
                          width: 48.w,
                          height: 48.w,
                          color: const Color(0xFFF1F5F9),
                          child: hasLocal
                              ? Image.file(
                                  File(controller.logoLocalPath.value!),
                                  width: 48.w,
                                  height: 48.w,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Icon(
                                    Iconsax.image,
                                    color: const Color(0xFF94A3B8),
                                    size: 22.sp,
                                  ),
                                )
                              : Image.network(
                                  controller.logoUrl.value!,
                                  width: 48.w,
                                  height: 48.w,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Icon(
                                    Iconsax.image,
                                    color: const Color(0xFF94A3B8),
                                    size: 22.sp,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(width: 14.w),

                      // Change file button
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                        ),
                        onPressed: controller.pickLogo,
                        child: Text(
                          'Change file',
                          style: GoogleFonts.inter(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // Remove button
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                        ),
                        onPressed: controller.removeLogo,
                        child: Text(
                          'Remove',
                          style: GoogleFonts.inter(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                        ),
                        onPressed: controller.pickLogo,
                        child: Text(
                          'Choose file',
                          style: GoogleFonts.inter(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'No file chosen',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
      );
    });
  }

  Widget _buildBannerBox() {
    return Obx(() {
      final hasLocal = controller.bannerLocalPath.value != null &&
          controller.bannerLocalPath.value!.isNotEmpty;
      final hasRemote = controller.bannerUrl.value != null &&
          controller.bannerUrl.value!.isNotEmpty;
      final isUploading = controller.isBannerUploading.value;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: isUploading
            ? Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFF630F),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Uploading banner...',
                        style: GoogleFonts.inter(
                          fontSize: 12.5.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : (hasLocal || hasRemote)
                ? Row(
                    children: [
                      // Thumbnail preview
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6.r),
                        child: Container(
                          width: 48.w,
                          height: 48.w,
                          color: const Color(0xFFF1F5F9),
                          child: hasLocal
                              ? Image.file(
                                  File(controller.bannerLocalPath.value!),
                                  width: 48.w,
                                  height: 48.w,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Icon(
                                    Iconsax.gallery,
                                    color: const Color(0xFF94A3B8),
                                    size: 22.sp,
                                  ),
                                )
                              : Image.network(
                                  controller.bannerUrl.value!,
                                  width: 48.w,
                                  height: 48.w,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Icon(
                                    Iconsax.gallery,
                                    color: const Color(0xFF94A3B8),
                                    size: 22.sp,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(width: 14.w),

                      // Change file button
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                        ),
                        onPressed: controller.pickBanner,
                        child: Text(
                          'Change file',
                          style: GoogleFonts.inter(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // Remove button
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                        ),
                        onPressed: controller.removeBanner,
                        child: Text(
                          'Remove',
                          style: GoogleFonts.inter(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                        ),
                        onPressed: controller.pickBanner,
                        child: Text(
                          'Choose file',
                          style: GoogleFonts.inter(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'No file chosen',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
      );
    });
  }
}
