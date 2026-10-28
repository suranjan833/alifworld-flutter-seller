import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/shop_info_model.dart';

class ShopInfoController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final slugController = TextEditingController();
  final descController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  final selectedCategory = 'Fashion & Apparel'.obs;
  final categories = [
    'Fashion & Apparel',
    'Electronics & Gadgets',
    'Groceries & Daily Needs',
    'Health & Beauty',
    'Home & Lifestyle',
    'Books & Stationery',
    'General Merchandise',
  ];

  final isSlugAuto = true.obs;

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    if (isSlugAuto.value) {
      final generated = ShopInfoModel.generateSlug(nameController.text);
      slugController.text = generated;
    }
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  bool validate() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Required',
        'Shop name is required',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }

    final phone = phoneController.text.trim();
    if (phone.isNotEmpty) {
      final digits = phone.replaceAll(RegExp(r'\D'), '');
      if (digits.length < 10 || digits.length > 11) {
        Get.snackbar(
          'Invalid Support Phone',
          'Support phone number must be between 10 and 11 digits',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return false;
      }
    }

    return formKey.currentState?.validate() ?? true;
  }

  ShopInfoModel getModel() {
    return ShopInfoModel(
      shopName: nameController.text.trim(),
      shopSlug: slugController.text.trim(),
      shopDescription: descController.text.trim(),
      businessCategory: selectedCategory.value,
      supportPhone: phoneController.text.trim(),
      supportEmail: emailController.text.trim(),
    );
  }

  void populate(ShopInfoModel model) {
    nameController.text = model.shopName;
    slugController.text = model.shopSlug;
    descController.text = model.shopDescription;
    if (model.businessCategory != null) {
      selectedCategory.value = model.businessCategory!;
    }
    if (model.supportPhone != null) phoneController.text = model.supportPhone!;
    if (model.supportEmail != null) emailController.text = model.supportEmail!;
  }

  @override
  void onClose() {
    nameController.removeListener(_onNameChanged);
    nameController.dispose();
    slugController.dispose();
    descController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }
}

