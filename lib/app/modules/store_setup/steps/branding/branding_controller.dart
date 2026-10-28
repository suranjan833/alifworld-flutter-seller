import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/models/branding_model.dart';
import '../../../../data/services/api_service.dart';

class BrandingController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final ImagePicker _picker = ImagePicker();

  final policiesController = TextEditingController();

  final logoUrl = RxnString();
  final logoFileName = RxnString();
  final logoLocalPath = RxnString();
  final isLogoUploading = false.obs;

  final bannerUrl = RxnString();
  final bannerFileName = RxnString();
  final bannerLocalPath = RxnString();
  final isBannerUploading = false.obs;

  Future<void> pickLogo({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) return;

      logoLocalPath.value = image.path;
      logoFileName.value = image.name;
      isLogoUploading.value = true;

      final uploadedUrl = await _api.uploadFile(
        filePath: image.path,
        fileName: image.name,
        kind: 'logo',
      );

      isLogoUploading.value = false;

      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        logoUrl.value = uploadedUrl;
        Get.snackbar(
          'Logo Uploaded',
          'Store logo uploaded to CDN successfully.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Upload Failed',
          'Could not upload logo. Please check image format.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLogoUploading.value = false;
      Get.snackbar(
        'Error',
        'Failed to select image: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void removeLogo() {
    logoUrl.value = null;
    logoFileName.value = null;
    logoLocalPath.value = null;
  }

  Future<void> pickBanner({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image == null) return;

      bannerLocalPath.value = image.path;
      bannerFileName.value = image.name;
      isBannerUploading.value = true;

      final uploadedUrl = await _api.uploadFile(
        filePath: image.path,
        fileName: image.name,
        kind: 'logo',
      );

      isBannerUploading.value = false;

      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        bannerUrl.value = uploadedUrl;
        Get.snackbar(
          'Banner Uploaded',
          'Store banner cover uploaded to CDN successfully.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Upload Failed',
          'Could not upload banner cover. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isBannerUploading.value = false;
      Get.snackbar(
        'Error',
        'Failed to select banner image: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void removeBanner() {
    bannerUrl.value = null;
    bannerFileName.value = null;
    bannerLocalPath.value = null;
  }

  bool validate() {
    if (logoUrl.value == null && logoFileName.value == null) {
      Get.snackbar(
        'Branding Required',
        'Please upload a store logo',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }
    if (bannerUrl.value == null && bannerFileName.value == null) {
      Get.snackbar(
        'Branding Required',
        'Please upload a store banner cover image',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  BrandingModel getModel() {
    return BrandingModel(
      logoUrl: logoUrl.value,
      bannerUrl: bannerUrl.value,
      policies: policiesController.text.trim(),
    );
  }

  void populate(BrandingModel model) {
    logoUrl.value = model.logoUrl;
    bannerUrl.value = model.bannerUrl;
    policiesController.text = model.policies;
  }

  @override
  void onClose() {
    policiesController.dispose();
    super.onClose();
  }
}
