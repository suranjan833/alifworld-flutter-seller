import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/api_service.dart';
import '../../../data/theme/app_colors.dart';

class OrdersPageController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final RxBool isLoading = true.obs;
  final RxList<dynamic> orders = <dynamic>[].obs;
  final Rxn<Map<String, dynamic>> summary = Rxn<Map<String, dynamic>>();
  final RxString selectedFilter = 'all'.obs;

  final List<Map<String, String>> statusTabs = const [
    {'label': 'All', 'value': 'all'},
    {'label': 'Pending', 'value': 'pending'},
    {'label': 'Confirmed', 'value': 'confirmed'},
    {'label': 'Packed', 'value': 'packed'},
    {'label': 'Out for Delivery', 'value': 'out_for_delivery'},
    {'label': 'Delivered', 'value': 'delivered'},
    {'label': 'Cancelled', 'value': 'cancelled'},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    try {
      final statusParam = selectedFilter.value == 'all' ? null : selectedFilter.value;
      final res = await _api.getOrders(status: statusParam);

      if (res != null) {
        orders.value = (res['orders'] as List<dynamic>?) ?? [];
        if (res['summary'] != null) {
          summary.value = res['summary'] as Map<String, dynamic>?;
        }
      } else {
        orders.clear();
      }
    } catch (_) {
      orders.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void changeFilter(String newFilter) {
    if (selectedFilter.value == newFilter) return;
    selectedFilter.value = newFilter;
    fetchOrders();
  }

  int getStatusCount(String statusKey) {
    if (summary.value == null) return 0;
    if (statusKey == 'all') {
      return (summary.value!['totalCount'] as num?)?.toInt() ?? 0;
    }
    final byStatus = summary.value!['byStatus'] as Map<String, dynamic>?;
    if (byStatus == null) return 0;
    return (byStatus[statusKey] as num?)?.toInt() ?? 0;
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
      case 'packed':
      case 'out_for_delivery':
        return AppColors.info;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

