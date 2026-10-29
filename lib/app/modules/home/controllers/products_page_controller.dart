import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/api_service.dart';
import '../../../data/theme/app_colors.dart';
import 'home_controller.dart';

class ProductsPageController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final RxBool isLoading = true.obs;
  final RxList<dynamic> products = <dynamic>[].obs;
  final RxString selectedFilter = 'all'.obs;

  final List<Map<String, String>> statusTabs = const [
    {'label': 'All', 'value': 'all'},
    {'label': 'Live', 'value': 'live'},
    {'label': 'Draft', 'value': 'draft'},
    {'label': 'Pending', 'value': 'pending'},
    {'label': 'Archived', 'value': 'archived'},
  ];

  Worker? _catalogWorker;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    if (Get.isRegistered<HomeController>()) {
      _catalogWorker = ever(
        Get.find<HomeController>().productCatalogRefreshTrigger,
        (_) => fetchProducts(),
      );
    }
  }

  @override
  void onClose() {
    _catalogWorker?.dispose();
    super.onClose();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      final statusParam = selectedFilter.value == 'all' ? null : selectedFilter.value;
      final res = await _api.getProducts(status: statusParam);

      if (res != null) {
        products.value = (res['products'] as List<dynamic>?) ?? [];
      } else {
        products.clear();
      }
    } catch (_) {
      products.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void changeFilter(String newFilter) {
    if (selectedFilter.value == newFilter) return;
    selectedFilter.value = newFilter;
    fetchProducts();
  }

  Future<void> toggleVisibility(String productId, bool currentVal) async {
    final success = await _api.toggleProductVisibility(productId, !currentVal);
    if (success) {
      Get.snackbar(
        'Visibility Updated',
        !currentVal ? 'Product is now visible in storefront.' : 'Product hidden from storefront.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      fetchProducts();
    } else {
      Get.snackbar(
        'Failed',
        'Could not update product visibility.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> submitProduct(String productId) async {
    final success = await _api.submitProduct(productId);
    if (success) {
      Get.snackbar(
        'Submitted for Review',
        'Draft product submitted to Alifworld moderation team.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      fetchProducts();
    } else {
      Get.snackbar(
        'Submission Failed',
        'Ensure product has name, category, and priced variants with stock.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'live':
        return AppColors.success;
      case 'draft':
        return AppColors.warning;
      case 'pending':
        return AppColors.info;
      case 'archived':
        return AppColors.textMuted;
      default:
        return AppColors.textSecondary;
    }
  }
}

