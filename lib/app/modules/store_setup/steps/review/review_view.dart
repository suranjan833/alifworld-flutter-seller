import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/theme/app_colors.dart';
import '../../../../data/widgets/step_indicator_widget.dart';
import '../../controllers/store_setup_controller.dart';
import 'review_controller.dart';

class ReviewView extends GetView<ReviewController> {
  const ReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final setupController = Get.find<StoreSetupController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 28.h,
            ),
            child: IntrinsicHeight(
              child: Obx(() {
                final shop = controller.shopController;
                final brand = controller.brandingController;
                final compliance = controller.complianceController;
                final kyc = controller.kycController;

                // Shop info values
                final shopName = shop.nameController.text.trim();
                final slug = shop.slugController.text.trim();
                final desc = shop.descController.text.trim();

                // Branding values
                final hasLogo = brand.logoUrl.value != null || brand.logoFileName.value != null;
                final hasBanner = brand.bannerUrl.value != null || brand.bannerFileName.value != null;
                final policies = brand.policiesController.text.trim();

                // Compliance dynamic fields
                final complianceFields = compliance.dynamicFields;

                // KYC documents
                final kycDocs = kyc.documents;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Mobile Stepper Indicator
                    StepIndicatorWidget(
                      currentStep: setupController.currentStep.value,
                      onStepTapped: (step) => setupController.goToStep(step),
                    ),
                    SizedBox(height: 16.h),

                    // 2. Review and Submit Card
                    Expanded(
                      child: Container(
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
                              'Review and submit',
                              style: GoogleFonts.inter(
                                fontSize: 16.5.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Check everything, then submit your shop for review.',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

                            // 1. Shop Info fields
                            _buildItemRow('Shop name', shopName.isEmpty ? 'Not set' : shopName),
                            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

                            _buildItemRow('Slug', slug.isEmpty ? 'Not set' : slug),
                            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

                            _buildItemRow('Description', desc.isEmpty ? 'Not set' : desc),
                            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

                            // 2. Branding fields
                            _buildItemRow('Logo', hasLogo ? 'Uploaded' : 'Not set', isStatus: true, isSuccess: hasLogo),
                            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

                            _buildItemRow('Banner', hasBanner ? 'Uploaded' : 'Not set', isStatus: true, isSuccess: hasBanner),
                            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

                            _buildItemRow('Shop policies', policies.isEmpty ? 'Not set' : policies),
                            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

                            // 3. Compliance fields
                            if (complianceFields.isNotEmpty) ...[
                              for (final field in complianceFields) ...[
                                _buildItemRow(
                                  field.label,
                                  field.controller.text.trim().isEmpty ? 'Not set' : field.controller.text.trim(),
                                ),
                                const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                              ],
                            ] else ...[
                              _buildItemRow('Trade License Number', 'Not set'),
                              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                              _buildItemRow('NBR BIN', 'Not set'),
                              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                              _buildItemRow('e-TIN', 'Not set'),
                              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                            ],

                            // 4. KYC Document fields
                            if (kycDocs.isNotEmpty) ...[
                              for (final doc in kycDocs) ...[
                                _buildItemRow(
                                  doc.label,
                                  doc.isUploaded ? 'Uploaded' : 'Not set',
                                  isStatus: true,
                                  isSuccess: doc.isUploaded,
                                ),
                                const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                              ],
                            ] else ...[
                              _buildItemRow('Trade License Copy', 'Not set', isStatus: true, isSuccess: false),
                              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                              _buildItemRow('NID Front/Back', 'Not set', isStatus: true, isSuccess: false),
                              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                              _buildItemRow('BIN Certificate', 'Not set', isStatus: true, isSuccess: false),
                              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                              _buildItemRow('Bank Cheque Leaf', 'Not set', isStatus: true, isSuccess: false),
                              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                              _buildItemRow('e-TIN Certificate', 'Not set', isStatus: true, isSuccess: false),
                              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                            ],

                            SizedBox(height: 18.h),

                            // Terms Agreement Box
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 22.w,
                                    height: 22.w,
                                    child: Checkbox(
                                      value: controller.agreedToTerms.value,
                                      onChanged: controller.toggleTerms,
                                      activeColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4.r),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Text(
                                      'I certify that all provided information is accurate and authentic. I agree to abide by the Alifworld Merchant Agreement and Terms.',
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5.sp,
                                        color: const Color(0xFF64748B),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemRow(
    String label,
    String value, {
    bool isStatus = false,
    bool isSuccess = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: const Color(0xFF475569),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 6,
            child: Align(
              alignment: Alignment.centerRight,
              child: isStatus
                  ? (isSuccess
                      ? Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 12.sp,
                                color: const Color(0xFF059669),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Uploaded',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            'Not set',
                            style: GoogleFonts.inter(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ))
                  : (value == 'Not set'
                      ? Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            'Not set',
                            style: GoogleFonts.inter(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        )
                      : Text(
                          value,
                          textAlign: TextAlign.end,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        )),
            ),
          ),
        ],
      ),
    );
  }
}
