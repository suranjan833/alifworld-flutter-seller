import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/theme/app_colors.dart';
import '../../../../data/widgets/shimmer_widget.dart';

class RejectOrderDialogController extends GetxController {
  final TextEditingController reasonController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  final List<String> quickReasons = const [
    'Out of stock',
    'Pricing error',
    'Customer requested cancellation',
    'Delivery area unserviceable',
  ];

  final Rxn<String> selectedQuickReason = Rxn<String>();
  final RxBool isSubmitting = false.obs;
  final RxBool hasReason = false.obs;

  @override
  void onInit() {
    super.onInit();
    reasonController.addListener(() {
      hasReason.value = reasonController.text.trim().isNotEmpty;
    });
  }

  @override
  void onClose() {
    reasonController.dispose();
    focusNode.dispose();
    super.onClose();
  }

  void selectQuickReason(String reason) {
    if (selectedQuickReason.value == reason) {
      selectedQuickReason.value = null;
      reasonController.clear();
    } else {
      selectedQuickReason.value = reason;
      reasonController.text = reason;
    }
  }
}

class RejectOrderDialog extends GetView<RejectOrderDialogController> {
  final Function(String reason) onConfirm;

  const RejectOrderDialog({super.key, required this.onConfirm});

  static Future<void> show(BuildContext context, {required Function(String reason) onConfirm}) {
    Get.delete<RejectOrderDialogController>();
    Get.put(RejectOrderDialogController());
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => RejectOrderDialog(onConfirm: onConfirm),
    );
  }

  void _submit(BuildContext context, RejectOrderDialogController dialogCtrl) {
    final text = dialogCtrl.reasonController.text.trim();
    if (text.isEmpty) return;

    dialogCtrl.isSubmitting.value = true;
    Navigator.of(context).pop();
    onConfirm(text);
  }

  @override
  Widget build(BuildContext context) {
    final dialogCtrl = Get.isRegistered<RejectOrderDialogController>()
        ? controller
        : Get.put(RejectOrderDialogController());

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      elevation: 6,
      backgroundColor: const Color(0xFFF5EBE6),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Container(
        constraints: BoxConstraints(maxWidth: 420.w),
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF7ECE7),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Reject Order',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 12.h),

              // Description
              Text(
                'Please provide a reason for rejecting this order:',
                style: GoogleFonts.inter(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF475569),
                  height: 1.35,
                ),
              ),
              SizedBox(height: 14.h),

              // Input Box
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: const Color(0xFF64748B).withValues(alpha: 0.4),
                    width: 1.0,
                  ),
                ),
                child: TextField(
                  controller: dialogCtrl.reasonController,
                  focusNode: dialogCtrl.focusNode,
                  maxLines: 4,
                  minLines: 3,
                  style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    color: const Color(0xFF1E293B),
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. Out of stock, pricing error...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12.w),
                  ),
                  onChanged: (val) {
                    if (dialogCtrl.selectedQuickReason.value != null &&
                        val != dialogCtrl.selectedQuickReason.value) {
                      dialogCtrl.selectedQuickReason.value = null;
                    }
                  },
                ),
              ),
              SizedBox(height: 10.h),

              // Quick preset chips for convenience
              Obx(
                () => Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: dialogCtrl.quickReasons.map((r) {
                    final isSelected = dialogCtrl.selectedQuickReason.value == r;
                    return InkWell(
                      onTap: () => dialogCtrl.selectQuickReason(r),
                      borderRadius: BorderRadius.circular(6.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                              : Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFEF4444)
                                : const Color(0xFFCBD5E1),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          r,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20.h),

              // Action buttons row: Cancel & Reject Order
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF5722),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Obx(() {
                    final hasReason = dialogCtrl.hasReason.value;
                    final isSubmitting = dialogCtrl.isSubmitting.value;

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: const Color(0xFFEF4444).withValues(alpha: 0.35),
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 11.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: hasReason && !isSubmitting
                          ? () => _submit(context, dialogCtrl)
                          : null,
                      child: isSubmitting
                          ? const ShimmerBox(width: 50, height: 16, borderRadius: 4)
                          : Text(
                              'Reject Order',
                              style: GoogleFonts.inter(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
