import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../data/theme/app_colors.dart';
import '../../../../data/widgets/shimmer_widget.dart';
import '../controllers/order_detail_controller.dart';

class OrderDetailView extends GetView<OrderDetailController> {
  const OrderDetailView({super.key});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return const Color(0xFF10B981); // Emerald Green
      case 'pending':
        return const Color(0xFFFF630F); // Primary Orange
      case 'confirmed':
        return const Color(0xFF2563EB); // Royal Blue
      case 'packed':
        return const Color(0xFF0284C7); // Sky Blue
      case 'handed_over':
        return const Color(0xFF0D9488); // Teal
      case 'out_for_delivery':
        return const Color(0xFF7C3AED); // Purple
      case 'cancelled':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF64748B);
    }
  }

  int _getStatusStepIndex(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'confirmed':
        return 1;
      case 'packed':
        return 2;
      case 'handed_over':
        return 3;
      case 'out_for_delivery':
        return 4;
      case 'delivered':
        return 5;
      default:
        return -1;
    }
  }

  String _formatDateTime(dynamic dt) {
    if (dt == null) return '';
    final str = dt.toString();
    final parsed = DateTime.tryParse(str);
    if (parsed != null) {
      final local = parsed.toLocal();
      final month = local.month.toString().padLeft(2, '0');
      final day = local.day.toString().padLeft(2, '0');
      final year = local.year.toString();

      int hour = local.hour;
      final ampm = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      final hourStr = hour.toString().padLeft(2, '0');
      final min = local.minute.toString().padLeft(2, '0');
      final sec = local.second.toString().padLeft(2, '0');

      return '$month/$day/$year, $hourStr:$min:$sec $ampm';
    }
    return str;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value && controller.order.value == null) {
          return const OrderDetailShimmer();
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.fetchOrderDetail,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Order Number & Status Header
                _buildHeaderCard(),

                SizedBox(height: 12.h),

                // 2. Step-by-Step Fulfillment Stepper
                _buildFulfillmentStepper(),

                SizedBox(height: 12.h),

                // 3. Dynamic Next Action Card (Pending -> Accept -> Pack -> Hand over -> Out for delivery -> Delivered)
                _buildNextActionCard(context),

                SizedBox(height: 14.h),

                // 4. Fulfillment Timeline (Exact sequence matching user's screenshot)
                _buildTimelineCard(),

                SizedBox(height: 14.h),

                // 5. Order Information
                _buildOrderInfoCard(),

                SizedBox(height: 12.h),

                // 6. Customer Details
                _buildCustomerCard(),

                SizedBox(height: 12.h),

                // 7. Delivery Address
                _buildDeliveryAddressCard(),

                SizedBox(height: 12.h),

                // 8. Total & Billing Calculation
                _buildTotalBreakdownCard(),

                SizedBox(height: 14.h),

                // 9. Ordered Items Table
                _buildItemsCard(),

                SizedBox(height: 36.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.textPrimary,
          size: 20,
        ),
        onPressed: () => Get.back(),
      ),
      titleSpacing: 0,
      title: Text(
        'Order Fulfillment',
        style: GoogleFonts.inter(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(
            Iconsax.refresh,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onPressed: controller.fetchOrderDetail,
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildHeaderCard() {
    final status = controller.status;
    final statusColor = _getStatusColor(status);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  controller.orderNumber,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  status.toUpperCase().replaceAll('_', ' '),
                  style: GoogleFonts.inter(
                    fontSize: status.toLowerCase().contains('out_for_delivery')
                        ? 9.5.sp
                        : 11.sp,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (controller.isOpenBoxDelivery) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.box_1, size: 13, color: Color(0xFF2563EB)),
                  SizedBox(width: 4.w),
                  Text(
                    'Open Box Delivery',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1D4ED8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- Step-by-Step Fulfillment Stepper ---
  Widget _buildFulfillmentStepper() {
    final currentStep = _getStatusStepIndex(controller.status);
    final isCancelled = controller.status == 'cancelled';

    final steps = [
      {'label': 'Pending', 'icon': Iconsax.clock},
      {'label': 'Confirmed', 'icon': Iconsax.verify},
      {'label': 'Packed', 'icon': Iconsax.box},
      {'label': 'Handed over', 'icon': Iconsax.truck_fast},
      {'label': 'Out for delivery', 'icon': Iconsax.routing},
      {'label': 'Delivered', 'icon': Icons.check_circle_rounded},
    ];

    if (isCancelled) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cancel,
                color: Color(0xFFDC2626),
                size: 20,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Cancelled',
                    style: GoogleFonts.inter(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF991B1B),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'This order was cancelled or rejected and will not be processed further.',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: const Color(0xFFB91C1C),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fulfillment Progress',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                currentStep >= 0 && currentStep <= 5
                    ? 'Step ${currentStep + 1} of 6'
                    : 'In Progress',
                style: GoogleFonts.inter(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          // Horizontal Step indicators
          Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isOdd) {
                final stepBefore = index ~/ 2;
                final isPassed = currentStep > stepBefore;
                return Expanded(
                  child: Container(
                    height: 3.h,
                    color: isPassed
                        ? const Color(0xFF10B981)
                        : const Color(0xFFE2E8F0),
                  ),
                );
              }

              final stepIdx = index ~/ 2;
              final isPassed = currentStep > stepIdx;
              final isCurrent = currentStep == stepIdx;

              Color circleBg;
              Color iconColor;
              Widget iconWidget;

              if (isPassed) {
                circleBg = const Color(0xFF10B981);
                iconColor = Colors.white;
                iconWidget = Icon(Icons.check, size: 12.sp, color: iconColor);
              } else if (isCurrent) {
                circleBg = const Color(0xFFFF630F);
                iconColor = Colors.white;
                iconWidget = Icon(
                  steps[stepIdx]['icon'] as IconData,
                  size: 12.sp,
                  color: iconColor,
                );
              } else {
                circleBg = const Color(0xFFF1F5F9);
                iconColor = const Color(0xFF94A3B8);
                iconWidget = Text(
                  '${stepIdx + 1}',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 26.w,
                    height: 26.w,
                    decoration: BoxDecoration(
                      color: circleBg,
                      shape: BoxShape.circle,
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFF630F)
                                    .withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(child: iconWidget),
                  ),
                ],
              );
            }),
          ),
          SizedBox(height: 10.h),
          // Step names row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pending',
                style: GoogleFonts.inter(
                  fontSize: 9.5.sp,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                'Confirmed',
                style: GoogleFonts.inter(
                  fontSize: 9.5.sp,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                'Packed',
                style: GoogleFonts.inter(
                  fontSize: 9.5.sp,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                'Handed Over',
                style: GoogleFonts.inter(
                  fontSize: 9.5.sp,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                'Out for Del.',
                style: GoogleFonts.inter(
                  fontSize: 8.5.sp,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                'Delivered',
                style: GoogleFonts.inter(
                  fontSize: 9.5.sp,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Dynamic Next Action Card (One button at a time flow) ---
  Widget _buildNextActionCard(BuildContext context) {
    final status = controller.status;
    final isLoading = controller.isActionLoading.value;

    if (isLoading) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12),
              Text('Updating order status...'),
            ],
          ),
        ),
      );
    }

    // 1. PENDING: Accept order / Reject
    if (status == 'pending') {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFFFEDD5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Iconsax.info_circle,
                  color: Color(0xFFFF630F),
                  size: 18,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Action Required: New Order',
                  style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF9A3412),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              'Accept this order to confirm stock availability and proceed to packing.',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: const Color(0xFFC2410C),
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Accept order',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF630F),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      elevation: 0,
                    ),
                    onPressed: controller.acceptOrder,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    onPressed: () => controller.promptRejectOrder(context),
                    child: Text(
                      'Reject',
                      style: GoogleFonts.inter(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // 2. CONFIRMED: Pack Order
    if (status == 'confirmed') {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Iconsax.box, color: Color(0xFF2563EB), size: 18),
                SizedBox(width: 6.w),
                Text(
                  'Step 2: Pack Items',
                  style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E40AF),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              'Order is confirmed. Prepare the parcel and label it before handoff.',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: const Color(0xFF1D4ED8),
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Iconsax.box_tick,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Pack Order',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      elevation: 0,
                    ),
                    onPressed: controller.packOrder,
                  ),
                ),
                SizedBox(width: 10.w),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: 12.h,
                      horizontal: 14.w,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  onPressed: () => controller.promptRejectOrder(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // 3. PACKED: Hand over to courier / rider
    if (status == 'packed') {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Iconsax.truck_fast,
                  color: Color(0xFF059669),
                  size: 18,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Step 3: Courier Handover',
                  style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF065F46),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              'Items are packed. Click below once you hand the package to the courier or rider.',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: const Color(0xFF047857),
              ),
            ),
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Iconsax.export_1,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  'Hand Over to Courier',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  elevation: 0,
                ),
                onPressed: controller.handOverOrder,
              ),
            ),
          ],
        ),
      );
    }

    // 4. HANDED OVER: Out for delivery
    if (status == 'handed_over') {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3FF),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFDDD6FE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Iconsax.routing, color: Color(0xFF7C3AED), size: 18),
                SizedBox(width: 6.w),
                Text(
                  'Step 4: Transit Dispatch',
                  style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5B21B6),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              'Package is with courier. When the delivery rider is on the way to the customer:',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: const Color(0xFF6D28D9),
              ),
            ),
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Iconsax.direct_send,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  'Mark Out for Delivery',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  elevation: 0,
                ),
                onPressed: controller.markOutForDelivery,
              ),
            ),
          ],
        ),
      );
    }

    // 5. OUT FOR DELIVERY: Complete Delivery
    if (status == 'out_for_delivery') {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Iconsax.location_tick,
                  color: Color(0xFF16A34A),
                  size: 18,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Final Step: Complete Delivery',
                  style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF15803D),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              'Rider has reached the destination. Verify delivery OTP to complete handover.',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: const Color(0xFF166534),
              ),
            ),
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  'Complete Delivery',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  elevation: 0,
                ),
                onPressed: () => controller.promptDeliverOrder(context),
              ),
            ),
          ],
        ),
      );
    }

    // 6. DELIVERED
    if (status == 'delivered') {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified,
                color: Color(0xFF16A34A),
                size: 22,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Fully Delivered',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF14532D),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Customer received the package and fulfillment is complete.',
                    style: GoogleFonts.inter(
                      fontSize: 11.5.sp,
                      color: const Color(0xFF166534),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // --- Timeline Card (Sequence matching user's screenshot) ---
  Widget _buildTimelineCard() {
    final timeline = controller.timeline;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.clock, size: 17, color: Color(0xFF475569)),
              SizedBox(width: 8.w),
              Text(
                'Timeline',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          if (timeline.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                children: [
                  Text(
                    controller.status.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: timeline.length,
              itemBuilder: (context, index) {
                final entry = timeline[index];
                final statusStr = (entry['status'] ?? 'UPDATE')
                    .toString()
                    .toLowerCase();
                final formattedStatus = statusStr == 'handed_over'
                    ? 'Handed over'
                    : statusStr == 'out_for_delivery'
                    ? 'Out for delivery'
                    : statusStr.capitalizeFirst ?? statusStr;

                final rawDate = entry['createdAt'] ?? entry['date'];
                final formattedDate = _formatDateTime(rawDate);
                final note = entry['note']?.toString() ?? '';
                final isLast = index == timeline.length - 1;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline node + connector line
                      Column(
                        children: [
                          Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: BoxDecoration(
                              color: index == 0
                                  ? const Color(0xFFFF630F)
                                  : const Color(0xFF64748B),
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2.w,
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(width: 12.w),
                      // Content: Bold Status + Date Time
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 14.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '$formattedStatus ',
                                      style: GoogleFonts.inter(
                                        fontSize:
                                            formattedStatus
                                                .toLowerCase()
                                                .contains('out for delivery')
                                            ? 12.5.sp
                                            : 14.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    if (formattedDate.isNotEmpty)
                                      TextSpan(
                                        text: formattedDate,
                                        style: GoogleFonts.inter(
                                          fontSize: 12.5.sp,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF475569),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (note.isNotEmpty &&
                                  note.toLowerCase() != statusStr) ...[
                                SizedBox(height: 3.h),
                                Text(
                                  note,
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return _buildSectionCard(
      title: 'Order information',
      icon: Iconsax.info_circle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'BATCH: ',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: Text(
                  controller.batchNumber,
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Text(
                'Payment: ',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '${controller.paymentMethod} / ${controller.paymentStatus}',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard() {
    return _buildSectionCard(
      title: 'Customer',
      icon: Iconsax.user,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.customerName,
            style: GoogleFonts.inter(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.w,
            runSpacing: 4.h,
            children: [
              if (controller.customerPhone.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.phone, size: 13, color: Color(0xFF64748B)),
                    SizedBox(width: 4.w),
                    Text(
                      controller.customerPhone,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              if (controller.customerPhone.isNotEmpty &&
                  controller.customerEmail.isNotEmpty)
                Text('•', style: TextStyle(color: AppColors.textMuted)),
              if (controller.customerEmail.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 13,
                      color: Color(0xFF64748B),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      controller.customerEmail,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressCard() {
    return _buildSectionCard(
      title: 'Delivery address',
      icon: Iconsax.location,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              controller.deliveryAddress,
              style: GoogleFonts.inter(
                fontSize: 12.5.sp,
                height: 1.4,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBreakdownCard() {
    final sub = controller.subtotalTaka;
    final ship = controller.shippingTaka;
    final disc = controller.discountTaka;
    final tot = controller.totalTaka;

    return _buildSectionCard(
      title: 'Total Calculation',
      icon: Iconsax.wallet_money,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: GoogleFonts.inter(
                  fontSize: 12.5.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '৳${sub.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shipping fee',
                style: GoogleFonts.inter(
                  fontSize: 12.5.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '+৳${ship.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (disc > 0) ...[
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Discount',
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '-৳${disc.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Text(
                  'Formula: ',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${sub.toStringAsFixed(2)} + ${ship.toStringAsFixed(2)} - ${disc.toStringAsFixed(2)} = ${tot.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total',
                style: GoogleFonts.inter(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '৳${tot.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFF630F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard() {
    final items = controller.items;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Items (${items.length})',
            style: GoogleFonts.inter(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          // Table Header
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'ITEMS',
                    style: GoogleFonts.inter(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'QTY',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'UNIT PRICE',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'TOTAL',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          if (items.isEmpty)
            Padding(
              padding: EdgeInsets.all(12.h),
              child: Center(
                child: Text(
                  'No item details available',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final item = items[index];
                final name =
                    item['productName'] ??
                    item['name'] ??
                    item['title'] ??
                    'Product';
                final variant = item['variantLabel'] ?? item['variant'] ?? '';
                final qty = item['qty'] ?? item['quantity'] ?? 1;

                final unitMinor =
                    item['unitPriceMinor'] ?? item['unitPrice'] ?? 0;
                final unitTaka =
                    (unitMinor is num ? unitMinor.toDouble() : 0.0) /
                    (unitMinor is int && unitMinor >= 100 ? 100.0 : 1.0);

                final lineMinor =
                    item['lineTotalMinor'] ??
                    item['totalMinor'] ??
                    (unitTaka * (qty is num ? qty : 1) * 100);
                final lineTaka =
                    (lineMinor is num ? lineMinor.toDouble() : 0.0) /
                    (lineMinor is int && lineMinor >= 100 ? 100.0 : 1.0);

                return Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 10.h,
                    horizontal: 8.w,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.toString(),
                              maxLines: 2,
                              softWrap: true,
                              style: GoogleFonts.inter(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (variant.toString().isNotEmpty) ...[
                              SizedBox(height: 2.h),
                              Text(
                                variant.toString(),
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '$qty',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          '৳${unitTaka.toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          '৳${lineTaka.toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: const Color(0xFF64748B)),
              SizedBox(width: 6.w),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }
}
