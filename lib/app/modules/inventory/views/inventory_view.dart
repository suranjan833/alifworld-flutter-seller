import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../data/models/inventory_model.dart';
import '../../../data/theme/app_colors.dart';
import '../../../data/widgets/shimmer_widget.dart';
import '../controllers/inventory_controller.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: AppColors.textPrimary, size: 22),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Inventory & Stock',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, color: AppColors.textPrimary, size: 20),
            onPressed: () {
              if (controller.selectedTab.value == 0) {
                controller.fetchInventory();
              } else if (controller.selectedProductId.isNotEmpty) {
                controller.fetchProductHistory(controller.selectedProductId.value);
              }
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          // Segmented Tab Selector
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Obx(
              () => Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSegmentButton(
                        label: 'Low Stock Alerts',
                        badgeCount: controller.products.length,
                        isSelected: controller.selectedTab.value == 0,
                        onTap: () => controller.selectedTab.value = 0,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: _buildSegmentButton(
                        label: 'Stock Ledger',
                        isSelected: controller.selectedTab.value == 1,
                        onTap: () => controller.selectedTab.value = 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Tab View Body
          Expanded(
            child: Obx(() {
              if (controller.selectedTab.value == 0) {
                return _buildLowStockTab(context);
              } else {
                return _buildHistoryTab(context);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    int? badgeCount,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 9.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.5.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
              ),
            ),
            if (badgeCount != null && badgeCount > 0) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEF4444) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$badgeCount',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- TAB 1: LOW STOCK ALERTS ---
  Widget _buildLowStockTab(BuildContext context) {
    if (controller.isLoading.value) {
      return const InventoryListShimmer();
    }

    if (controller.products.isEmpty) {
      return ShimmerPullToRefresh(
        onRefresh: controller.fetchInventory,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 100.h),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(18.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFFECFDF5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Iconsax.box_tick, size: 48.sp, color: const Color(0xFF10B981)),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'All items are in healthy stock',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'No low stock warnings at this moment.\nPull down to refresh anytime.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12.5.sp,
                      color: const Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return ShimmerPullToRefresh(
      onRefresh: controller.fetchInventory,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        itemCount: controller.products.length + (controller.nextCursor != null ? 1 : 0),
        separatorBuilder: (_, _) => SizedBox(height: 10.h),
        itemBuilder: (context, index) {
          if (index == controller.products.length) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: TextButton.icon(
                  onPressed: controller.loadMoreInventory,
                  icon: const Icon(Iconsax.arrow_down_1, size: 16),
                  label: Text(
                    controller.isLoadingMore.value ? 'Loading more...' : 'Load more items',
                    style: GoogleFonts.inter(fontSize: 12.5.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            );
          }

          final item = controller.products[index];
          return Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: const Icon(Iconsax.warning_2, color: Color(0xFFEF4444), size: 22),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Variant: ${item.variantLabel.isNotEmpty ? item.variantLabel : "Default"} • SKU: ${item.sku}',
                            style: GoogleFonts.inter(
                              fontSize: 11.5.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  'Current: ${item.stockQty}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFB91C1C),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Threshold: ≤ ${item.lowStockThreshold}',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5.sp,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                SizedBox(height: 10.h),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      ),
                      onPressed: () {
                        controller.fetchProductHistory(
                          item.productId,
                          productName: item.productName,
                        );
                        controller.selectedTab.value = 1;
                      },
                      icon: const Icon(Iconsax.clock, size: 16, color: Color(0xFF64748B)),
                      label: Text(
                        'History',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF630F),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9.r),
                        ),
                      ),
                      onPressed: () => _showAdjustStockSheet(context, item),
                      icon: const Icon(Iconsax.edit, size: 15, color: Colors.white),
                      label: Text(
                        'Adjust Stock',
                        style: GoogleFonts.inter(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- TAB 2: STOCK LEDGER HISTORY ---
  Widget _buildHistoryTab(BuildContext context) {
    if (controller.selectedProductId.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(18.w),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.document_text, size: 40, color: Color(0xFF64748B)),
              ),
              SizedBox(height: 14.h),
              Text(
                'No Product Selected',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Tap "History" on any low stock item to view its complete chronological ledger movement.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (controller.isLoadingHistory.value) {
      return const InventoryListShimmer();
    }

    return Column(
      children: [
        // Product Banner
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          color: const Color(0xFFF8FAFC),
          child: Row(
            children: [
              const Icon(Iconsax.box_tick, size: 18, color: Color(0xFFFF630F)),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Ledger: ${controller.selectedProductName.value}',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => controller.fetchProductHistory(
                  controller.selectedProductId.value,
                  productName: controller.selectedProductName.value,
                ),
                child: Text(
                  'Refresh',
                  style: GoogleFonts.inter(fontSize: 11.5.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        Expanded(
          child: controller.historyEntries.isEmpty
              ? Center(
                  child: Text(
                    'No stock ledger movements recorded.',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  itemCount: controller.historyEntries.length +
                      (controller.historyNextCursor != null ? 1 : 0),
                  separatorBuilder: (_, _) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    if (index == controller.historyEntries.length) {
                      return Center(
                        child: TextButton.icon(
                          onPressed: controller.loadMoreHistory,
                          icon: const Icon(Iconsax.arrow_down_1, size: 16),
                          label: Text(
                            controller.isLoadingMoreHistory.value
                                ? 'Loading...'
                                : 'Load older ledger records',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }

                    final entry = controller.historyEntries[index];
                    final isPositive = entry.changeQty > 0;
                    final isNegative = entry.changeQty < 0;

                    final color = isPositive
                        ? const Color(0xFF10B981)
                        : (isNegative ? const Color(0xFFEF4444) : const Color(0xFF64748B));

                    final signStr = isPositive ? '+${entry.changeQty}' : '${entry.changeQty}';

                    final dateStr = entry.createdAt != null
                        ? _formatDate(entry.createdAt!.toLocal())
                        : '—';

                    return Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Kind badge
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  entry.kind.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              // Reference source
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  entry.referenceType,
                                  style: GoogleFonts.inter(
                                    fontSize: 10.sp,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Change quantity
                              Text(
                                signStr,
                                style: GoogleFonts.inter(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w800,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Variant: ${entry.variantLabel.isNotEmpty ? entry.variantLabel : entry.variantSku}',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF334155),
                                ),
                              ),
                              // Resulting balance
                              Text(
                                'Balance: ${entry.balanceQty}',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          if (entry.note != null && entry.note!.trim().isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              'Note: ${entry.note}',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                          SizedBox(height: 4.h),
                          Text(
                            dateStr,
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$day $month, $year  $hour:$minute $amPm';
  }

  // --- ADJUST STOCK SHEET (Zero StatefulWidget, adheres to commit 60c5a25) ---
  void _showAdjustStockSheet(BuildContext context, InventoryProductModel item) {
    final qtyCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    // Default kind to 'in'
    controller.adjustKind.value = 'in';
    controller.adjustQty.value = 0;
    controller.adjustNote.value = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          20.w,
          16.h,
          20.w,
          MediaQuery.of(context).viewInsets.bottom + 20.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adjust Stock',
                          style: GoogleFonts.inter(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${item.productName} • Current: ${item.stockQty} units',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              // Mode Selection Chips (In, Out, Adjustment)
              Obx(
                () => Row(
                  children: [
                    _buildKindChip(
                      label: 'Stock In (+)',
                      selected: controller.adjustKind.value == 'in',
                      color: const Color(0xFF10B981),
                      onTap: () => controller.adjustKind.value = 'in',
                    ),
                    SizedBox(width: 8.w),
                    _buildKindChip(
                      label: 'Stock Out (-)',
                      selected: controller.adjustKind.value == 'out',
                      color: const Color(0xFFEF4444),
                      onTap: () => controller.adjustKind.value = 'out',
                    ),
                    SizedBox(width: 8.w),
                    _buildKindChip(
                      label: 'Audit (±)',
                      selected: controller.adjustKind.value == 'adjustment',
                      color: const Color(0xFF3B82F6),
                      onTap: () => controller.adjustKind.value = 'adjustment',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),

              // Quantity Input
              Obx(() {
                final isAdjustment = controller.adjustKind.value == 'adjustment';
                final isOut = controller.adjustKind.value == 'out';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAdjustment
                          ? 'Signed Delta (e.g. +5 or -10)'
                          : (isOut ? 'Quantity to Remove (Magnitude)' : 'Quantity to Add (Magnitude)'),
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    TextField(
                      controller: qtyCtrl,
                      keyboardType: const TextInputType.numberWithOptions(signed: true),
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: isAdjustment ? 'e.g. -2 or +15' : 'e.g. 10',
                        hintStyle: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        prefixIcon: const Icon(Iconsax.box, size: 18, color: Color(0xFF64748B)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(color: Color(0xFFFF630F), width: 1.5),
                        ),
                      ),
                      onChanged: (val) {
                        final parsed = int.tryParse(val.trim()) ?? 0;
                        controller.adjustQty.value = parsed;
                      },
                    ),
                  ],
                );
              }),
              SizedBox(height: 10.h),

              // Note Input
              Text(
                'Note / Reason (optional)',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
              SizedBox(height: 6.h),
              TextField(
                controller: noteCtrl,
                style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: 'e.g. Received new shipment, Damaged, Stock count audit',
                  hintStyle: GoogleFonts.inter(fontSize: 12.5.sp, color: const Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  prefixIcon: const Icon(Iconsax.document_text, size: 18, color: Color(0xFF64748B)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: Color(0xFFFF630F), width: 1.5),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Live Stock Preview Calculation
              Obx(() {
                final kind = controller.adjustKind.value;
                final qty = controller.adjustQty.value;
                int previewBalance = item.stockQty;

                if (kind == 'in') {
                  previewBalance += qty.abs();
                } else if (kind == 'out') {
                  previewBalance -= qty.abs();
                } else {
                  previewBalance += qty;
                }

                final isNegative = previewBalance < 0;

                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isNegative ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isNegative ? const Color(0xFFFCA5A5) : const Color(0xFFBBF7D0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isNegative ? Iconsax.warning_2 : Iconsax.tick_circle,
                        size: 16,
                        color: isNegative ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          isNegative
                              ? 'Resulting stock ($previewBalance) cannot be negative!'
                              : 'Projected Stock: ${item.stockQty} → $previewBalance units',
                          style: GoogleFonts.inter(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w600,
                            color: isNegative ? const Color(0xFFDC2626) : const Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(height: 18.h),

              // Submit Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF630F),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    onPressed: controller.isAdjusting.value
                        ? null
                        : () async {
                            final rawQty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
                            if (rawQty == 0) {
                              Get.snackbar(
                                'Invalid Quantity',
                                'Please enter a non-zero quantity.',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            final success = await controller.adjustStock(
                              productId: item.productId,
                              variantId: item.variantId,
                              changeQty: rawQty,
                              kind: controller.adjustKind.value,
                              note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                            );

                            if (success && ctx.mounted) {
                              Navigator.pop(ctx);
                            }
                          },
                    child: controller.isAdjusting.value
                        ? const ShimmerBox(width: 120, height: 16)
                        : Text(
                            'Save Stock Movement',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKindChip({
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.12) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: selected ? color : const Color(0xFFE2E8F0),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.5.sp,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? color : const Color(0xFF475569),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
