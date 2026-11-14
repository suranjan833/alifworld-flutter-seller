import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../data/theme/app_colors.dart';
import '../../../data/widgets/exit_dialog.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  static const List<Map<String, dynamic>> slides = [
    {
      'tag': '01 • MARKET EXPANSION',
      'title': 'Reach Verified Buyers Across\nBangladesh',
      'desc':
          'Showcase your store to customers in 64 districts. Enjoy streamlined onboarding and automated catalog management.',
      'mainIcon': Iconsax.shop,
      'accIcon1': Iconsax.global,
      'accIcon2': Iconsax.trend_up,
      'features': [
        {'icon': Iconsax.verify, 'text': 'Fast store verification & live storefront'},
        {'icon': Iconsax.tag_2, 'text': 'Transparent commission & promotional tools'},
      ],
      'gradient': [Color(0xFFFF630F), Color(0xFFFF8E4F)],
      'badgeColor': Color(0xFFFFF2EB),
    },
    {
      'tag': '02 • SEAMLESS LOGISTICS',
      'title': 'Doorstep Pickup In\nAll 64 Districts',
      'desc':
          'Never worry about order delivery. We pick up parcels directly from your shop or warehouse with automated GPS route tracking.',
      'mainIcon': Iconsax.truck_fast,
      'accIcon1': Iconsax.box_tick,
      'accIcon2': Iconsax.routing,
      'features': [
        {'icon': Iconsax.box, 'text': 'Convenient doorstep courier pickup & safe packing'},
        {'icon': Iconsax.radar_2, 'text': 'Real-time parcel tracking and instant notifications'},
      ],
      'gradient': [Color(0xFF2563EB), Color(0xFF60A5FA)],
      'badgeColor': Color(0xFFEFF6FF),
    },
    {
      'tag': '03 • SECURE EARNINGS',
      'title': 'Automated Next-Day\nBank Payouts',
      'desc':
          'Transparent accounting with zero manual withdrawal delays. Track real-time profit margins, order velocity, and customer ratings.',
      'mainIcon': Iconsax.wallet_3,
      'accIcon1': Iconsax.card_tick,
      'accIcon2': Iconsax.chart_21,
      'features': [
        {'icon': Iconsax.money_tick, 'text': 'Automated 24h bank and MFS payouts direct to you'},
        {'icon': Iconsax.chart_success, 'text': 'Powerful live dashboard with revenue analytics'},
      ],
      'gradient': [Color(0xFF059669), Color(0xFF34D399)],
      'badgeColor': Color(0xFFECFDF5),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (controller.currentPage.value > 0) {
          controller.previousPage();
        } else {
          await handleAppExit(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          leading: Obx(
            () => controller.currentPage.value > 0
                ? IconButton(
                    icon: Icon(Iconsax.arrow_left_2, color: AppColors.textPrimary, size: 20.sp),
                    onPressed: controller.previousPage,
                  )
                : const SizedBox.shrink(),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 28.h,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Iconsax.shop, color: AppColors.primary, size: 18.sp),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'SELLER',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Obx(
              () => controller.currentPage.value < OnboardingController.totalPages - 1
                  ? TextButton(
                      onPressed: controller.skip,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.inter(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            SizedBox(width: 12.w),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // PageView Area
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  itemCount: slides.length,
                  onPageChanged: controller.onPageChanged,
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    return _buildSlide(slide);
                  },
                ),
              ),

              // Bottom Navigation & Actions
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlide(Map<String, dynamic> slide) {
    final List<Color> gradientColors = slide['gradient'] as List<Color>;
    final List<Map<String, dynamic>> features =
        slide['features'] as List<Map<String, dynamic>>;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10.h),

          // Central Visual with Vuesax Icons & Glow
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer Decorative Soft Ring
              Container(
                width: 220.w,
                height: 220.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gradientColors[0].withValues(alpha: 0.08),
                ),
              ),
              // Inner Ring
              Container(
                width: 170.w,
                height: 170.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gradientColors[0].withValues(alpha: 0.15),
                ),
              ),
              // Center Floating Card
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    slide['mainIcon'] as IconData,
                    size: 54.sp,
                    color: Colors.white,
                  ),
                ),
              ),
              // Accessory Vuesax Badge Top-Right
              Positioned(
                top: 15.h,
                right: 25.w,
                child: _buildFloatingIconBadge(
                  icon: slide['accIcon1'] as IconData,
                  color: gradientColors[0],
                ),
              ),
              // Accessory Vuesax Badge Bottom-Left
              Positioned(
                bottom: 15.h,
                left: 25.w,
                child: _buildFloatingIconBadge(
                  icon: slide['accIcon2'] as IconData,
                  color: gradientColors[1],
                ),
              ),
            ],
          ),
          SizedBox(height: 28.h),

          // Category Tag
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: slide['badgeColor'] as Color,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              slide['tag'] as String,
              style: GoogleFonts.inter(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w800,
                color: gradientColors[0],
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Slide Title
          Text(
            slide['title'] as String,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
          SizedBox(height: 10.h),

          // Slide Description
          Text(
            slide['desc'] as String,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: 20.h),

          // Feature Highlights with Vuesax Icons
          ...features.map(
            (feat) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      feat['icon'] as IconData,
                      size: 16.sp,
                      color: gradientColors[0],
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        feat['text'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingIconBadge({
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, size: 20.sp, color: color),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1.w)),
      ),
      child: Obx(() {
        final isLastPage =
            controller.currentPage.value == OnboardingController.totalPages - 1;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Smooth Dot Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                OnboardingController.totalPages,
                (index) {
                  final isActive = controller.currentPage.value == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    height: 7.h,
                    width: isActive ? 24.w : 7.w,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 18.h),

            // Action Button
            if (!isLastPage)
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: controller.nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Iconsax.arrow_right_3, size: 18.sp, color: Colors.white),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: controller.finish,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.shop, size: 18.sp, color: Colors.white),
                          SizedBox(width: 8.w),
                          Text(
                            'Get Started as a Seller',
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Icon(Iconsax.arrow_right_3, size: 16.sp, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: controller.finish,
                        child: Text(
                          'Log In',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        );
      }),
    );
  }
}

