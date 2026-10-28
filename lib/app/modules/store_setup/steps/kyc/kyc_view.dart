import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../data/models/kyc_document_model.dart';
import '../../../../data/widgets/step_indicator_widget.dart';
import '../../controllers/store_setup_controller.dart';
import 'kyc_controller.dart';

class KycView extends GetView<KycController> {
  const KycView({super.key});

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

          // 2. KYC Card matching Web Portal Screenshot
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
                Text(
                  'KYC documents',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Upload the required documents from your device.',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 20.h),

                // Documents List
                Obx(
                  () => Column(
                    children: List.generate(controller.documents.length, (index) {
                      final doc = controller.documents[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < controller.documents.length - 1 ? 14.h : 0,
                        ),
                        child: _buildDocumentCard(doc),
                      );
                    }),
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

  Widget _buildDocumentCard(KycDocumentModel doc) {
    final allowedText = doc.allowedExtensions.join(', ');
    final helpSuffix = doc.helpHint != null && doc.helpHint!.isNotEmpty
        ? ' — ${doc.helpHint!}'
        : '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document Title
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                doc.label,
                style: GoogleFonts.inter(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              if (doc.required)
                Text(
                  ' *',
                  style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF630F),
                  ),
                )
              else
                Text(
                  ' (Optional)',
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
            ],
          ),
          SizedBox(height: 4.h),

          // Subtitle / Specs
          Text(
            'Allowed: $allowedText · ${doc.minKb}–${doc.maxKb} KB$helpSuffix',
            style: GoogleFonts.inter(
              fontSize: 11.5.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 12.h),

          // Action State
          if (doc.isUploading)
            Row(
              children: [
                SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFFF630F),
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  'Uploading document…',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            )
          else if (doc.isUploaded)
            Row(
              children: [
                Icon(
                  Iconsax.document_text,
                  color: const Color(0xFF16A34A),
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    doc.fileName ?? 'Uploaded_document.pdf',
                    style: GoogleFonts.inter(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),

                // Change file button
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                  ),
                  onPressed: () => controller.uploadDocument(doc.id),
                  child: Text(
                    'Change file',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                SizedBox(width: 6.w),

                // Remove button
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                  ),
                  onPressed: () => controller.removeDocument(doc.id),
                  child: Text(
                    'Remove',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
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
                  onPressed: () => controller.uploadDocument(doc.id),
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
        ],
      ),
    );
  }
}
