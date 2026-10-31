import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../data/models/leaderboard_model.dart';
import '../../../data/theme/app_colors.dart';
import '../../../data/widgets/shimmer_widget.dart';
import '../controllers/leaderboard_controller.dart';

class LeaderboardView extends GetView<LeaderboardController> {
  const LeaderboardView({super.key});

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
          'Seller leaderboard',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Iconsax.refresh, color: AppColors.textPrimary, size: 20),
            onPressed: () => controller.fetchLeaderboard(),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: ProductListShimmer());
        }

        final data = controller.leaderboardData.value;
        if (data == null) {
          return const Center(child: Text('No leaderboard data available.'));
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchLeaderboard(),
          color: const Color(0xFFFF630F),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Section (Title + Period Selector)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    if (isWide) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleSection(),
                          _buildPeriodSelector(),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildTitleSection()),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        _buildPeriodSelector(),
                      ],
                    );
                  },
                ),
                SizedBox(height: 16.h),

                // Top 3 Summary Cards
                _buildSummaryCards(data),
                SizedBox(height: 16.h),

                // Top Sellers Table Card
                _buildTopSellersCard(data),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seller leaderboard',
          style: GoogleFonts.inter(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Top shops ranked by sales revenue',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Obx(() {
      final current = controller.selectedPeriod.value;

      return Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: controller.periods.map((p) {
            final isSelected = current == p.toLowerCase();
            return InkWell(
              onTap: () => controller.changePeriod(p),
              borderRadius: BorderRadius.circular(6.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(6.r),
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
                child: Text(
                  p,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  // =========================================================================
  // TOP 3 SUMMARY CARDS (Matches Screenshot Exactly)
  // =========================================================================
  Widget _buildSummaryCards(LeaderboardDataModel data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 550;
        if (isWide) {
          return Row(
            children: [
              Expanded(child: _buildRankCard(data)),
              SizedBox(width: 12.w),
              Expanded(child: _buildRevenueCard(data)),
              SizedBox(width: 12.w),
              Expanded(child: _buildOrdersCard(data)),
            ],
          );
        }
        return Column(
          children: [
            _buildRankCard(data),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(child: _buildRevenueCard(data)),
                SizedBox(width: 10.w),
                Expanded(child: _buildOrdersCard(data)),
              ],
            ),
          ],
        );
      },
    );
  }

  // Card 1: My rank (Gold Border & Trophy)
  Widget _buildRankCard(LeaderboardDataModel data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFDF8),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFBBF24), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.05),
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
              Icon(Iconsax.cup, size: 16.sp, color: const Color(0xFFD97706)),
              SizedBox(width: 6.w),
              Text(
                'My rank',
                style: GoogleFonts.inter(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '#${data.myRank}',
                style: GoogleFonts.inter(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                'of ${data.totalSellers} sellers',
                style: GoogleFonts.inter(
                  fontSize: 12.5.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card 2: My revenue
  Widget _buildRevenueCard(LeaderboardDataModel data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
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
            'My revenue',
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            data.formattedMyRevenue,
            style: GoogleFonts.inter(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  // Card 3: My orders
  Widget _buildOrdersCard(LeaderboardDataModel data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
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
            'My orders',
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${data.myOrders}',
            style: GoogleFonts.inter(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TOP SELLERS CARD (Ranked by Sales Revenue)
  // =========================================================================
  Widget _buildTopSellersCard(LeaderboardDataModel data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
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
            'Top sellers',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Ranked by sales revenue in the selected period',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 16.h),

          // Table Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            child: Row(
              children: [
                SizedBox(
                  width: 50.w,
                  child: Text(
                    'Rank',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Shop',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
                SizedBox(
                  width: 60.w,
                  child: Text(
                    'Orders',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
                SizedBox(
                  width: 80.w,
                  child: Text(
                    'Revenue',
                    textAlign: TextAlign.end,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Table Rows or Empty State
          if (data.sellers.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Center(
                child: Text(
                  'No sellers ranked for this period yet.',
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.sellers.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final item = data.sellers[index];
                return _buildSellerRow(item);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSellerRow(LeaderboardSellerItem item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: item.isYou ? const Color(0xFFFFFBEB) : Colors.transparent,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 50.w,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.rank == 1) ...[
                  Icon(Iconsax.crown_1, size: 16.sp, color: const Color(0xFFD97706)),
                  SizedBox(width: 4.w),
                  Text(
                    '1',
                    style: GoogleFonts.inter(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                ] else
                  Text(
                    '#${item.rank}',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
                    ),
                  ),
              ],
            ),
          ),

          // Shop Name + [You] Badge (Two lines, NO ellipsis)
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6.w,
              runSpacing: 2.h,
              children: [
                Text(
                  item.shopName,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: item.isYou ? FontWeight.w800 : FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                if (item.isYou)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'You',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Orders Count
          SizedBox(
            width: 60.w,
            child: Text(
              '${item.orders}',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF334155),
              ),
            ),
          ),

          // Revenue
          SizedBox(
            width: 80.w,
            child: Text(
              item.formattedRevenue,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
