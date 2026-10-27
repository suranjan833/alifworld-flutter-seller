import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../data/theme/app_colors.dart';
import '../../../data/widgets/common_widgets.dart';
import '../../../data/widgets/exit_dialog.dart';
import '../controllers/seller_gate_controller.dart';

class SellerGateView extends GetView<SellerGateController> {
  const SellerGateView({super.key});

  void _handleBack(BuildContext context) async {
    if (!controller.isLoginMode.value) {
      if (controller.gateStep.value > 1) {
        controller.gateStep.value--;
      } else {
        controller.switchToLogin();
      }
    } else {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        await handleAppExit(context);
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
        appBar: _buildMobileAppBar(context),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mobile Native Hero Banner with Auto-scrolling Marquee
                _buildMobileHero(context),
                SizedBox(height: 16.h),

                // Main Auth Card (Login as default, or Sign Up)
                Obx(() => controller.isLoginMode.value
                    ? _buildLoginCard(context)
                    : _buildSignUpCard(context)),
                SizedBox(height: 16.h),

                // Quick Benefits / Perks Bar
                _buildPerksQuickBar(context),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
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
            height: 26.h,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Iconsax.shop, color: AppColors.primary, size: 18.sp),
            ),
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
      actions: [
        Obx(
          () => TextButton(
            onPressed: controller.toggleAuthMode,
            child: Text(
              controller.isLoginMode.value ? 'Sign Up' : 'Log In',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () => _showBenefitsBottomSheet(context),
          icon: Icon(Iconsax.info_circle, size: 20.sp, color: AppColors.textSecondary),
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  Widget _buildMobileHero(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF630F), Color(0xFFFF8E4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.verify5, size: 13.sp, color: Colors.white),
                    SizedBox(width: 4.w),
                    Text(
                      'OFFICIAL MERCHANT GATEWAY',
                      style: GoogleFonts.inter(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Launch your digital store\nacross Bangladesh',
            style: GoogleFonts.inter(
              fontSize: 19.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.25,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Lowest commissions • Next-day automated payouts • 64 districts courier pickup.',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.35,
            ),
          ),
          SizedBox(height: 14.h),

          // Continuous Auto-scrolling Marquee Ticker
          AutoMarqueeWidget(
            speed: 36.0,
            spacing: 8.w,
            children: [
              _buildHeroMiniBadge(Iconsax.empty_wallet_tick, '0% First 30 Days'),
              _buildHeroMiniBadge(Iconsax.truck_fast, '64 Districts Pickup'),
              _buildHeroMiniBadge(Iconsax.card_tick, 'Automated Bank Payout'),
              _buildHeroMiniBadge(Iconsax.headphone, '24/7 Dedicated Support'),
              _buildHeroMiniBadge(Iconsax.tag_2, 'Zero Catalog Listing Fee'),
              _buildHeroMiniBadge(Iconsax.flash_1, 'Free Promotional Boost'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMiniBadge(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: Colors.white),
          SizedBox(width: 5.w),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. Login Card (Now the Primary View) ---
  Widget _buildLoginCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seller Log In',
                style: GoogleFonts.inter(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'PARTNER PORTAL',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Enter your registered phone or email to access your seller account.',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),

          // Login Method Selector (Password vs Dev OTP)
          Obx(
            () => Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => controller.isOtpLogin.value = false,
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 7.h),
                        decoration: BoxDecoration(
                          color: !controller.isOtpLogin.value ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: !controller.isOtpLogin.value
                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Password Login',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: !controller.isOtpLogin.value ? FontWeight.w700 : FontWeight.w500,
                              color: !controller.isOtpLogin.value ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => controller.isOtpLogin.value = true,
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 7.h),
                        decoration: BoxDecoration(
                          color: controller.isOtpLogin.value ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: controller.isOtpLogin.value
                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Number OTP Login',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: controller.isOtpLogin.value ? FontWeight.w700 : FontWeight.w500,
                              color: controller.isOtpLogin.value ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // Login Form: OTP or Password
          Obx(
            () => controller.isOtpLogin.value
                ? _buildPhoneStep()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: 'Phone or Email Address',
                        hint: '01XXXXXXXXX or email@company.com',
                        controller: controller.loginAccountController,
                        keyboardType: TextInputType.emailAddress,
                        isRequired: true,
                        prefixIcon: Icon(Iconsax.user, color: AppColors.primary, size: 20.sp),
                      ),
                      SizedBox(height: 12.h),

                      Obx(
                        () => AppTextField(
                          label: 'Password',
                          hint: 'Enter your account password',
                          controller: controller.loginPasswordController,
                          obscureText: !controller.isLoginPasswordVisible.value,
                          isRequired: true,
                          prefixIcon: Icon(Iconsax.lock, color: AppColors.textMuted, size: 20.sp),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isLoginPasswordVisible.value ? Iconsax.eye : Iconsax.eye_slash,
                              color: AppColors.textMuted,
                              size: 18.sp,
                            ),
                            onPressed: controller.toggleLoginPasswordVisibility,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Remember Me & Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(
                            () => InkWell(
                              onTap: () => controller.rememberMe.toggle(),
                              borderRadius: BorderRadius.circular(4.r),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 22.w,
                                    height: 22.w,
                                    child: Checkbox(
                                      value: controller.rememberMe.value,
                                      onChanged: (v) => controller.rememberMe.value = v ?? true,
                                      activeColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4.r),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Remember me',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.snackbar(
                                'Password Recovery',
                                'A password reset link will be sent to your registered contact.',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: AppColors.primary,
                                colorText: Colors.white,
                              );
                            },
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),

                      AppButton(
                        text: 'Log In to Seller Center',
                        isLoading: controller.isLoading.value,
                        icon: const Icon(Iconsax.login_1, color: Colors.white),
                        onPressed: controller.login,
                      ),
                    ],
                  ),
          ),
          SizedBox(height: 14.h),

          // Switcher to Sign Up
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'New to Alif Seller? ',
                style: GoogleFonts.inter(
                  fontSize: 12.5.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              InkWell(
                onTap: controller.switchToSignUp,
                child: Text(
                  'Sign Up / Register',
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 2. Sign Up Card (Previously the Main Form) ---
  Widget _buildSignUpCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seller Sign Up',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Step ${controller.gateStep.value} of 3',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Segmented Progress Bar with Icons
          Obx(
            () => Row(
              children: [
                _buildSegmentTab(
                  index: 1,
                  title: 'Mobile',
                  icon: Iconsax.call,
                  currentStep: controller.gateStep.value,
                ),
                SizedBox(width: 6.w),
                _buildSegmentTab(
                  index: 2,
                  title: 'Email',
                  icon: Iconsax.sms,
                  currentStep: controller.gateStep.value,
                ),
                SizedBox(width: 6.w),
                _buildSegmentTab(
                  index: 3,
                  title: 'Account',
                  icon: Iconsax.user,
                  currentStep: controller.gateStep.value,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          const Divider(height: 1, color: AppColors.divider),
          SizedBox(height: 16.h),

          // Step Content
          Obx(() {
            if (controller.gateStep.value == 1) {
              return _buildPhoneStep();
            } else if (controller.gateStep.value == 2) {
              return _buildEmailStep();
            } else {
              return _buildAccountStep();
            }
          }),
          SizedBox(height: 14.h),

          // Switcher back to Login
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: GoogleFonts.inter(
                  fontSize: 12.5.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              InkWell(
                onTap: controller.switchToLogin,
                child: Text(
                  'Log In',
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentTab({
    required int index,
    required String title,
    required IconData icon,
    required int currentStep,
  }) {
    final isActive = currentStep == index;
    final isDone = currentStep > index;

    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryLight
              : isDone
                  ? AppColors.successLight
                  : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.5)
                : isDone
                    ? AppColors.success.withValues(alpha: 0.4)
                    : AppColors.border,
            width: 1.w,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isDone ? Iconsax.tick_circle : icon,
              size: 15.sp,
              color: isActive
                  ? AppColors.primary
                  : isDone
                      ? AppColors.success
                      : AppColors.textMuted,
            ),
            SizedBox(height: 3.h),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 10.5.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? AppColors.primary
                    : isDone
                        ? AppColors.success
                        : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verify your Bangladesh Mobile Number',
          style: GoogleFonts.inter(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'We will send a 6-digit one-time code to secure your seller portal.',
          style: GoogleFonts.inter(
            fontSize: 11.5.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 12.h),

        Obx(
          () => AppTextField(
            label: 'Mobile Phone Number',
            hint: '01XXXXXXXXX or 1XXXXXXXXX',
            controller: controller.phoneController,
            keyboardType: TextInputType.phone,
            isRequired: true,
            maxLength: 11,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            helperText: controller.isAutoResendingPhoneOtp.value
                ? 'Resending OTP to new number...'
                : (controller.isPhoneOtpSent.value
                    ? 'Editing number will automatically resend OTP'
                    : 'Minimum 10 digits, maximum 11 digits'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Phone number is required';
              }
              final digits = value.replaceAll(RegExp(r'\D'), '');
              if (digits.length < 10) {
                return 'Phone number must be at least 10 digits';
              }
              if (digits.length > 11) {
                return 'Phone number cannot exceed 11 digits';
              }
              return null;
            },
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 12.w, right: 6.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+880',
                    style: GoogleFonts.inter(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Container(width: 1.w, height: 16.h, color: AppColors.borderStrong),
                ],
              ),
            ),
            suffixIcon: controller.isAutoResendingPhoneOtp.value
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: Center(
                      child: SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                : (controller.isPhoneOtpSent.value
                    ? Tooltip(
                        message: 'Phone number verified / active for OTP',
                        child: Icon(Iconsax.edit_2, color: AppColors.primary, size: 18.sp),
                      )
                    : null),
          ),
        ),
        SizedBox(height: 12.h),

        Obx(
          () => !controller.isPhoneOtpSent.value
              ? AppButton(
                  text: 'Send Verification Code',
                  isLoading: controller.isLoading.value,
                  icon: const Icon(Iconsax.sms, color: Colors.white),
                  onPressed: controller.requestPhoneOtp,
                )
              : Column(
                  children: [
                    AppTextField(
                      label: 'Enter 6-Digit SMS Code',
                      hint: '123456',
                      controller: controller.phoneOtpController,
                      keyboardType: TextInputType.number,
                      isRequired: true,
                      prefixIcon: Icon(Iconsax.key, color: AppColors.primary, size: 20.sp),
                      suffixIcon: controller.phoneResendCountdown.value > 0
                          ? Padding(
                              padding: EdgeInsets.all(12.w),
                              child: Text(
                                '${controller.phoneResendCountdown.value}s',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : TextButton(
                              onPressed: controller.requestPhoneOtp,
                              child: Text(
                                'Resend',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                    ),
                    SizedBox(height: 12.h),
                    AppButton(
                      text: 'Verify Phone Number',
                      isLoading: controller.isLoading.value,
                      icon: const Icon(Iconsax.verify, color: Colors.white),
                      onPressed: controller.verifyPhoneOtp,
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verify Business Email',
          style: GoogleFonts.inter(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Your statements, order alerts, and official payouts will be sent here.',
          style: GoogleFonts.inter(
            fontSize: 11.5.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 12.h),

        AppTextField(
          label: 'Business Email Address',
          hint: 'merchant@company.com',
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          isRequired: true,
          prefixIcon: Icon(Iconsax.sms, color: AppColors.primary, size: 20.sp),
        ),
        SizedBox(height: 12.h),

        Obx(
          () => !controller.isEmailOtpSent.value
              ? AppButton(
                  text: 'Send Email Code',
                  isLoading: controller.isLoading.value,
                  icon: const Icon(Iconsax.send_2, color: Colors.white),
                  onPressed: controller.requestEmailOtp,
                )
              : Column(
                  children: [
                    AppTextField(
                      label: 'Enter 6-Digit Email Code',
                      hint: '123456',
                      controller: controller.emailOtpController,
                      keyboardType: TextInputType.number,
                      isRequired: true,
                      prefixIcon: Icon(Iconsax.key, color: AppColors.primary, size: 20.sp),
                      suffixIcon: controller.emailResendCountdown.value > 0
                          ? Padding(
                              padding: EdgeInsets.all(12.w),
                              child: Text(
                                '${controller.emailResendCountdown.value}s',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : TextButton(
                              onPressed: controller.requestEmailOtp,
                              child: Text(
                                'Resend',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                    ),
                    SizedBox(height: 12.h),
                    AppButton(
                      text: 'Verify Email & Continue',
                      isLoading: controller.isLoading.value,
                      icon: const Icon(Iconsax.verify, color: Colors.white),
                      onPressed: controller.verifyEmailOtp,
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildAccountStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal & Login Details',
          style: GoogleFonts.inter(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Set up your merchant login credentials to access your store manager.',
          style: GoogleFonts.inter(
            fontSize: 11.5.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 12.h),

        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'First Name',
                hint: 'Rahim',
                controller: controller.firstNameController,
                isRequired: true,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: AppTextField(
                label: 'Last Name',
                hint: 'Uddin',
                controller: controller.lastNameController,
                isRequired: true,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        Obx(
          () => AppTextField(
            label: 'Create Password',
            hint: 'At least 8 characters',
            controller: controller.passwordController,
            obscureText: !controller.isPasswordVisible.value,
            isRequired: true,
            prefixIcon: Icon(Iconsax.lock, color: AppColors.textMuted, size: 20.sp),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isPasswordVisible.value ? Iconsax.eye : Iconsax.eye_slash,
                color: AppColors.textMuted,
                size: 18.sp,
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
          ),
        ),
        SizedBox(height: 12.h),

        Obx(
          () => AppTextField(
            label: 'Confirm Password',
            hint: 'Re-type password',
            controller: controller.confirmPasswordController,
            obscureText: !controller.isPasswordVisible.value,
            isRequired: true,
            prefixIcon: Icon(Iconsax.lock, color: AppColors.textMuted, size: 20.sp),
          ),
        ),
        SizedBox(height: 16.h),

        AppButton(
          text: 'Complete & Setup Shop',
          isLoading: controller.isLoading.value,
          icon: const Icon(Iconsax.shop, color: Colors.white),
          onPressed: controller.completeRegistration,
        ),
      ],
    );
  }

  Widget _buildPerksQuickBar(BuildContext context) {
    return InkWell(
      onTap: () => _showBenefitsBottomSheet(context),
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.award, color: AppColors.primary, size: 18.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why 50,000+ merchants sell on Alif',
                    style: GoogleFonts.inter(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Tap to view commission rates, payout cycles & seller reviews',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Iconsax.arrow_right_3, size: 16.sp, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  void _showBenefitsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.borderStrong,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Seller Perks & Advantages',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Designed to empower Bangladeshi retailers and manufacturers',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 18.h),

                _buildBenefitItem(
                  icon: Iconsax.global,
                  title: 'Massive Nationwide Reach',
                  desc: 'Showcase your products to hundreds of thousands of active buyers with free catalog listing.',
                ),
                SizedBox(height: 12.h),

                _buildBenefitItem(
                  icon: Iconsax.card_tick,
                  title: 'Timely Automated Payouts',
                  desc: 'Funds are transferred directly into your verified bank account without manual payout requests.',
                ),
                SizedBox(height: 12.h),

                _buildBenefitItem(
                  icon: Iconsax.chart_2,
                  title: 'Powerful Seller Analytics',
                  desc: 'Track sales, order fulfillment, return rates, and customer reviews with our real-time dashboard.',
                ),
                SizedBox(height: 16.h),

                // Testimonial
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(Icons.star_rounded, color: AppColors.accent, size: 16.sp),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '"Joining Alif doubled our monthly orders within 2 weeks. The mobile onboarding process was seamless."',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '— Tanvir Hossain, Founder, Dhaka Craft Works',
                        style: GoogleFonts.inter(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                AppButton(
                  text: 'Got It, Let\'s Go',
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A smooth, continuous horizontal auto-scrolling Marquee widget
class AutoMarqueeWidget extends GetView<SellerGateController> {
  final List<Widget> children;
  final double speed; // pixels per second
  final double spacing;

  const AutoMarqueeWidget({
    super.key,
    required this.children,
    this.speed = 36.0,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller.marqueeScrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < 4; i++) ...[
            for (final child in children) ...[
              child,
              SizedBox(width: spacing),
            ],
          ],
        ],
      ),
    );
  }
}
