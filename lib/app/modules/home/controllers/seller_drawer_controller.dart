import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class SellerDrawerController extends GetxController {
  final HomeController homeController = Get.find<HomeController>();
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxBool isProductsExpanded = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (homeController.currentNavIndex.value == 2) {
      isProductsExpanded.value = true;
    }
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void toggleProductsExpanded() {
    isProductsExpanded.value = !isProductsExpanded.value;
  }
}

