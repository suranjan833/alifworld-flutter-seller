import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/api_service.dart';
import '../../../../data/theme/app_colors.dart';
import '../widgets/delivery_otp_dialog.dart';
import '../widgets/reject_order_dialog.dart';

class OrderDetailController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  late final String orderId;
  final isLoading = true.obs;
  final isActionLoading = false.obs;
  final order = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      orderId = (args['orderId'] ?? args['id'] ?? '').toString();
      if (args['order'] is Map<String, dynamic>) {
        order.value = args['order'] as Map<String, dynamic>;
        isLoading.value = false;
      }
    } else if (Get.parameters.containsKey('id')) {
      orderId = Get.parameters['id'] ?? '';
    } else {
      orderId = '';
    }

    if (orderId.isNotEmpty) {
      fetchOrderDetail();
    }
  }

  Future<void> fetchOrderDetail() async {
    if (order.value == null) {
      isLoading.value = true;
    }
    try {
      final res = await _api.getOrderDetail(orderId);
      if (res != null) {
        order.value = res;
      }
    } catch (e) {
      log('Error fetching order detail: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // --- Getters for clean view binding ---
  String get orderNumber =>
      order.value?['orderNumber']?.toString() ??
      order.value?['code']?.toString() ??
      orderId;

  String get status => order.value?['status']?.toString().toLowerCase() ?? 'pending';

  bool get isOpenBoxDelivery {
    final v = order.value?['openBoxDelivery'] ??
        order.value?['isOpenBoxDelivery'] ??
        order.value?['is_open_box_delivery'];
    return v == true || v == 1;
  }

  String get batchNumber {
    final batch = order.value?['batch'] as Map<String, dynamic>?;
    return batch?['batchNumber']?.toString() ??
        order.value?['batchNumber']?.toString() ??
        'BATCH-N/A';
  }

  String get paymentMethod {
    final batch = order.value?['batch'] as Map<String, dynamic>?;
    return batch?['paymentMethod']?.toString() ??
        order.value?['paymentMethod']?.toString() ??
        'COD';
  }

  String get paymentStatus {
    final batch = order.value?['batch'] as Map<String, dynamic>?;
    return batch?['paymentStatus']?.toString() ??
        order.value?['paymentStatus']?.toString() ??
        'cod_pending';
  }

  String get customerName {
    final customer = order.value?['customer'] as Map<String, dynamic>?;
    return customer?['name']?.toString() ??
        order.value?['customerName']?.toString() ??
        'Customer';
  }

  String get customerPhone {
    final customer = order.value?['customer'] as Map<String, dynamic>?;
    return customer?['phone']?.toString() ??
        order.value?['customerPhone']?.toString() ??
        '';
  }

  String get customerEmail {
    final customer = order.value?['customer'] as Map<String, dynamic>?;
    return customer?['email']?.toString() ??
        order.value?['customerEmail']?.toString() ??
        '';
  }

  String get deliveryAddress {
    final snapshot = order.value?['addressSnapshot'];
    if (snapshot is Map<String, dynamic>) {
      final parts = <String>[];
      if (snapshot['name'] != null) parts.add(snapshot['name'].toString());
      if (snapshot['phone'] != null) parts.add(snapshot['phone'].toString());
      if (snapshot['addressLine1'] != null) parts.add(snapshot['addressLine1'].toString());
      if (snapshot['addressLine2'] != null) parts.add(snapshot['addressLine2'].toString());
      if (snapshot['landmark'] != null) parts.add(snapshot['landmark'].toString());
      if (snapshot['city'] != null) parts.add(snapshot['city'].toString());
      if (snapshot['district'] != null) parts.add(snapshot['district'].toString());
      if (snapshot['postalCode'] != null) parts.add(snapshot['postalCode'].toString());
      if (parts.isNotEmpty) return parts.join(', ');
    } else if (snapshot is String && snapshot.isNotEmpty) {
      return snapshot;
    }
    return order.value?['shippingAddress']?.toString() ??
        order.value?['deliveryAddress']?.toString() ??
        'Address not specified';
  }

  double _parseTakaAmount(dynamic minorVal, dynamic directVal) {
    if (minorVal != null) {
      final n = minorVal is num ? minorVal.toDouble() : double.tryParse(minorVal.toString());
      if (n != null && !n.isNaN && !n.isInfinite) {
        return n / 100.0;
      }
    }
    if (directVal != null) {
      final n = directVal is num ? directVal.toDouble() : double.tryParse(directVal.toString());
      if (n != null && !n.isNaN && !n.isInfinite) {
        return n;
      }
    }
    return 0.0;
  }

  double get subtotalTaka => _parseTakaAmount(order.value?['subtotalMinor'], order.value?['subtotal']);
  double get shippingTaka => _parseTakaAmount(order.value?['shippingMinor'], order.value?['shippingFee'] ?? order.value?['shipping']);
  double get discountTaka => _parseTakaAmount(order.value?['discountMinor'], order.value?['discount']);
  double get totalTaka {
    final t = _parseTakaAmount(order.value?['totalMinor'], order.value?['total']);
    if (t > 0) return t;
    final calculated = subtotalTaka + shippingTaka - discountTaka;
    return calculated > 0 ? calculated : 0.0;
  }

  List<Map<String, dynamic>> get items {
    final raw = (order.value?['items'] as List<dynamic>?) ?? [];
    return raw.whereType<Map<String, dynamic>>().toList();
  }

  List<Map<String, dynamic>> get timeline {
    final raw = (order.value?['timeline'] as List<dynamic>?) ?? [];
    return raw.whereType<Map<String, dynamic>>().toList();
  }

  List<String> get allowedActions {
    final raw = (order.value?['allowedActions'] as List<dynamic>?) ?? [];
    if (raw.isNotEmpty) {
      return raw.map((e) => e.toString().toLowerCase()).toList();
    }
    // Fallback status machine according to section 7.3:
    // pending -> confirmed, cancelled
    // confirmed -> packed, cancelled
    // packed -> handed_over, cancelled
    // handed_over -> out_for_delivery
    // out_for_delivery -> delivered
    switch (status) {
      case 'pending':
        return ['confirmed', 'cancelled'];
      case 'confirmed':
        return ['packed', 'cancelled'];
      case 'packed':
        return ['handed_over', 'cancelled'];
      case 'handed_over':
        return ['out_for_delivery'];
      case 'out_for_delivery':
        return ['delivered'];
      default:
        return [];
    }
  }

  // --- Status Actions ---

  Future<void> acceptOrder() async {
    await performStatusChange(
      status: 'confirmed',
      note: 'Order accepted by seller',
      successMessage: 'Order confirmed successfully',
    );
  }

  void promptRejectOrder(BuildContext context) {
    RejectOrderDialog.show(
      context,
      onConfirm: (reason) {
        performStatusChange(
          status: 'cancelled',
          reason: reason,
          successMessage: 'Order rejected',
        );
      },
    );
  }

  Future<void> packOrder() async {
    await performStatusChange(
      status: 'packed',
      note: 'Items packed and ready for dispatch',
      successMessage: 'Order marked as packed',
    );
  }

  Future<void> handOverOrder() async {
    await performStatusChange(
      status: 'handed_over',
      note: 'Handed over to delivery partner',
      successMessage: 'Order handed over',
    );
  }

  Future<void> markOutForDelivery() async {
    await performStatusChange(
      status: 'out_for_delivery',
      note: 'Out for delivery to customer',
      successMessage: 'Order marked as out for delivery',
    );
  }

  void promptDeliverOrder(BuildContext context) {
    DeliveryOtpDialog.show(
      context,
      onConfirm: (otp) {
        performStatusChange(
          status: 'delivered',
          otpCode: otp,
          photoUrl: 'https://cdn.alifworld.com.bd/delivery/handover-confirmed.jpg',
          successMessage: 'Order delivered successfully',
        );
      },
    );
  }

  Future<void> performStatusChange({
    required String status,
    String? note,
    String? reason,
    String? otpCode,
    String? photoUrl,
    String? successMessage,
  }) async {
    isActionLoading.value = true;
    try {
      final payload = <String, dynamic>{'status': status};
      if (note != null && note.isNotEmpty) payload['note'] = note;
      if (reason != null && reason.isNotEmpty) payload['reason'] = reason;
      if (otpCode != null && otpCode.isNotEmpty) payload['otpCode'] = otpCode;
      if (photoUrl != null && photoUrl.isNotEmpty) payload['photoUrl'] = photoUrl;

      final res = await _api.updateOrderStatus(orderId, payload);
      if (res['success'] == true) {
        // Optimistically update order status and append timeline for instantaneous UI update
        if (order.value != null) {
          final updated = Map<String, dynamic>.from(order.value!);
          updated['status'] = status;
          final currentTimeline = List<Map<String, dynamic>>.from(
            (updated['timeline'] as List<dynamic>?)?.whereType<Map<String, dynamic>>() ?? [],
          );
          currentTimeline.insert(0, {
            'status': status,
            'note': note ?? reason ?? 'Status changed to $status',
            'createdAt': DateTime.now().toIso8601String(),
          });
          updated['timeline'] = currentTimeline;
          order.value = updated;
        }

        Get.snackbar(
          'Success',
          successMessage ?? 'Status updated to $status',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        await fetchOrderDetail();
      } else {
        Get.snackbar(
          'Action Failed',
          res['message']?.toString() ?? 'Could not update order status',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isActionLoading.value = false;
    }
  }
}

