import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../data/theme/app_colors.dart';
import '../../../data/widgets/shimmer_widget.dart';
import '../../../routes/app_pages.dart';
import '../controllers/orders_page_controller.dart';

class OrdersSheet extends GetView<OrdersPageController> {
  const OrdersSheet({super.key});

  static Future<void> show(BuildContext context) {
    if (!Get.isRegistered<OrdersPageController>()) {
      Get.put(OrdersPageController());
    }
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const OrdersSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersCtrl = Get.isRegistered<OrdersPageController>()
        ? controller
        : Get.put(OrdersPageController());

    return Container(
      height: 0.88.sh,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // Drag handle
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 12.h),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.truck_fast,
                    color: const Color(0xFF3B82F6),
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Orders',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Track and fulfill customer orders',
                        style: GoogleFonts.inter(
                          fontSize: 11.5.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Iconsax.refresh, size: 20),
                  onPressed: ordersCtrl.fetchOrders,
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),

          // Summary Metric Strip
          Obx(() {
            final summary = ordersCtrl.summary.value;
            if (summary == null) return const SizedBox.shrink();
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricCol(
                    'Total Orders',
                    '${summary['totalCount'] ?? 0}',
                    Iconsax.box,
                    AppColors.primary,
                  ),
                  Container(width: 1, height: 26.h, color: AppColors.border),
                  _buildMetricCol(
                    'Revenue',
                    '৳${((summary['totalRevenueMinor'] ?? 0) / 100).toStringAsFixed(0)}',
                    Iconsax.moneys,
                    AppColors.success,
                  ),
                ],
              ),
            );
          }),

          // Filter Tab Bar
          SizedBox(height: 6.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Obx(
              () => Row(
                children: ordersCtrl.statusTabs.map((tab) {
                  final isSelected = ordersCtrl.selectedFilter.value == tab['value'];
                  final count = ordersCtrl.getStatusCount(tab['value']!);

                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tab['label']!,
                            style: GoogleFonts.inter(
                              fontSize: tab['value'] == 'out_for_delivery'
                                  ? 11.sp
                                  : 12.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 1.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.25)
                                  : (count > 0
                                      ? const Color(0xFFF1F5F9)
                                      : const Color(0xFFF8FAFC)),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              '$count',
                              style: GoogleFonts.inter(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : (count > 0
                                        ? AppColors.textPrimary
                                        : AppColors.textMuted),
                              ),
                            ),
                          ),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (_) => ordersCtrl.changeFilter(tab['value']!),
                      selectedColor: AppColors.primary,
                      labelStyle: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // Orders List
          Expanded(
            child: Obx(() {
              if (ordersCtrl.isLoading.value) {
                return const OrderListShimmer();
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: ordersCtrl.fetchOrders,
                child: ordersCtrl.orders.isEmpty
                    ? LayoutBuilder(
                        builder: (context, constraints) => SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: _buildEmptyState(),
                          ),
                        ),
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 20.h),
                        itemCount: ordersCtrl.orders.length,
                        separatorBuilder: (_, _) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final order =
                              ordersCtrl.orders[index] as Map<String, dynamic>;
                          return _buildOrderCard(order, ordersCtrl);
                        },
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: color),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                color: AppColors.textMuted,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.box_remove, size: 48.sp, color: AppColors.textMuted),
          SizedBox(height: 12.h),
          Text(
            'No orders found',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Orders matching this status will appear here.',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
      Map<String, dynamic> order, OrdersPageController ordersCtrl) {
    final orderId = order['id']?.toString() ?? '';
    final orderNum = order['orderNumber']?.toString() ?? 'ORD-000';
    final status = order['status']?.toString() ?? 'pending';
    final statusColor = ordersCtrl.getStatusColor(status);
    final totalMinor = (order['totalMinor'] as num?)?.toDouble() ?? 0;
    final totalTaka = (totalMinor / 100).toStringAsFixed(2);
    final itemCount = order['itemCount']?.toString() ?? '1';
    final customer = order['customer'] as Map<String, dynamic>?;
    final customerName = customer?['name']?.toString() ?? 'Customer';
    final customerPhone = customer?['phone']?.toString() ?? '';
    final batch = order['batch'] as Map<String, dynamic>?;
    final paymentMethod =
        batch?['paymentMethod']?.toString().toUpperCase() ?? 'COD';

    void navigateToDetail() {
      Get.toNamed(
        Routes.ORDER_DETAIL,
        arguments: {'orderId': orderId, 'order': order},
      )?.then((_) => ordersCtrl.fetchOrders());
    }

    return GestureDetector(
      onTap: navigateToDetail,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    orderNum,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        status.toUpperCase().replaceAll('_', ' '),
                        style: GoogleFonts.inter(
                          fontSize: status.toLowerCase().contains('out_for_delivery') ? 9.sp : 10.5.sp,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: const Color(0xFFFFEDD5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.eye,
                            size: 13.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'View',
                            style: GoogleFonts.inter(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Iconsax.user, size: 14.sp, color: AppColors.textMuted),
                SizedBox(width: 6.w),
                Text(
                  customerName,
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (customerPhone.isNotEmpty) ...[
                  const Text(' • ', style: TextStyle(color: AppColors.textMuted)),
                  Text(
                    customerPhone,
                    style: GoogleFonts.inter(
                      fontSize: 11.5.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 8.h),
            const Divider(height: 1, color: AppColors.divider),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        paymentMethod,
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '$itemCount item(s)',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Text(
                  '৳$totalTaka',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
