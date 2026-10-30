import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../data/theme/app_colors.dart';
import '../../../../data/widgets/shimmer_widget.dart';

class DeliveryOtpDialogController extends GetxController {
  static const int otpLength = 6;
  final List<TextEditingController> controllers =
      List.generate(otpLength, (_) => TextEditingController());
  final List<FocusNode> focusNodes =
      List.generate(otpLength, (_) => FocusNode());

  final RxString currentOtp = ''.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusNodes.isNotEmpty) {
        focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void onClose() {
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.onClose();
  }

  bool get isComplete => currentOtp.value.length == otpLength;

  void updateOtpString() {
    currentOtp.value = controllers.map((c) => c.text).join().trim();
  }

  void onChanged(String value, int index) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < otpLength; i++) {
        if (i < digits.length) {
          controllers[i].text = digits[i];
        }
      }
      final nextIndex = digits.length < otpLength ? digits.length : otpLength - 1;
      focusNodes[nextIndex].requestFocus();
      updateOtpString();
      return;
    }

    if (value.isNotEmpty) {
      if (index < otpLength - 1) {
        focusNodes[index + 1].requestFocus();
      } else {
        focusNodes[index].unfocus();
      }
    }
    updateOtpString();
  }

  void onBackspace(int index) {
    if (controllers[index].text.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
      controllers[index - 1].clear();
      updateOtpString();
    }
  }
}

class DeliveryOtpDialog extends GetView<DeliveryOtpDialogController> {
  final Function(String otp) onConfirm;

  const DeliveryOtpDialog({super.key, required this.onConfirm});

  static Future<void> show(BuildContext context, {required Function(String otp) onConfirm}) {
    Get.delete<DeliveryOtpDialogController>();
    Get.put(DeliveryOtpDialogController());
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DeliveryOtpDialog(onConfirm: onConfirm),
    );
  }

  void _submit(BuildContext context, DeliveryOtpDialogController dialogCtrl) {
    final otp = dialogCtrl.currentOtp.value;
    if (otp.length < 4) return;
    dialogCtrl.isSubmitting.value = true;
    Navigator.of(context).pop();
    onConfirm(otp);
  }

  @override
  Widget build(BuildContext context) {
    final dialogCtrl = Get.isRegistered<DeliveryOtpDialogController>()
        ? controller
        : Get.put(DeliveryOtpDialogController());

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h + keyboardHeight),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle pill
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(height: 18.h),

            // Top Badge Icon
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Iconsax.shield_tick, color: Colors.white, size: 28),
              ),
            ),
            SizedBox(height: 14.h),

            // Title & Subtitle
            Text(
              'Delivery Verification',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Ask the customer for the 6-digit delivery OTP shown on their order screen to confirm handover.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.5.sp,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),

            // 6-Digit OTP Box Grid
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(DeliveryOtpDialogController.otpLength, (index) {
                  final isFilled = dialogCtrl.controllers[index].text.isNotEmpty;
                  final isFocused = dialogCtrl.focusNodes[index].hasFocus;

                  return SizedBox(
                    width: 46.w,
                    height: 54.h,
                    child: KeyboardListener(
                      focusNode: FocusNode(),
                      onKeyEvent: (event) {
                        if (event is KeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.backspace) {
                          dialogCtrl.onBackspace(index);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: isFocused ? Colors.white : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isFocused
                                ? const Color(0xFF10B981)
                                : isFilled
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFE2E8F0),
                            width: isFocused ? 2 : 1.2,
                          ),
                          boxShadow: isFocused
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.18),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: TextField(
                            controller: dialogCtrl.controllers[index],
                            focusNode: dialogCtrl.focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: GoogleFonts.inter(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                            decoration: const InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (val) => dialogCtrl.onChanged(val, index),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 22.h),

            // Customer hint banner
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 15, color: Color(0xFF64748B)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Customer receives OTP on their Alifworld order tracking page.',
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Confirm Button
            Obx(() {
              final isComplete = dialogCtrl.isComplete;
              final isSubmitting = dialogCtrl.isSubmitting.value;

              return SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isComplete
                        ? const Color(0xFF10B981)
                        : const Color(0xFF10B981).withValues(alpha: 0.4),
                    elevation: isComplete ? 3 : 0,
                    shadowColor: const Color(0xFF10B981).withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: isComplete && !isSubmitting
                      ? () => _submit(context, dialogCtrl)
                      : null,
                  child: isSubmitting
                      ? const ShimmerBox(width: 60, height: 18, borderRadius: 4)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                            SizedBox(width: 8.w),
                            Text(
                              'Confirm Delivery',
                              style: GoogleFonts.inter(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              );
            }),
            SizedBox(height: 10.h),

            // Cancel button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
