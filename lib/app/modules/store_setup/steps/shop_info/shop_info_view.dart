import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/widgets/step_indicator_widget.dart';
import '../../controllers/store_setup_controller.dart';
import 'shop_info_controller.dart';

class ShopInfoView extends GetView<ShopInfoController> {
  const ShopInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    final setupController = Get.find<StoreSetupController>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Vertical Stepper & Progress Bar matching official web portal
          Obx(
            () => StepIndicatorWidget(
              currentStep: setupController.currentStep.value,
              onStepTapped: (step) => setupController.goToStep(step),
            ),
          ),
          SizedBox(height: 16.h),

          // 2. Shop info Card matching screenshot exactly
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
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card Header
                Text(
                  'Shop info',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'The basics of your shop.',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 20.h),

                // Shop name *
                _buildFieldLabel('Shop name', isRequired: true),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: controller.nameController,
                  style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: _inputDecoration(
                    hint: 'e.g. Test Shop',
                  ),
                ),
                SizedBox(height: 16.h),

                // Slug *
                _buildFieldLabel('Slug', isRequired: true),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: controller.slugController,
                  readOnly: true,
                  style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: _inputDecoration(
                    fillColor: const Color(0xFFF8FAFC),
                    hint: 'test-shop',
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  'Automatically generated from your shop name. Used in your public shop URL.',
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    color: const Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 16.h),

                // Description (Optional)
                _buildFieldLabel('Description (Optional)', isRequired: false),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: controller.descController,
                  maxLines: 4,
                  minLines: 3,
                  style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    color: const Color(0xFF0F172A),
                  ),
                  decoration: _inputDecoration(
                    hint: 'Brief description about your shop...',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          if (isRequired)
            TextSpan(
              text: ' *',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFF5722),
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, Color? fillColor}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 13.sp,
        color: const Color(0xFF94A3B8),
      ),
      filled: fillColor != null,
      fillColor: fillColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: Color(0xFFFF5722), width: 1.5),
      ),
    );
  }
}
