import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../data/models/dashboard_stats_model.dart';
import '../../../data/theme/app_colors.dart';
import '../../../data/widgets/exit_dialog.dart';
import '../../../data/widgets/shimmer_widget.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';
import '../widgets/announcement_banner.dart';
import '../widgets/announcements_sheet.dart';
import '../widgets/kpi_card.dart';
import '../widgets/seller_drawer.dart';
import 'orders_page.dart';
import 'products_page.dart';
import 'profile_view.dart';
import 'wallets_page.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (controller.currentNavIndex.value != 0) {
          controller.changeNavIndex(0);
        } else {
          await handleAppExit(context);
        }
      },
      child: Scaffold(
        key: controller.scaffoldKey,
        drawer: const SellerDrawer(),
        backgroundColor: AppColors.background,
        body: Obx(
          () => IndexedStack(
            index: controller.currentNavIndex.value,
            children: [
              _buildDashboardView(context),
              const OrdersPage(),
              const ProductsPage(),
              const WalletsPage(),
              const ProfileView(),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  // ===========================================================================
  // UNIFIED SELLER DASHBOARD (Per alifworld-seller-dashboard-flutter-readme.md)
  // ===========================================================================
  Widget _buildDashboardView(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: controller.loadAllData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6.h),

              // Announcements Banner
              const AnnouncementBanner(),

              // 1. Range Selector (7D / 30D / 90D)
              _buildRangeHeader(),

              // 2. Main KPI Cards (Call 1)
              _buildKpisSection(),

              SizedBox(height: 14.h),

              // 3. Revenue Over Time Chart (Call 1 Series)
              _buildRevenueChartSection(),

              SizedBox(height: 14.h),

              // 4. Order Funnel (Call 1 Funnel)
              _buildOrderFunnelSection(),

              SizedBox(height: 14.h),

              // 5. Top Products Best Sellers (Call 1 Top Products, top 5)
              _buildTopProductsSection(),

              SizedBox(height: 14.h),

              // 6. Attention Cards (Call 2 Analytics Summary)
              _buildAttentionCardsSection(context),

              SizedBox(height: 14.h),

              // 7. Growth KPIs (Call 3 Analytics Dashboard)
              _buildGrowthKpisSection(),

              SizedBox(height: 14.h),

              // 8. Payment Methods Breakdown (Call 3 Payment Split)
              _buildPaymentMethodsSection(),

              SizedBox(height: 14.h),

              // 9. Customer Ratings (Call 3 Rating Dist + All-time avg)
              _buildCustomerRatingsSection(),

              SizedBox(height: 14.h),

              // 10. Coupon Performance (Call 3 Coupons)
              _buildCouponPerformanceSection(),

              SizedBox(height: 14.h),

              // 11. Quick Operations Hub
              _buildQuickActions(context),

              SizedBox(height: 36.h),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. RANGE SELECTOR HEADER (7D / 30D / 90D)
  // ===========================================================================
  Widget _buildRangeHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard & Analytics',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Live store performance & growth metrics',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Obx(() {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: controller.availableRanges.map((range) {
                  final isSelected = controller.selectedRange.value == range;
                  return GestureDetector(
                    onTap: () => controller.changeDateRange(range),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        range.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
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

  // ===========================================================================
  // 2. MAIN KPI CARDS (Call 1)
  // ===========================================================================
  Widget _buildKpisSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Obx(() {
        final stats = controller.dashboardStats.value;
        final isLoading = controller.isLoading.value && stats == null;

        if (isLoading) {
          return const KpiGridShimmer();
        }

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.25,
          children: [
            KpiCard(
              title: 'Revenue',
              value: stats != null ? stats.formattedRevenue : '৳0',
              icon: Iconsax.wallet_money,
              color: AppColors.primary,
              bgColor: AppColors.primaryLight,
              deltaPct: stats?.revenue.deltaPct,
            ),
            KpiCard(
              title: 'Orders',
              value: '${stats?.orders.value ?? 0}',
              icon: Iconsax.bag_2,
              color: const Color(0xFF3B82F6),
              bgColor: const Color(0xFFEFF6FF),
              deltaPct: stats?.orders.deltaPct,
            ),
            KpiCard(
              title: 'Units Sold',
              value: '${stats?.unitsSold.value ?? 0}',
              icon: Iconsax.box,
              color: const Color(0xFF10B981),
              bgColor: const Color(0xFFECFDF5),
              deltaPct: stats?.unitsSold.deltaPct,
            ),
            KpiCard(
              title: 'Avg Order Value',
              value: stats != null ? stats.formattedAvgOrderValue : '৳0',
              icon: Iconsax.chart_21,
              color: const Color(0xFF8B5CF6),
              bgColor: const Color(0xFFF5F3FF),
              deltaPct: stats?.avgOrderValue.deltaPct,
            ),
          ],
        );
      }),
    );
  }

  // ===========================================================================
  // 3. REVENUE OVER TIME CHART (Call 1 series)
  // ===========================================================================
  Widget _buildRevenueChartSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() {
        final stats = controller.dashboardStats.value;
        final points = stats?.series ?? [];
        final hasSales = stats != null && stats.hasSales;

        return _buildSectionCardWrapper(
          title: 'Revenue over time',
          subtitle: 'Daily sales performance for ${controller.selectedRange.value.toUpperCase()}',
          child: !hasSales || points.isEmpty
              ? _buildEmptyState(
                  icon: Iconsax.chart_21,
                  message: 'No sales in this period yet',
                )
              : SizedBox(
                  height: 180.h,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _DashboardSeriesLineChartPainter(
                      points: points,
                      currencySymbol: stats.currencySymbol,
                    ),
                  ),
                ),
        );
      }),
    );
  }

  // ===========================================================================
  // 4. ORDER FUNNEL (Call 1 funnel)
  // ===========================================================================
  Widget _buildOrderFunnelSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() {
        final stats = controller.dashboardStats.value;
        final funnel = stats?.funnel ?? [];
        final hasOrders = stats != null && stats.hasOrders && funnel.isNotEmpty;

        final totalCount = funnel.fold<int>(0, (sum, f) => sum + f.count);

        return _buildSectionCardWrapper(
          title: 'Order funnel',
          subtitle: 'Conversion & fulfillment pipeline (${controller.selectedRange.value.toUpperCase()})',
          child: !hasOrders
              ? _buildEmptyState(
                  icon: Iconsax.box_remove,
                  message: 'No orders in this period yet',
                )
              : Column(
                  children: funnel.map((item) {
                    final pct = totalCount > 0 ? (item.count / totalCount) : 0.0;
                    final color = _getStatusColor(item.status);

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8.w,
                                    height: 8.w,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    item.displayStatus,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${item.count} orders (${(pct * 100).toStringAsFixed(1)}%)',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 6.h,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        );
      }),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'completed':
        return const Color(0xFF10B981);
      case 'pending':
      case 'processing':
        return const Color(0xFFF59E0B);
      case 'shipped':
      case 'handed_over':
      case 'out_for_delivery':
        return const Color(0xFF3B82F6);
      case 'cancelled':
      case 'refunded':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  // ===========================================================================
  // 5. TOP PRODUCTS (Call 1 topProducts, top 5)
  // ===========================================================================
  Widget _buildTopProductsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() {
        final stats = controller.dashboardStats.value;
        final products = stats?.topProducts ?? [];
        final hasSales = stats != null && stats.hasSales && products.isNotEmpty;

        return _buildSectionCardWrapper(
          title: 'Top products',
          subtitle: 'Best-selling items by revenue (${controller.selectedRange.value.toUpperCase()})',
          child: !hasSales
              ? _buildEmptyState(
                  icon: Iconsax.shop,
                  message: 'No sales in this period yet',
                )
              : Column(
                  children: List.generate(math.min(5, products.length), (index) {
                    final item = products[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(
                        children: [
                          Container(
                            width: 26.w,
                            height: 26.w,
                            decoration: BoxDecoration(
                              color: index == 0
                                  ? const Color(0xFFFEF3C7)
                                  : (index == 1 ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC)),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '#${index + 1}',
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: index == 0 ? const Color(0xFFD97706) : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  '${item.units} units sold',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.sp,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            stats.formatMoney(item.revenueMinor),
                            style: GoogleFonts.inter(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
        );
      }),
    );
  }

  // ===========================================================================
  // 6. ATTENTION CARDS (Call 2 Analytics Summary)
  // ===========================================================================
  Widget _buildAttentionCardsSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() {
        final summary = controller.analyticsSummary.value;
        if (summary == null) return const SizedBox.shrink();

        return _buildSectionCardWrapper(
          title: 'Action items & attention',
          subtitle: 'Live operational snapshot requiring merchant action',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildAttentionTile(
                      label: 'Pending reviews',
                      count: summary.reviewsPending,
                      icon: Iconsax.star,
                      color: const Color(0xFFF59E0B),
                      onTap: () => Get.toNamed(Routes.REVIEWS, arguments: {'filter': 'pending'}),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildAttentionTile(
                      label: 'Low stock items',
                      count: summary.lowStockCount,
                      icon: Iconsax.warning_2,
                      color: summary.lowStockCount > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      onTap: () => Get.toNamed(Routes.INVENTORY),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: _buildAttentionTile(
                      label: 'Pending products',
                      count: summary.productsPending,
                      icon: Iconsax.box_time,
                      color: const Color(0xFF3B82F6),
                      onTap: () => controller.changeNavIndex(2),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildAttentionTile(
                      label: 'Announcements',
                      count: summary.announcementsUnread,
                      icon: Iconsax.notification,
                      color: AppColors.primary,
                      onTap: () => AnnouncementsSheet.show(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAttentionTile({
    required String label,
    required int count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, size: 16.sp, color: color),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 7. GROWTH KPIS (Call 3 Analytics Dashboard)
  // ===========================================================================
  Widget _buildGrowthKpisSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() {
        final growth = controller.growthAnalytics.value;
        if (growth == null) return const SizedBox.shrink();

        return _buildSectionCardWrapper(
          title: 'Store growth & quality',
          subtitle: 'Customer retention and service metrics (${controller.selectedRange.value.toUpperCase()})',
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: 1.6,
            children: [
              _buildGrowthTile(
                title: 'Cancellation rate',
                value: growth.formattedCancellationRate,
                icon: Iconsax.close_circle,
                color: const Color(0xFFEF4444),
                subtitle: 'Period order loss',
              ),
              _buildGrowthTile(
                title: 'Average rating',
                value: growth.formattedAvgRating,
                icon: Iconsax.star,
                color: const Color(0xFFF59E0B),
                subtitle: 'All-time reviews',
              ),
              _buildGrowthTile(
                title: 'Unique buyers',
                value: '${growth.customers}',
                icon: Iconsax.people,
                color: const Color(0xFF3B82F6),
                subtitle: 'Active customers',
              ),
              _buildGrowthTile(
                title: 'Repeat customers',
                value: growth.formattedRepeatCustomers,
                icon: Iconsax.refresh_2,
                color: const Color(0xFF10B981),
                subtitle: '>1 orders in period',
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildGrowthTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              Icon(icon, size: 14.sp, color: color),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 9.5.sp,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 8. PAYMENT METHODS (Call 3 paymentSplit)
  // ===========================================================================
  Widget _buildPaymentMethodsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() {
        final stats = controller.dashboardStats.value;
        final growth = controller.growthAnalytics.value;
        final split = growth?.paymentSplit ?? [];
        final totalOrders = split.fold<int>(0, (sum, item) => sum + item.orders);

        return _buildSectionCardWrapper(
          title: 'Payment methods',
          subtitle: 'Orders & revenue by payment gateway (${controller.selectedRange.value.toUpperCase()})',
          child: split.isEmpty || totalOrders == 0
              ? _buildEmptyState(
                  icon: Iconsax.card_pos,
                  message: 'No orders in this period yet',
                )
              : Column(
                  children: split.map((item) {
                    final pct = totalCountPct(item.orders, totalOrders);
                    final color = _getPaymentColor(item.method);

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      item.displayMethod,
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5.sp,
                                        fontWeight: FontWeight.w700,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    '${item.orders} orders',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${pct.toStringAsFixed(1)}% • ${stats != null ? stats.formatMoney(item.revenueMinor) : '৳${(item.revenueMinor / 100).toStringAsFixed(0)}'}',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              value: pct / 100.0,
                              minHeight: 5.h,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        );
      }),
    );
  }

  double totalCountPct(int count, int total) {
    if (total <= 0) return 0.0;
    return (count / total) * 100.0;
  }

  Color _getPaymentColor(String method) {
    switch (method.toLowerCase()) {
      case 'cod':
      case 'cash':
        return const Color(0xFF10B981);
      case 'bkash':
        return const Color(0xFFE2136E);
      case 'nagad':
        return const Color(0xFFF58220);
      case 'wallet':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  // ===========================================================================
  // 9. CUSTOMER RATINGS (Call 3 ratingDist + kpis, All-Time)
  // ===========================================================================
  Widget _buildCustomerRatingsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() {
        final growth = controller.growthAnalytics.value;
        final ratings = growth?.starRatings ?? {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
        final totalReviews = growth?.totalReviews ?? 0;
        final avgRating = growth?.avgRating;

        return _buildSectionCardWrapper(
          title: 'Customer ratings',
          subtitle: 'All-time verified customer review distribution',
          child: totalReviews == 0
              ? _buildEmptyState(
                  icon: Iconsax.star,
                  message: 'No approved reviews yet',
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          avgRating != null && avgRating > 0 ? avgRating.toStringAsFixed(1) : '—',
                          style: GoogleFonts.inter(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: List.generate(5, (index) {
                                final isFull = index < (avgRating?.round() ?? 0);
                                return Icon(
                                  Icons.star_rounded,
                                  size: 16.sp,
                                  color: isFull ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                                );
                              }),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '$totalReviews total reviews (All-time)',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    SizedBox(height: 10.h),
                    ...[5, 4, 3, 2, 1].map((star) {
                      final count = ratings[star] ?? 0;
                      final pct = totalReviews > 0 ? (count / totalReviews) : 0.0;

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 3.h),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 32.w,
                              child: Row(
                                children: [
                                  Text(
                                    '$star',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Icon(Icons.star_rounded, size: 13.sp, color: const Color(0xFFF59E0B)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4.r),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 6.h,
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            SizedBox(
                              width: 36.w,
                              child: Text(
                                '$count',
                                textAlign: TextAlign.end,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
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
      }),
    );
  }

  // ===========================================================================
  // 10. COUPON PERFORMANCE (Call 3 coupons)
  // ===========================================================================
  Widget _buildCouponPerformanceSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() {
        final stats = controller.dashboardStats.value;
        final growth = controller.growthAnalytics.value;
        final coupons = growth?.coupons ?? [];
        final currencySymbol = stats?.currencySymbol ?? '৳';

        return _buildSectionCardWrapper(
          title: 'Coupon performance',
          subtitle: 'Active & past voucher redemption volume',
          child: coupons.isEmpty
              ? _buildEmptyState(
                  icon: Iconsax.ticket_discount,
                  message: 'No coupons created yet',
                )
              : Column(
                  children: coupons.map((c) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(color: const Color(0xFFFFEDD5)),
                              ),
                              child: Text(
                                c.code,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFEA580C),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: c.isActive ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                c.isActive ? 'Active' : 'Inactive',
                                style: GoogleFonts.inter(
                                  fontSize: 9.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: c.isActive ? const Color(0xFF059669) : const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  c.formatDiscount(currencySymbol),
                                  style: GoogleFonts.inter(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  '${c.usedCount} used',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5.sp,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        );
      }),
    );
  }

  // ===========================================================================
  // 11. QUICK OPERATIONS HUB
  // ===========================================================================
  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Operations',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  title: 'Order Tracking',
                  subtitle: 'Manage & ship',
                  icon: Iconsax.truck_fast,
                  color: const Color(0xFF3B82F6),
                  onTap: () => controller.changeNavIndex(1),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildActionTile(
                  title: 'Product Catalog',
                  subtitle: 'Stock & pricing',
                  icon: Iconsax.box_add,
                  color: const Color(0xFF10B981),
                  onTap: () => controller.changeNavIndex(2),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  title: 'Wallet & Payout',
                  subtitle: 'Balance & transfers',
                  icon: Iconsax.card_pos,
                  color: const Color(0xFF8B5CF6),
                  onTap: () => controller.changeNavIndex(3),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildActionTile(
                  title: 'Coupons & Vouchers',
                  subtitle: 'Promotional rules',
                  icon: Iconsax.ticket_discount,
                  color: const Color(0xFFEA580C),
                  onTap: () => Get.toNamed(Routes.COUPONS),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: color, size: 18.sp),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10.5.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SECTION WRAPPER & EMPTY STATE HELPERS
  // ===========================================================================
  Widget _buildSectionCardWrapper({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
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
            title,
            style: GoogleFonts.inter(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11.5.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28.sp, color: const Color(0xFFCBD5E1)),
          SizedBox(height: 6.h),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // APPBAR & NAVIGATION
  // ===========================================================================
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Iconsax.menu, color: AppColors.textPrimary, size: 24),
        onPressed: controller.openDrawer,
      ),
      leadingWidth: 44.w,
      titleSpacing: 0,
      title: Obx(() {
        return Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  controller.sellerName.isNotEmpty ? controller.sellerName[0].toUpperCase() : 'S',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${controller.timeGreeting} ${controller.greetingIcon}',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          controller.sellerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Text(
                          controller.sellerStatus,
                          style: GoogleFonts.inter(
                            fontSize: 8.5.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF065F46),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      actions: [
        Obx(() {
          final unread = controller.unreadCount;
          return Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Iconsax.notification, color: AppColors.textPrimary),
                onPressed: () => AnnouncementsSheet.show(context),
              ),
              if (unread > 0)
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16.w,
                      minHeight: 16.w,
                    ),
                    child: Center(
                      child: Text(
                        unread > 9 ? '9+' : '$unread',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
        PopupMenuButton<String>(
          icon: const Icon(Iconsax.more, color: AppColors.textSecondary),
          onSelected: (value) {
            if (value == 'logout') {
              controller.logout();
            } else if (value == 'announcements') {
              AnnouncementsSheet.show(context);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'announcements',
              child: Row(
                children: [
                  Icon(Iconsax.notification_status, size: 18),
                  SizedBox(width: 8),
                  Text('Announcements'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Iconsax.logout, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Logout', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        SizedBox(width: 6.w),
      ],
    );
  }

  Widget _buildBottomNav() {
    final navItems = [
      {'label': 'Dashboard', 'icon': Iconsax.element_4, 'activeIcon': Iconsax.element_4},
      {'label': 'Orders', 'icon': Iconsax.box, 'activeIcon': Iconsax.box_tick},
      {'label': 'Catalog', 'icon': Iconsax.shop, 'activeIcon': Iconsax.shop},
      {'label': 'Wallets', 'icon': Iconsax.wallet_3, 'activeIcon': Iconsax.card_pos},
      {'label': 'Profile', 'icon': Iconsax.profile_circle, 'activeIcon': Iconsax.user},
    ];

    return Obx(() {
      final selectedIndex = controller.currentNavIndex.value;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
          border: const Border(top: BorderSide(color: AppColors.border, width: 0.8)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navItems.length, (index) {
                final item = navItems[index];
                final isSelected = selectedIndex == index;
                final icon = isSelected ? (item['activeIcon'] as IconData) : (item['icon'] as IconData);

                return InkWell(
                  onTap: () => controller.changeNavIndex(index),
                  borderRadius: BorderRadius.circular(12.r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 12.w : 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryLight : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 20.sp,
                          color: isSelected ? AppColors.primary : AppColors.textMuted,
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          item['label'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 10.5.sp,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.primary : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      );
    });
  }
}

// =============================================================================
// REVENUE LINE CHART PAINTER (Call 1 Series)
// =============================================================================
class _DashboardSeriesLineChartPainter extends CustomPainter {
  final List<DashboardSeriesPoint> points;
  final String currencySymbol;

  _DashboardSeriesLineChartPainter({required this.points, required this.currencySymbol});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final bottomPadding = 24.0;
    final chartHeight = size.height - bottomPadding;
    final maxRevenue = points.fold<double>(0.0, (max, p) => p.revenueTaka > max ? p.revenueTaka : max);
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

    if (points.length < 2) return;

    final coords = <Offset>[];
    final stepX = size.width / (points.length - 1);

    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y = chartHeight - ((points[i].revenueTaka / effectiveMax) * chartHeight);
      coords.add(Offset(x, y));
    }

    // Build smooth cubic Bezier path
    final linePath = Path()..moveTo(coords[0].dx, coords[0].dy);

    for (int i = 0; i < coords.length - 1; i++) {
      final p0 = coords[i];
      final p1 = coords[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    // Fill under curve
    final fillPath = Path.from(linePath)
      ..lineTo(coords.last.dx, chartHeight)
      ..lineTo(coords.first.dx, chartHeight)
      ..close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x33FF630F), Color(0x00FF630F)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw main line
    final linePaint = Paint()
      ..color = const Color(0xFFFF630F)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // Peak dot
    int maxIndex = 0;
    double highest = -1;
    for (int i = 0; i < points.length; i++) {
      if (points[i].revenueTaka > highest) {
        highest = points[i].revenueTaka;
        maxIndex = i;
      }
    }

    if (highest > 0 && maxIndex < coords.length) {
      final peak = coords[maxIndex];
      canvas.drawCircle(peak, 5, Paint()..color = const Color(0xFFFF630F));
      canvas.drawCircle(peak, 2.5, Paint()..color = Colors.white);
    }

    // X-Axis date labels
    final labelStep = math.max(1, (points.length / 5).floor());
    for (int i = 0; i < points.length; i += labelStep) {
      final rawDate = points[i].date;
      String shortDate = rawDate;
      if (shortDate.contains('-')) {
        final parts = shortDate.split('-');
        if (parts.length >= 3) {
          shortDate = '${parts[1]}-${parts[2]}';
        }
      }

      final textSpan = TextSpan(
        text: shortDate,
        style: GoogleFonts.inter(fontSize: 9.5.sp, color: const Color(0xFF94A3B8)),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final x = coords[i].dx - (textPainter.width / 2);
      textPainter.paint(canvas, Offset(math.max(0, math.min(size.width - textPainter.width, x)), chartHeight + 6));
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
  bool shouldRepaint(covariant _DashboardSeriesLineChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
