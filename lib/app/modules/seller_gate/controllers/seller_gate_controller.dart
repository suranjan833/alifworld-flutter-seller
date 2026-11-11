import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/api_service.dart';
import '../../../routes/app_pages.dart';

class SellerGateController extends GetxController {
  late final ApiService _api;

  // Mode: true = Login, false = Sign Up (Registration)
  final isLoginMode = true.obs;
  final isOtpLogin = false.obs;

  // Gate Registration Steps: 1: Phone, 2: Email, 3: Password & Name
  final gateStep = 1.obs;
  final isLoading = false.obs;

  // --- Login State ---
  final loginAccountController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final isLoginPasswordVisible = false.obs;
  final rememberMe = true.obs;

  // --- Step 1: Phone Registration ---
  final phoneController = TextEditingController();
  final phoneOtpController = TextEditingController();
  final isPhoneOtpSent = false.obs;
  final phoneResendCountdown = 0.obs;
  final isAutoResendingPhoneOtp = false.obs;
  String lastOtpSentPhone = '';
  Timer? _phoneTimer;
  Timer? _phoneChangeDebounce;

  // --- Step 2: Email Registration ---
  final emailController = TextEditingController();
  final emailOtpController = TextEditingController();
  final isEmailOtpSent = false.obs;
  final emailResendCountdown = 0.obs;
  Timer? _emailTimer;

  // --- Step 3: Account info ---
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isPasswordVisible = false.obs;

  // Token storage
  String? regToken;
  String? emailToken;

  // --- Forgot / Reset Password State (§3.1) ---
  final forgotPhoneController = TextEditingController();
  final forgotOtpController = TextEditingController();
  final forgotNewPasswordController = TextEditingController();
  final forgotConfirmPasswordController = TextEditingController();
  final isForgotOtpSent = false.obs;
  final forgotCountdown = 0.obs;
  final isForgotLoading = false.obs;
  final isForgotNewPasswordVisible = false.obs;
  Timer? _forgotTimer;

  // Marquee ticker
  final marqueeScrollController = ScrollController();
  bool _isMarqueeScrolling = false;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();

    phoneController.addListener(_onPhoneChanged);

    if (Get.arguments != null && Get.arguments is Map) {
      if (Get.arguments['isLogin'] != null) {
        isLoginMode.value = Get.arguments['isLogin'] as bool;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => startMarqueeLoop());
  }

  void startMarqueeLoop({double speed = 36.0}) async {
    _isMarqueeScrolling = true;
    while (_isMarqueeScrolling) {
      if (!marqueeScrollController.hasClients) {
        await Future.delayed(const Duration(milliseconds: 100));
        continue;
      }
      final max = marqueeScrollController.position.maxScrollExtent;
      final current = marqueeScrollController.offset;
      final remaining = max - current;
      if (remaining <= 0) {
        marqueeScrollController.jumpTo(0);
        continue;
      }
      final durationMs = (remaining / speed * 1000).toInt();
      try {
        await marqueeScrollController.animateTo(
          max,
          duration: Duration(milliseconds: durationMs),
          curve: Curves.linear,
        );
        if (marqueeScrollController.hasClients) {
          marqueeScrollController.jumpTo(0);
        }
      } catch (_) {
        break;
      }
    }
  }

  void _onPhoneChanged() {
    final currentPhone = phoneController.text.trim().replaceAll(
      RegExp(r'\D'),
      '',
    );

    // If OTP was already sent previously and user changes/edits the phone number:
    if (isPhoneOtpSent.value &&
        lastOtpSentPhone.isNotEmpty &&
        currentPhone != lastOtpSentPhone) {
      // Clear old verification code immediately since phone changed
      phoneOtpController.clear();
      _phoneChangeDebounce?.cancel();

      // Automatically trigger OTP resend once user enters a full valid number (10 or 11 digits)
      if (currentPhone.length >= 10 && currentPhone.length <= 11) {
        _phoneChangeDebounce = Timer(const Duration(milliseconds: 650), () {
          final phoneNow = phoneController.text.trim().replaceAll(
            RegExp(r'\D'),
            '',
          );
          if (phoneNow.length >= 10 &&
              phoneNow.length <= 11 &&
              phoneNow != lastOtpSentPhone) {
            requestPhoneOtp(isAutoResend: true);
          }
        });
      }
    }
  }

  void toggleAuthMode() {
    isLoginMode.value = !isLoginMode.value;
  }

  void switchToSignUp() {
    isLoginMode.value = false;
  }

  void switchToLogin() {
    isLoginMode.value = true;
  }

  void toggleLoginPasswordVisibility() {
    isLoginPasswordVisible.value = !isLoginPasswordVisible.value;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  String _mapAuthErrorMessage(String? code, String? fallback) {
    switch (code) {
      case 'INVALID_CREDENTIALS':
        return 'Invalid email/phone or password. Please verify and try again.';
      case 'OTP_INVALID':
        return 'Incorrect verification code. Please check the code and try again.';
      case 'OTP_NOT_FOUND':
        return 'Verification code expired or not found. Please request a new code.';
      case 'OTP_LOCKED':
        return 'Too many incorrect attempts. Please wait 10 minutes and request a new code.';
      case 'USER_NOT_FOUND':
        return 'No account found with this phone number.';
      case 'USER_SUSPENDED':
        return 'Your merchant account has been suspended. Please contact support.';
      case 'USER_BLOCKED':
        return 'Your merchant account has been blocked. Please contact support.';
      case 'RATE_LIMITED':
        return 'Too many login attempts. Please wait a minute before trying again.';
      case 'VALIDATION_ERROR':
        return fallback ?? 'Invalid input data. Please check and try again.';
      default:
        return fallback ?? 'Could not complete login. Please try again.';
    }
  }

  Future<void> _handlePostLoginLanding() async {
    try {
      final statusRes = await _api.getOnboardingStatus();
      final seller = statusRes?['seller'] as Map<String, dynamic>?;
      if (seller == null) {
        Get.offAllNamed(Routes.STORE_SETUP);
      } else {
        final status = seller['status']?.toString().toLowerCase();
        if (status == 'approved') {
          Get.offAllNamed(Routes.HOME);
        } else if (status == 'pending') {
          Get.offAllNamed(Routes.ONBOARDING_PENDING);
        } else {
          Get.offAllNamed(Routes.STORE_SETUP);
        }
      }
    } catch (_) {
      Get.offAllNamed(Routes.STORE_SETUP);
    }
  }

  // --- Log In Logic ---
  void login() async {
    final account = loginAccountController.text.trim();
    final password = loginPasswordController.text;

    if (account.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please enter your phone number or email address',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final isEmail = account.contains('@');
    if (isEmail) {
      if (!GetUtils.isEmail(account)) {
        Get.snackbar(
          'Invalid Email',
          'Please enter a valid email address',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }
    } else {
      final digits = account.replaceAll(RegExp(r'\D'), '');
      if (digits.length < 10 || digits.length > 15) {
        Get.snackbar(
          'Invalid Phone Number',
          'Phone number must be between 10 and 15 digits',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }
    }

    if (password.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please enter your merchant account password',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final res = await _api.loginWithPassword(
        identifier: account,
        password: password,
      );
      isLoading.value = false;

      if (res != null && res['accessToken'] != null) {
        await _api.getProfile();
        Get.snackbar(
          'Login Successful',
          'Welcome back to Alif Seller Partner Portal',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Routing rule per §5:
        await _handlePostLoginLanding();
      } else {
        final errorMsg = _mapAuthErrorMessage(
          _api.lastApiErrorCode,
          _api.lastApiError,
        );
        Get.snackbar(
          'Login Failed',
          errorMsg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;
      final errorMsg = _mapAuthErrorMessage(
        _api.lastApiErrorCode,
        _api.lastApiError,
      );
      Get.snackbar(
        'Login Error',
        errorMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  // --- Step 1: Phone ---
  void requestPhoneOtp({bool isAutoResend = false}) async {
    final phone = phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (phone.length < 10 || phone.length > 11) {
      if (!isAutoResend) {
        Get.snackbar(
          'Invalid Phone Number',
          'Please enter a valid phone number (minimum 10, maximum 11 digits)',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
      return;
    }

    if (isAutoResend) {
      isAutoResendingPhoneOtp.value = true;
      _phoneTimer?.cancel();
      phoneResendCountdown.value = 0;
    } else {
      isLoading.value = true;
    }

    try {
      final res = await _api.requestPhoneOtp(
        phone: phone,
        purpose: isLoginMode.value ? 'login' : 'register',
      );
      isLoading.value = false;
      isAutoResendingPhoneOtp.value = false;
      isPhoneOtpSent.value = true;
      lastOtpSentPhone = phone;

      _startPhoneResendTimer();

      // Automatically add devCode only in dev/debug mode (§2.1: never in production)
      final devCode = res?['devCode']?.toString();
      if (kDebugMode && devCode != null && devCode.isNotEmpty) {
        phoneOtpController.text = devCode;
      }

      final showDevCode = kDebugMode && devCode != null && devCode.isNotEmpty;
      Get.snackbar(
        isAutoResend ? 'Number Updated & OTP Sent' : 'OTP Sent',
        isAutoResend
            ? (showDevCode
                  ? 'Phone updated! Code ($devCode) auto-added.'
                  : 'Phone updated! New verification code sent to +880 $phone.')
            : (showDevCode
                  ? 'Code ($devCode) auto-added.'
                  : 'A 6-digit verification code was sent to +880 $phone via SMS.'),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      isLoading.value = false;
      isAutoResendingPhoneOtp.value = false;
      final errorMsg = _mapAuthErrorMessage(
        _api.lastApiErrorCode,
        _api.lastApiError ?? 'Failed to request verification code. Please try again.',
      );
      Get.snackbar(
        'Error',
        errorMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void _startPhoneResendTimer() {
    phoneResendCountdown.value = 60;
    _phoneTimer?.cancel();
    _phoneTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (phoneResendCountdown.value > 0) {
        phoneResendCountdown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  void verifyPhoneOtp() async {
    final code = phoneOtpController.text.trim();
    final phone = phoneController.text.trim().replaceAll(RegExp(r'\D'), '');

    if (phone.length < 10 || phone.length > 11) {
      Get.snackbar(
        'Invalid Phone Number',
        'Phone number must be between 10 and 11 digits',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (code.length < 4) {
      Get.snackbar(
        'Invalid Code',
        'Please enter the complete verification code',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final res = await _api.verifyPhoneOtp(
        phone: phone,
        code: code,
        purpose: isLoginMode.value ? 'login' : 'register',
      );
      isLoading.value = false;

      if (isLoginMode.value) {
        if (res != null && res['accessToken'] != null) {
          await _api.getProfile();
          Get.snackbar(
            'Login Verified',
            'Successfully logged in to Alif Seller.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Routing rule per §5:
          await _handlePostLoginLanding();
        } else {
          // If phone is not registered, branch to registration per §1.1
          if (_api.lastApiErrorCode == 'USER_NOT_FOUND') {
            Get.snackbar(
              'No Account Found',
              'No merchant account found for this phone number. Redirecting to registration...',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.orangeAccent,
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
            );
            isLoginMode.value = false;
            gateStep.value = 1;
            return;
          }

          final errorMsg = _mapAuthErrorMessage(
            _api.lastApiErrorCode,
            _api.lastApiError ?? 'The verification code is incorrect.',
          );
          Get.snackbar(
            'Verification Failed',
            errorMsg,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      } else {
        final token = res?['regToken']?.toString();
        if (token != null && token.isNotEmpty) {
          regToken = token;
          gateStep.value = 2; // move to email verification
          Get.snackbar(
            'Phone Verified',
            'Mobile number verified successfully. Now verify your email.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          final errorMsg = _mapAuthErrorMessage(
            _api.lastApiErrorCode,
            _api.lastApiError ?? 'The verification code is incorrect.',
          );
          Get.snackbar(
            'Verification Failed',
            errorMsg,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      isLoading.value = false;
      final errorMsg = _mapAuthErrorMessage(
        _api.lastApiErrorCode,
        _api.lastApiError ?? 'The verification code is incorrect.',
      );
      Get.snackbar(
        'Verification Failed',
        errorMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  // --- Step 2: Email ---
  void requestEmailOtp() async {
    final email = emailController.text.trim();
    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Invalid Email',
        'Please enter a valid business email address',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final res = await _api.requestEmailOtp(email: email);
      isLoading.value = false;
      isEmailOtpSent.value = true;

      _startEmailResendTimer();

      // Automatically add devCode only in dev/debug mode
      final devCode = res?['devCode']?.toString();
      if (kDebugMode && devCode != null && devCode.isNotEmpty) {
        emailOtpController.text = devCode;
      }

      final showDevCode = kDebugMode && devCode != null && devCode.isNotEmpty;
      Get.snackbar(
        'OTP Sent',
        showDevCode
            ? 'Code ($devCode) auto-added.'
            : 'A 6-digit verification code was sent to $email.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      final errorMsg = _mapAuthErrorMessage(
        _api.lastApiErrorCode,
        _api.lastApiError ?? 'Failed to send email verification code.',
      );
      Get.snackbar(
        'Error',
        errorMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void _startEmailResendTimer() {
    emailResendCountdown.value = 60;
    _emailTimer?.cancel();
    _emailTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (emailResendCountdown.value > 0) {
        emailResendCountdown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  void verifyEmailOtp() async {
    final code = emailOtpController.text.trim();
    final email = emailController.text.trim();

    if (code.length < 4) {
      Get.snackbar(
        'Invalid Code',
        'Please enter the 6-digit email verification code',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final res = await _api.verifyEmailOtp(email: email, code: code);
      isLoading.value = false;

      final token = res?['emailToken']?.toString();
      if (token != null && token.isNotEmpty) {
        emailToken = token;
        gateStep.value = 3; // move to account details
        Get.snackbar(
          'Email Verified',
          'Email verified successfully. Complete your account details.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        final errorMsg =
            _api.lastApiError ?? 'The verification code is incorrect.';
        Get.snackbar(
          'Verification Failed',
          errorMsg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;
      final errorMsg =
          _api.lastApiError ?? 'The verification code is incorrect.';
      Get.snackbar(
        'Verification Failed',
        errorMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  // --- Step 3: Account Info & Register ---
  void completeRegistration() async {
    final first = firstNameController.text.trim();
    final last = lastNameController.text.trim();
    final pass = passwordController.text;
    final confirm = confirmPasswordController.text;
    final email = emailController.text.trim();

    final phone = phoneController.text.trim().replaceAll(RegExp(r'\D'), '');

    if (first.isEmpty || last.isEmpty) {
      Get.snackbar(
        'Required',
        'First and Last names are required',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (pass.length < 8) {
      Get.snackbar(
        'Password Weak',
        'Password must be at least 8 characters long',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (pass != confirm) {
      Get.snackbar(
        'Mismatch',
        'Passwords do not match',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (regToken == null || emailToken == null) {
      Get.snackbar(
        'Session Error',
        'Verification tokens missing or expired. Please verify your phone and email again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      gateStep.value = 1;
      return;
    }

    isLoading.value = true;
    try {
      final res = await _api.completeRegistration(
        regToken: regToken!,
        emailToken: emailToken!,
        email: email,
        firstName: first,
        lastName: last,
        password: pass,
      );

      if (res != null) {
        // §0.2 & §2.6: POST /auth/register/complete creates user and sets a web session cookie,
        // but returns NO Bearer tokens. The app MUST call POST /auth/token (§3.1) with phone and password.
        final tokenRes = await _api.loginWithPassword(
          identifier: phone,
          password: pass,
        );

        isLoading.value = false;

        if (tokenRes != null && tokenRes['accessToken'] != null) {
          await _api.getProfile();
          Get.snackbar(
            'Registration Successful',
            'Account created! Let\'s setup your store.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Routing per §5:
          await _handlePostLoginLanding();
        } else {
          Get.snackbar(
            'Account Created',
            'Your account has been created. Please sign in with your phone and password.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          isLoginMode.value = true;
          gateStep.value = 1;
        }
      } else {
        isLoading.value = false;
        final code = _api.lastApiErrorCode;
        final msg = _api.lastApiError;

        if (code == 'USER_EXISTS') {
          Get.snackbar(
            'Account Already Exists',
            'This phone number is already registered. Please sign in.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orangeAccent,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          isLoginMode.value = true;
          gateStep.value = 1;
        } else if (code == 'EMAIL_TAKEN') {
          Get.snackbar(
            'Email Taken',
            'This email is already registered. Please use another email address.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          gateStep.value = 2; // return to email step
        } else if (code == 'INVALID_TOKEN') {
          Get.snackbar(
            'Verification Expired',
            'Your verification session has expired. Please verify your phone again.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          gateStep.value = 1;
        } else {
          Get.snackbar(
            'Registration Failed',
            msg ?? 'Could not complete registration. Please try again.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        _api.lastApiError ?? 'Registration error occurred. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  // --- Forgot / Reset Password Logic (§3.1) ---
  void _startForgotCountdown() {
    forgotCountdown.value = 60;
    _forgotTimer?.cancel();
    _forgotTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (forgotCountdown.value > 0) {
        forgotCountdown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  void requestForgotOtp() async {
    final phone = forgotPhoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (phone.length < 10 || phone.length > 15) {
      Get.snackbar(
        'Invalid Phone Number',
        'Please enter a valid phone number (between 10 and 15 digits)',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isForgotLoading.value = true;
    try {
      final res = await _api.requestPhoneOtp(
        phone: phone,
        purpose: 'reset',
      );
      isForgotLoading.value = false;

      if (res != null || _api.lastApiErrorCode == null) {
        isForgotOtpSent.value = true;
        _startForgotCountdown();

        final devCode = res?['devCode']?.toString();
        if (kDebugMode && devCode != null && devCode.isNotEmpty) {
          forgotOtpController.text = devCode;
        }

        final showDev = kDebugMode && devCode != null && devCode.isNotEmpty;
        Get.snackbar(
          'Reset Code Sent',
          showDev
              ? 'Code ($devCode) auto-added.'
              : 'Password reset code sent to +880 $phone via SMS.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        final errorMsg = _mapAuthErrorMessage(
          _api.lastApiErrorCode,
          _api.lastApiError ?? 'Failed to send reset code.',
        );
        Get.snackbar(
          'Error',
          errorMsg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isForgotLoading.value = false;
      Get.snackbar(
        'Error',
        'Could not send reset code. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void submitResetPassword() async {
    final phone = forgotPhoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    final code = forgotOtpController.text.trim();
    final newPass = forgotNewPasswordController.text;
    final confirmPass = forgotConfirmPasswordController.text;

    if (code.length < 4) {
      Get.snackbar(
        'Invalid Code',
        'Please enter the 6-digit reset code sent to your phone',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (newPass.length < 8 || newPass.length > 128) {
      Get.snackbar(
        'Invalid Password',
        'Password must be between 8 and 128 characters',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (newPass != confirmPass) {
      Get.snackbar(
        'Password Mismatch',
        'New password and confirm password do not match',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isForgotLoading.value = true;
    try {
      final ok = await _api.resetPassword(
        phone: phone,
        code: code,
        newPassword: newPass,
      );
      isForgotLoading.value = false;

      if (ok) {
        if (Get.isBottomSheetOpen ?? false) {
          Get.back();
        }
        loginAccountController.text = phone;
        loginPasswordController.text = newPass;
        isLoginMode.value = true;
        isOtpLogin.value = false;

        Get.snackbar(
          'Password Reset Successful',
          'Your password has been changed. You can now log in.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        final errorMsg = _mapAuthErrorMessage(
          _api.lastApiErrorCode,
          _api.lastApiError ?? 'Password reset failed. Please check the code.',
        );
        Get.snackbar(
          'Reset Failed',
          errorMsg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isForgotLoading.value = false;
      Get.snackbar(
        'Error',
        'Could not reset password. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    _isMarqueeScrolling = false;
    marqueeScrollController.dispose();
    phoneController.removeListener(_onPhoneChanged);
    _phoneChangeDebounce?.cancel();
    _phoneTimer?.cancel();
    _emailTimer?.cancel();
    _forgotTimer?.cancel();
    loginAccountController.dispose();
    loginPasswordController.dispose();
    phoneController.dispose();
    phoneOtpController.dispose();
    emailController.dispose();
    emailOtpController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    forgotPhoneController.dispose();
    forgotOtpController.dispose();
    forgotNewPasswordController.dispose();
    forgotConfirmPasswordController.dispose();
    super.onClose();
  }
}
