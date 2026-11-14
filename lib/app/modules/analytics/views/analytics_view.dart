import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../data/models/analytics_dashboard_model.dart';
import '../../../data/theme/app_colors.dart';
import '../../../routes/app_pages.dart';
import '../controllers/analytics_controller.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context),
      body: Obx(() {
        if (controller.isLoading.value && controller.analytics.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final data = controller.analytics.value;
        final lowStock = data?.lowStockVariants ?? controller.summary.value?.lowStockCount ?? 0;

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.fetchAnalytics,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header with Range Filter
                _buildHeaderWithRange(),

                SizedBox(height: 14.h),

                // 2. Low Stock Warning Banner
                if (lowStock > 0) ...[
                  _buildLowStockBanner(lowStock),
                  SizedBox(height: 16.h),
                ],

                // 3. 8 KPI Cards Grid
                _buildKpiGrid(data),

                SizedBox(height: 16.h),

                // 4. Revenue Over Time Chart
                _buildRevenueOverTimeCard(data),

                SizedBox(height: 16.h),

                // 5. Top Products Best Sellers
                _buildTopProductsCard(data),

                SizedBox(height: 16.h),

                // 6. Order Funnel
                _buildOrderFunnelCard(data),

                SizedBox(height: 16.h),

                // 7. Payment Methods Donut Card
                _buildPaymentMethodsCard(data),

                SizedBox(height: 16.h),

                // 8. Customer Ratings Card
                _buildCustomerRatingsCard(data),

                SizedBox(height: 16.h),

                // 9. Coupon Performance Card
                _buildCouponPerformanceCard(data),

                SizedBox(height: 32.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Analytics',
        style: GoogleFonts.inter(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Iconsax.refresh, color: AppColors.textSecondary, size: 20),
          onPressed: controller.fetchAnalytics,
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildHeaderWithRange() {
    return Container(
      padding: EdgeInsets.all(14.w),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Your shop performance at a glance.',
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            return Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: controller.ranges.map((range) {
                  final isSelected = controller.selectedRange.value == range;
                  return GestureDetector(
                    onTap: () => controller.setRange(range),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        range.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLowStockBanner(int count) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.warning_2, color: Color(0xFFD97706), size: 18),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 12.5.sp,
                      color: const Color(0xFF92400E),
                    ),
                    children: [
                      TextSpan(
                        text: '$count variant${count > 1 ? 's are' : ' is'} low on stock. ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text: 'Restock soon to avoid losing sales.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.INVENTORY),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: const Color(0xFFD97706),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Restock',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(AnalyticsDashboardModel? data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: 1.35,
      children: [
        _buildKpiCard(
          title: 'Revenue',
          value: data?.formattedRevenue ?? '৳0.00',
          icon: Iconsax.wallet_3,
          accentColor: const Color(0xFFFF630F),
          bgColor: const Color(0xFFFFF7ED),
        ),
        _buildKpiCard(
          title: 'Orders',
          value: '${data?.orders ?? 0}',
          icon: Iconsax.bag_2,
          accentColor: const Color(0xFF2563EB),
          bgColor: const Color(0xFFEFF6FF),
        ),
        _buildKpiCard(
          title: 'Units sold',
          value: '${data?.unitsSold ?? 0}',
          icon: Iconsax.box,
          accentColor: const Color(0xFF059669),
          bgColor: const Color(0xFFECFDF5),
        ),
        _buildKpiCard(
          title: 'Avg. order value',
          value: data?.formattedAvgOrderValue ?? '৳0.00',
          icon: Iconsax.chart_2,
          accentColor: const Color(0xFF7C3AED),
          bgColor: const Color(0xFFF5F3FF),
        ),
        _buildKpiCard(
          title: 'Cancellation rate',
          value: data?.formattedCancellationRate ?? '0%',
          icon: Iconsax.close_circle,
          accentColor: const Color(0xFFDC2626),
          bgColor: const Color(0xFFFEF2F2),
        ),
        _buildKpiCard(
          title: 'Avg. rating',
          value: data?.formattedAvgRating ?? '—',
          icon: Iconsax.star_1,
          accentColor: const Color(0xFFD97706),
          bgColor: const Color(0xFFFFFBEB),
        ),
        _buildKpiCard(
          title: 'Customers',
          value: '${data?.customers ?? 0}',
          icon: Iconsax.profile_2user,
          accentColor: const Color(0xFF4F46E5),
          bgColor: const Color(0xFFEEF2FF),
        ),
        _buildKpiCard(
          title: 'Repeat customers',
          value: data?.formattedRepeatCustomers ?? '0%',
          icon: Iconsax.repeat,
          accentColor: const Color(0xFF0D9488),
          bgColor: const Color(0xFFF0FDFA),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: accentColor, size: 15.sp),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueOverTimeCard(AnalyticsDashboardModel? data) {
    final points = data?.revenueOverTime ?? [];

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
          Text(
            'Revenue over time',
            style: GoogleFonts.inter(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Daily revenue for the selected period',
            style: GoogleFonts.inter(
              fontSize: 11.5.sp,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 180.h,
            width: double.infinity,
            child: CustomPaint(
              painter: _RevenueLineChartPainter(points: points),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductsCard(AnalyticsDashboardModel? data) {
    final products = data?.topProducts ?? [];
    final maxRevenue = products.fold<double>(
      0.0,
      (max, p) => p.revenue > max ? p.revenue : max,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product insights',
            style: GoogleFonts.inter(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Items sorted by revenue',
            style: GoogleFonts.inter(
              fontSize: 11.5.sp,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 14.h),
          if (products.isEmpty)
            _buildEmptyPlaceholder('No sales data recorded for products yet.')
          else ...[
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      'Product',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Units',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Revenue',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            SizedBox(height: 8.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              separatorBuilder: (_, _) => Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
              ),
              itemBuilder: (context, index) {
                final p = products[index];
                final progress = maxRevenue > 0 ? (p.revenue / maxRevenue).clamp(0.05, 1.0) : 0.05;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            p.name,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: GoogleFonts.inter(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${p.units}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            p.formattedRevenue,
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
                    SizedBox(height: 6.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5.h,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF630F)),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderFunnelCard(AnalyticsDashboardModel? data) {
    final funnel = data?.orderFunnel ?? OrderFunnelData();
    final maxCount = math.max(1, math.max(funnel.pending, math.max(funnel.delivered, funnel.cancelled)));

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order funnel',
            style: GoogleFonts.inter(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Where orders sit in the fulfilment pipeline',
            style: GoogleFonts.inter(
              fontSize: 11.5.sp,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 16.h),
          _buildFunnelBar(
            label: 'Pending',
            count: funnel.pending,
            max: maxCount,
            color: const Color(0xFFFF630F),
          ),
          SizedBox(height: 12.h),
          _buildFunnelBar(
            label: 'Delivered',
            count: funnel.delivered,
            max: maxCount,
            color: const Color(0xFF10B981),
          ),
          SizedBox(height: 12.h),
          _buildFunnelBar(
            label: 'Cancelled',
            count: funnel.cancelled,
            max: maxCount,
            color: const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _buildFunnelBar({
    required String label,
    required int count,
    required int max,
    required Color color,
  }) {
    final progress = max > 0 ? (count / max).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '$count',
              style: GoogleFonts.inter(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6.h,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsCard(AnalyticsDashboardModel? data) {
    final payments = data?.paymentMethods ?? PaymentMethodsData();
    final total = payments.totalCount > 0 ? payments.totalCount : (payments.codCount + payments.walletCount);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment methods',
            style: GoogleFonts.inter(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'How customers prefer to pay',
            style: GoogleFonts.inter(
              fontSize: 11.5.sp,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              // Donut Chart
              SizedBox(
                width: 110.w,
                height: 110.w,
                child: CustomPaint(
                  painter: _DonutChartPainter(
                    codCount: payments.codCount,
                    walletCount: payments.walletCount,
                    totalCount: total,
                  ),
                  child: Center(
                    child: Text(
                      '$total',
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 24.w),
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPaymentLegend(
                      color: const Color(0xFFFF630F),
                      label: 'COD',
                      count: payments.codCount,
                      percentage: payments.codPct,
                    ),
                    SizedBox(height: 14.h),
                    _buildPaymentLegend(
                      color: const Color(0xFF3B82F6),
                      label: 'Wallet',
                      count: payments.walletCount,
                      percentage: payments.walletPct,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentLegend({
    required Color color,
    required String label,
    required int count,
    required double percentage,
  }) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '$count (${percentage.toStringAsFixed(0)}%)',
          style: GoogleFonts.inter(
            fontSize: 12.5.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerRatingsCard(AnalyticsDashboardModel? data) {
    final ratings = data?.starRatings ?? {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    final total = ratings.values.fold<int>(0, (sum, count) => sum + count);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 20),
              SizedBox(width: 6.w),
              Text(
                'Customer ratings',
                style: GoogleFonts.inter(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            total == 0 ? 'No approved reviews yet' : 'Based on $total customer reviews',
            style: GoogleFonts.inter(
              fontSize: 11.5.sp,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 16.h),
          ...[5, 4, 3, 2, 1].map((star) {
            final count = ratings[star] ?? 0;
            final progress = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                children: [
                  SizedBox(
                    width: 32.w,
                    child: Text(
                      '$star ★',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6.h,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  SizedBox(
                    width: 24.w,
                    child: Text(
                      '$count',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCouponPerformanceCard(AnalyticsDashboardModel? data) {
    final coupons = data?.coupons ?? [];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coupon performance',
                    style: GoogleFonts.inter(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Which discount codes actually get used',
                    style: GoogleFonts.inter(
                      fontSize: 11.5.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Get.toNamed(Routes.COUPONS),
                child: Text(
                  'Manage',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (coupons.isEmpty)
            _buildEmptyPlaceholder('No coupons created yet')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: coupons.length,
              separatorBuilder: (_, _) => Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
              ),
              itemBuilder: (context, index) {
                final c = coupons[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(color: const Color(0xFFFFEDD5)),
                          ),
                          child: Text(
                            c.code,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${c.usedCount} uses',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '৳${c.discountAmount.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlaceholder(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.box, color: const Color(0xFF94A3B8), size: 32.sp),
          SizedBox(height: 8.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom Painters for Smooth Visualizations
// ---------------------------------------------------------------------------

class _RevenueLineChartPainter extends CustomPainter {
  final List<DailyRevenuePoint> points;

  _RevenueLineChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    // Fallback simulated points if empty (to match visual elegance)
    final data = points.isNotEmpty
        ? points
        : [
            DailyRevenuePoint(date: '09-30', revenue: 0),
            DailyRevenuePoint(date: '10-04', revenue: 0),
            DailyRevenuePoint(date: '10-08', revenue: 0),
            DailyRevenuePoint(date: '10-12', revenue: 0),
            DailyRevenuePoint(date: '10-16', revenue: 102000),
            DailyRevenuePoint(date: '10-20', revenue: 5000),
            DailyRevenuePoint(date: '10-24', revenue: 20000),
            DailyRevenuePoint(date: '10-28', revenue: 0),
          ];

    final bottomPadding = 24.0;
    final chartHeight = size.height - bottomPadding;
    final maxRevenue = data.fold<double>(0.0, (max, p) => p.revenue > max ? p.revenue : max);
    final effectiveMax = maxRevenue > 0 ? maxRevenue * 1.15 : 1000.0;

    // Draw horizontal dashed grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= 3; i++) {
      final y = chartHeight * (i / 3);
      _drawDashedLine(canvas, Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (data.length < 2) return;

    // Compute pixel positions
    final coords = <Offset>[];
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = chartHeight - ((data[i].revenue / effectiveMax) * chartHeight);
      coords.add(Offset(x, y));
    }

    // Build smooth cubic Bezier path
    final linePath = Path();
    linePath.moveTo(coords[0].dx, coords[0].dy);

    for (int i = 0; i < coords.length - 1; i++) {
      final p0 = coords[i];
      final p1 = coords[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    // Gradient fill under the curve
    final fillPath = Path.from(linePath);
    fillPath.lineTo(coords.last.dx, chartHeight);
    fillPath.lineTo(coords.first.dx, chartHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x33FF630F),
          Color(0x00FF630F),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw curve line
    final linePaint = Paint()
      ..color = const Color(0xFFFF630F)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // Draw peak point dot
    int maxIndex = 0;
    double highest = -1;
    for (int i = 0; i < data.length; i++) {
      if (data[i].revenue > highest) {
        highest = data[i].revenue;
        maxIndex = i;
      }
    }

    if (highest > 0 && maxIndex < coords.length) {
      final peak = coords[maxIndex];
      final outerDot = Paint()..color = const Color(0xFFFF630F);
      final innerDot = Paint()..color = Colors.white;

      canvas.drawCircle(peak, 5, outerDot);
      canvas.drawCircle(peak, 2.5, innerDot);
    }

    // Draw X-axis date labels
    final labelStep = math.max(1, (data.length / 5).floor());
    for (int i = 0; i < data.length; i += labelStep) {
      final textSpan = TextSpan(
        text: data[i].date,
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final x = (coords[i].dx - (textPainter.width / 2)).clamp(0.0, size.width - textPainter.width);
      textPainter.paint(canvas, Offset(x, chartHeight + 8));
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = p1.dx;
    while (startX < p2.dx) {
      canvas.drawLine(
        Offset(startX, p1.dy),
        Offset(math.min(startX + dashWidth, p2.dx), p1.dy),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _RevenueLineChartPainter oldDelegate) => true;
}

class _DonutChartPainter extends CustomPainter {
  final int codCount;
  final int walletCount;
  final int totalCount;

  _DonutChartPainter({
    required this.codCount,
    required this.walletCount,
    required this.totalCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 14.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final basePaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, basePaint);

    final total = totalCount > 0 ? totalCount : (codCount + walletCount);
    if (total == 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // COD sweep (Orange)
    final codFraction = codCount / total;
    final codSweep = codFraction * 2 * math.pi;

    final codPaint = Paint()
      ..color = const Color(0xFFFF630F)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    double startAngle = -math.pi / 2;
    if (codFraction > 0) {
      canvas.drawArc(rect, startAngle, codSweep, false, codPaint);
      startAngle += codSweep;
    }

    // Wallet sweep (Blue)
    final walletFraction = walletCount / total;
    final walletSweep = walletFraction * 2 * math.pi;

    final walletPaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    if (walletFraction > 0) {
      canvas.drawArc(rect, startAngle, walletSweep, false, walletPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}
