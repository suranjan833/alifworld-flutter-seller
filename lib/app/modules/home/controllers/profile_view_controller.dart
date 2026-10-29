import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/services/api_service.dart';
import '../../../data/theme/app_colors.dart';
import 'home_controller.dart';

class ProfileViewController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final RxBool isLoadingShop = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isSeoExpanded = true.obs;
  final Rxn<Map<String, dynamic>> shopData = Rxn<Map<String, dynamic>>();

  // General Shop Controllers
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController slugController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController policiesController = TextEditingController();

  // SEO & Social Controllers
  final TextEditingController metaTitleController = TextEditingController();
  final TextEditingController metaDescController = TextEditingController();
  final TextEditingController keywordsController = TextEditingController();
  final TextEditingController canonicalUrlController = TextEditingController();
  final TextEditingController robotsController = TextEditingController();
  final TextEditingController ogTitleController = TextEditingController();
  final TextEditingController ogDescController = TextEditingController();
  final TextEditingController ogTypeController = TextEditingController();
  final TextEditingController ogImageController = TextEditingController();
  final TextEditingController twitterTitleController = TextEditingController();
  final TextEditingController twitterDescController = TextEditingController();
  final TextEditingController twitterCardController = TextEditingController();
  final TextEditingController twitterImageController = TextEditingController();

  // Images state
  final Rxn<String> logoUrl = Rxn<String>();
  final Rxn<String> bannerUrl = Rxn<String>();
  final RxBool isLogoUploading = false.obs;
  final RxBool isBannerUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadShopProfile();
  }

  @override
  void onClose() {
    shopNameController.dispose();
    slugController.dispose();
    descController.dispose();
    policiesController.dispose();

    metaTitleController.dispose();
    metaDescController.dispose();
    keywordsController.dispose();
    canonicalUrlController.dispose();
    robotsController.dispose();
    ogTitleController.dispose();
    ogDescController.dispose();
    ogTypeController.dispose();
    ogImageController.dispose();
    twitterTitleController.dispose();
    twitterDescController.dispose();
    twitterCardController.dispose();
    twitterImageController.dispose();
    super.onClose();
  }

  bool isValidUri(String? s) {
    if (s == null || s.trim().isEmpty) return false;
    final uri = Uri.tryParse(s.trim());
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }

  Future<void> loadShopProfile() async {
    isLoadingShop.value = true;
    try {
      final shop = await _api.getShop();
      if (shop != null) {
        shopData.value = shop;
        populateFields(shop);
      } else if (shopNameController.text.isEmpty && Get.isRegistered<HomeController>()) {
        final fallbackName = Get.find<HomeController>().sellerName;
        if (fallbackName.isNotEmpty) {
          shopNameController.text = fallbackName;
          slugController.text =
              fallbackName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
        }
      }
    } catch (_) {
    } finally {
      isLoadingShop.value = false;
    }
  }

  void populateFields(Map<String, dynamic> shop) {
    shopNameController.text = shop['shopName']?.toString() ?? '';
    slugController.text = shop['slug']?.toString() ?? '';
    descController.text = shop['description']?.toString() ?? '';
    policiesController.text = shop['policies']?.toString() ?? '';
    logoUrl.value = shop['logoUrl']?.toString();
    bannerUrl.value = shop['bannerUrl']?.toString();

    final seo = shop['seoMeta'] as Map<String, dynamic>? ?? {};
    metaTitleController.text = seo['title']?.toString() ?? '';
    metaDescController.text = seo['description']?.toString() ?? '';
    keywordsController.text = seo['keywords']?.toString() ?? '';
    canonicalUrlController.text = seo['canonicalUrl']?.toString() ?? '';
    robotsController.text = seo['robots']?.toString() ?? '';
    ogTitleController.text = seo['ogTitle']?.toString() ?? '';
    ogDescController.text = seo['ogDescription']?.toString() ?? '';
    ogTypeController.text = seo['ogType']?.toString() ?? '';
    ogImageController.text = seo['ogImage']?.toString() ?? '';
    twitterTitleController.text = seo['twitterTitle']?.toString() ?? '';
    twitterDescController.text = seo['twitterDescription']?.toString() ?? '';
    twitterCardController.text = seo['twitterCard']?.toString() ?? '';
    twitterImageController.text = seo['twitterImage']?.toString() ?? '';
  }

  Future<void> pickAndUploadImage({required bool isLogo}) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image == null) return;

      if (isLogo) {
        isLogoUploading.value = true;
      } else {
        isBannerUploading.value = true;
      }

      final uploadedUrl = await _api.uploadFile(
        filePath: image.path,
        fileName: image.name,
        kind: isLogo ? 'logo' : 'banner',
      );

      if (isLogo) {
        isLogoUploading.value = false;
        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          logoUrl.value = uploadedUrl;
        }
      } else {
        isBannerUploading.value = false;
        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          bannerUrl.value = uploadedUrl;
        }
      }

      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        Get.snackbar(
          isLogo ? 'Logo Uploaded' : 'Banner Uploaded',
          'Asset uploaded successfully to CDN.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Upload Failed',
          'Could not upload asset. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (isLogo) {
        isLogoUploading.value = false;
      } else {
        isBannerUploading.value = false;
      }
      Get.snackbar(
        'Upload Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> saveShopProfile() async {
    if (shopNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Required Field',
        'Shop name is required.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
      );
      return;
    }

    isSaving.value = true;

    final seoMap = <String, dynamic>{};
    if (metaTitleController.text.trim().isNotEmpty) seoMap['title'] = metaTitleController.text.trim();
    if (metaDescController.text.trim().isNotEmpty) seoMap['description'] = metaDescController.text.trim();
    if (keywordsController.text.trim().isNotEmpty) seoMap['keywords'] = keywordsController.text.trim();
    if (isValidUri(canonicalUrlController.text)) seoMap['canonicalUrl'] = canonicalUrlController.text.trim();
    if (robotsController.text.trim().isNotEmpty) seoMap['robots'] = robotsController.text.trim();
    if (ogTitleController.text.trim().isNotEmpty) seoMap['ogTitle'] = ogTitleController.text.trim();
    if (ogDescController.text.trim().isNotEmpty) seoMap['ogDescription'] = ogDescController.text.trim();
    if (ogTypeController.text.trim().isNotEmpty) seoMap['ogType'] = ogTypeController.text.trim();
    if (isValidUri(ogImageController.text)) seoMap['ogImage'] = ogImageController.text.trim();
    if (twitterTitleController.text.trim().isNotEmpty) seoMap['twitterTitle'] = twitterTitleController.text.trim();
    if (twitterDescController.text.trim().isNotEmpty) seoMap['twitterDescription'] = twitterDescController.text.trim();
    if (twitterCardController.text.trim().isNotEmpty) seoMap['twitterCard'] = twitterCardController.text.trim();
    if (isValidUri(twitterImageController.text)) seoMap['twitterImage'] = twitterImageController.text.trim();

    final payload = <String, dynamic>{
      'shopName': shopNameController.text.trim(),
      if (slugController.text.trim().isNotEmpty) 'slug': slugController.text.trim(),
      if (isValidUri(logoUrl.value)) 'logoUrl': logoUrl.value,
      if (isValidUri(bannerUrl.value)) 'bannerUrl': bannerUrl.value,
      if (descController.text.trim().isNotEmpty) 'description': descController.text.trim(),
      if (policiesController.text.trim().isNotEmpty) 'policies': policiesController.text.trim(),
      if (seoMap.isNotEmpty) 'seoMeta': seoMap,
    };

    final updated = await _api.updateShop(payload);

    isSaving.value = false;

    if (updated != null) {
      shopData.value = updated;
      populateFields(updated);
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchUserProfile();
      }
      Get.snackbar(
        'Success',
        'Shop profile updated successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
    } else {
      final errorMsg = _api.lastApiError ?? 'Could not update shop profile. Please verify your data and try again.';
      Get.snackbar(
        'Update Failed',
        errorMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }
}

