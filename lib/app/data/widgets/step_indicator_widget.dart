import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class StepIndicatorWidget extends StatelessWidget {
  final int currentStep; // 1 to 5
  final Function(int)? onStepTapped;

  StepIndicatorWidget({
    super.key,
    required this.currentStep,
    this.onStepTapped,
  });

  final RxBool _isExpanded = false.obs;

  static const List<Map<String, dynamic>> steps = [
    {
      'title': 'Shop info',
      'shortTitle': 'Shop',
      'subtitle': 'Tell us about your shop',
      'icon': Iconsax.shop,
    },
    {
      'title': 'Branding',
      'shortTitle': 'Branding',
      'subtitle': 'Logo, banner and shop style',
      'icon': Iconsax.brush_1,
    },
    {
      'title': 'Compliance',
      'shortTitle': 'Compliance',
      'subtitle': 'Tax and legal details',
      'icon': Iconsax.document_text,
    },
    {
      'title': 'KYC documents',
      'shortTitle': 'KYC',
      'subtitle': 'Upload documents to verify identity',
      'icon': Iconsax.security_user,
    },
    {
      'title': 'Review',
      'shortTitle': 'Review',
      'subtitle': 'Check everything before you submit',
      'icon': Iconsax.verify,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final curStep = currentStep.clamp(1, StepIndicatorWidget.steps.length);
    final activeStepData = StepIndicatorWidget.steps[curStep - 1];
    final progressPct = (curStep / StepIndicatorWidget.steps.length * 100).toInt();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Step Badge + Active Step Title + % + Expand Icon
          InkWell(
            onTap: () {
              _isExpanded.value = !_isExpanded.value;
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Row(
              children: [
                // Step Pill Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: const Color(0xFFFFD8A8)),
                  ),
                  child: Text(
                    'Step $curStep of ${StepIndicatorWidget.steps.length}',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFF630F),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),

                // Active Step Title
                Expanded(
                  child: Text(
                    activeStepData['title'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Percentage Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '$progressPct%',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),

                // Chevron Toggle
                Obx(
                  () => Icon(
                    _isExpanded.value
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),

          // 5-Segmented Mobile Linear Progress Bar
          Row(
            children: List.generate(StepIndicatorWidget.steps.length, (idx) {
              final stepNum = idx + 1;
              final isDone = stepNum < curStep;
              final isCurrent = stepNum == curStep;

              return Expanded(
                child: Container(
                  height: 4.h,
                  margin: EdgeInsets.only(
                    right: idx < StepIndicatorWidget.steps.length - 1 ? 4.w : 0,
                  ),
                  decoration: BoxDecoration(
                    color: isDone
                        ? const Color(0xFF10B981)
                        : (isCurrent
                            ? const Color(0xFFFF630F)
                            : const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 10.h),

          // Horizontal Quick-Jump Step Track
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(StepIndicatorWidget.steps.length, (idx) {
                final stepNum = idx + 1;
                final isDone = stepNum < curStep;
                final isCurrent = stepNum == curStep;
                final s = StepIndicatorWidget.steps[idx];

                return Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: InkWell(
                    onTap: onStepTapped != null
                        ? () => onStepTapped!(stepNum)
                        : null,
                    borderRadius: BorderRadius.circular(20.r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFFFF630F)
                            : (isDone ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC)),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFFFF630F)
                              : (isDone ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0)),
                          width: isCurrent ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDone ? Icons.check_circle_rounded : (s['icon'] as IconData),
                            size: 13.sp,
                            color: isCurrent
                                ? Colors.white
                                : (isDone ? const Color(0xFF16A34A) : const Color(0xFF64748B)),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            s['shortTitle'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 11.5.sp,
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                              color: isCurrent
                                  ? Colors.white
                                  : (isDone ? const Color(0xFF16A34A) : const Color(0xFF475569)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Collapsible Detailed Vertical View (when expanded)
          Obx(
            () => _isExpanded.value
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      ),
                      ...List.generate(StepIndicatorWidget.steps.length, (idx) {
                        final stepNum = idx + 1;
                        final isDone = stepNum < curStep;
                        final isCurrent = stepNum == curStep;
                        final s = StepIndicatorWidget.steps[idx];

                        return InkWell(
                          onTap: onStepTapped != null
                              ? () {
                                  onStepTapped!(stepNum);
                                  _isExpanded.value = false;
                                }
                              : null,
                          borderRadius: BorderRadius.circular(8.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Node Circle + Vertical connector
                                Column(
                                  children: [
                                    Container(
                                      width: 22.w,
                                      height: 22.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isCurrent
                                            ? const Color(0xFFFF630F)
                                            : (isDone ? const Color(0xFF10B981) : Colors.white),
                                        border: Border.all(
                                          color: isCurrent
                                              ? const Color(0xFFFF630F)
                                              : (isDone ? const Color(0xFF10B981) : const Color(0xFFCBD5E1)),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Center(
                                        child: isDone
                                            ? const Icon(Icons.check, size: 12, color: Colors.white)
                                            : Text(
                                                '$stepNum',
                                                style: GoogleFonts.inter(
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: isCurrent ? Colors.white : const Color(0xFF64748B),
                                                ),
                                              ),
                                      ),
                                    ),
                                    if (stepNum < StepIndicatorWidget.steps.length)
                                      Container(
                                        width: 1.5.w,
                                        height: 18.h,
                                        color: isDone
                                            ? const Color(0xFF10B981).withValues(alpha: 0.4)
                                            : const Color(0xFFE2E8F0),
                                      ),
                                  ],
                                ),
                                SizedBox(width: 10.w),
                                // Title and Subtitle
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s['title'] as String,
                                        style: GoogleFonts.inter(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w700,
                                          color: isCurrent
                                              ? const Color(0xFFFF630F)
                                              : const Color(0xFF0F172A),
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        s['subtitle'] as String,
                                        style: GoogleFonts.inter(
                                          fontSize: 11.sp,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
