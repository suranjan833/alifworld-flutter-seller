import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/inventory_model.dart';
import '../../../data/services/api_service.dart';

class InventoryController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  // Tabs: 0 = Low Stock Alerts, 1 = Ledger / History
  final selectedTab = 0.obs;

  // --- Low Stock Section ---
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final products = <InventoryProductModel>[].obs;
  String? nextCursor;

  // --- Stock History / Ledger Section ---
  final isLoadingHistory = false.obs;
  final isLoadingMoreHistory = false.obs;
  final historyEntries = <InventoryLedgerEntry>[].obs;
  final selectedProductId = ''.obs;
  final selectedProductName = ''.obs;
  String? historyNextCursor;

  // --- Adjust Stock Form State ---
  final isAdjusting = false.obs;
  final adjustKind = 'in'.obs; // 'in' | 'out' | 'adjustment'
  final adjustQty = 0.obs;
  final adjustNote = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInventory();
  }

  /// GET /seller/inventory?lowStock=true
  Future<void> fetchInventory({bool showLoading = true}) async {
    if (showLoading) isLoading.value = true;
    try {
      final res = await _api.getLowStockInventory(limit: 20);
      if (res != null) {
        final list = res['products'] as List<dynamic>? ?? [];
        products.value = list
            .map((item) => InventoryProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
        nextCursor = res['nextCursor']?.toString();
      } else {
        products.clear();
        nextCursor = null;
      }
    } catch (e) {
      log('Error fetching inventory: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Cursor pagination for low-stock items
  Future<void> loadMoreInventory() async {
    if (isLoadingMore.value || nextCursor == null || nextCursor!.isEmpty) return;
    isLoadingMore.value = true;
    try {
      final res = await _api.getLowStockInventory(limit: 20, cursor: nextCursor);
      if (res != null) {
        final list = res['products'] as List<dynamic>? ?? [];
        final newItems = list
            .map((item) => InventoryProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
        products.addAll(newItems);
        nextCursor = res['nextCursor']?.toString();
      }
    } catch (e) {
      log('Error loading more inventory: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// GET /seller/inventory?productId=`productId`
  Future<void> fetchProductHistory(
    String productId, {
    String? productName,
    bool showLoading = true,
  }) async {
    selectedProductId.value = productId;
    if (productName != null) selectedProductName.value = productName;
    if (showLoading) isLoadingHistory.value = true;

    try {
      final res = await _api.getProductInventoryHistory(productId: productId, limit: 20);
      if (res != null) {
        final rawEntries = res['entries'] as List<dynamic>? ?? [];
        historyEntries.value = rawEntries
            .map((e) => InventoryLedgerEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        historyNextCursor = res['nextCursor']?.toString();
      } else {
        historyEntries.clear();
        historyNextCursor = null;
      }
    } catch (e) {
      log('Error fetching product history: $e');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  /// Cursor pagination for history ledger
  Future<void> loadMoreHistory() async {
    if (isLoadingMoreHistory.value ||
        historyNextCursor == null ||
        historyNextCursor!.isEmpty ||
        selectedProductId.isEmpty) {
      return;
    }
    isLoadingMoreHistory.value = true;
    try {
      final res = await _api.getProductInventoryHistory(
        productId: selectedProductId.value,
        limit: 20,
        cursor: historyNextCursor,
      );
      if (res != null) {
        final rawEntries = res['entries'] as List<dynamic>? ?? [];
        final newEntries = rawEntries
            .map((e) => InventoryLedgerEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        historyEntries.addAll(newEntries);
        historyNextCursor = res['nextCursor']?.toString();
      }
    } catch (e) {
      log('Error loading more history: $e');
    } finally {
      isLoadingMoreHistory.value = false;
    }
  }

  /// POST /seller/inventory/adjust
  /// Follows commit 60c5a25 rule:
  /// - 'in': sends positive magnitude -> server adds +changeQty
  /// - 'out': sends positive magnitude -> server subtracts -changeQty
  /// - 'adjustment': sends signed delta -> server posts exactly what is sent
  Future<bool> adjustStock({
    required String productId,
    required String variantId,
    required int changeQty,
    required String kind,
    String? note,
  }) async {
    if (changeQty == 0) {
      Get.snackbar(
        'Invalid Quantity',
        'Quantity cannot be zero.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }

    isAdjusting.value = true;
    final res = await _api.adjustStock(
      productId: productId,
      variantId: variantId,
      changeQty: changeQty,
      kind: kind,
      note: note,
    );
    isAdjusting.value = false;

    if (res != null) {
      final adjustment = res['adjustment'] as Map<String, dynamic>?;
      final int? newBalance = (adjustment?['balanceQty'] as num?)?.toInt();

      // Rule: replace current stock with the server response's balanceQty directly!
      if (newBalance != null) {
        final idx = products.indexWhere((p) => p.variantId == variantId);
        if (idx != -1) {
          products[idx].stockQty = newBalance;
          products.refresh();
        }
      }

      Get.snackbar(
        'Stock Updated',
        newBalance != null
            ? 'New balance: $newBalance units.'
            : 'Inventory ledger updated successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );

      // Refresh history if open for this product
      if (selectedProductId.value == productId) {
        fetchProductHistory(productId, showLoading: false);
      }

      // Re-fetch low stock list in background
      fetchInventory(showLoading: false);
      return true;
    } else {
      // Error handling branching
      String errMsg = 'Could not update inventory.';
      if (_api.lastApiErrorCode == 'INSUFFICIENT_STOCK') {
        errMsg = 'Insufficient stock! The change would take stock below 0.';
      } else if (_api.lastApiError != null && _api.lastApiError!.isNotEmpty) {
        errMsg = _api.lastApiError!;
      }

      Get.snackbar(
        'Adjustment Failed',
        errMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }
  }
}
