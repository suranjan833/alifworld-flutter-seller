import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class ShimmerLoadingController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final AnimationController animationController;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}

/// Reusable shimmer loading wrapper that applies an animated light sweep effect
/// to all child skeleton placeholders.
class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE2E8F0),
    this.highlightColor = const Color(0xFFF8FAFC),
    this.duration = const Duration(milliseconds: 1400),
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ShimmerLoadingController>()
        ? Get.find<ShimmerLoadingController>()
        : Get.put(ShimmerLoadingController());

    return AnimatedBuilder(
      animation: controller.animationController,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(
                  slidePercent: controller.animationController.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent * 2 - 1), 0.0, 0.0);
  }
}

/// A generic placeholder rectangle / pill for skeleton screens.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final ShapeBorder? shape;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: shape != null
          ? ShapeDecoration(color: Colors.white, shape: shape!)
          : BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius.r),
            ),
    );
  }
}

// ==========================================
// 1. KPI Grid Shimmer (Dashboard metrics)
// ==========================================
class KpiCardShimmer extends StatelessWidget {
  const KpiCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 30.w, height: 30.w, borderRadius: 10.r),
              ShimmerBox(width: 42.w, height: 16.h, borderRadius: 6.r),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 80.w, height: 18.h, borderRadius: 4.r),
              SizedBox(height: 6.h),
              ShimmerBox(width: 60.w, height: 11.h, borderRadius: 4.r),
            ],
          ),
        ],
      ),
    );
  }
}

class KpiGridShimmer extends StatelessWidget {
  const KpiGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.25,
        children: const [
          KpiCardShimmer(),
          KpiCardShimmer(),
          KpiCardShimmer(),
          KpiCardShimmer(),
        ],
      ),
    );
  }
}

// ==========================================
// 2. Product Shimmer
// ==========================================
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            width: 60.w,
            height: 60.w,
            borderRadius: 10.r,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(width: 130.w, height: 14.h, borderRadius: 4.r),
                    ShimmerBox(width: 48.w, height: 16.h, borderRadius: 4.r),
                  ],
                ),
                SizedBox(height: 8.h),
                ShimmerBox(width: 95.w, height: 12.h, borderRadius: 4.r),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(width: 65.w, height: 18.h, borderRadius: 6.r),
                    ShimmerBox(width: 55.w, height: 18.h, borderRadius: 10.r),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductListShimmer extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry? padding;

  const ProductListShimmer({
    super.key,
    this.itemCount = 6,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.separated(
        padding: padding ?? EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 20.h),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, _) => SizedBox(height: 10.h),
        itemBuilder: (_, _) => const ProductCardShimmer(),
      ),
    );
  }
}

// ==========================================
// 3. Order Shimmer
// ==========================================
class OrderCardShimmer extends StatelessWidget {
  const OrderCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 110.w, height: 15.h, borderRadius: 4.r),
              ShimmerBox(width: 64.w, height: 20.h, borderRadius: 6.r),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              ShimmerBox(width: 16.w, height: 16.w, borderRadius: 4.r),
              SizedBox(width: 8.w),
              ShimmerBox(width: 120.w, height: 12.h, borderRadius: 4.r),
              const Spacer(),
              ShimmerBox(width: 80.w, height: 12.h, borderRadius: 4.r),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(height: 1, color: AppColors.border),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 90.w, height: 16.h, borderRadius: 4.r),
              ShimmerBox(width: 50.w, height: 16.h, borderRadius: 4.r),
              ShimmerBox(width: 50.w, height: 18.h, borderRadius: 6.r),
            ],
          ),
        ],
      ),
    );
  }
}

class OrderListShimmer extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry? padding;

  const OrderListShimmer({
    super.key,
    this.itemCount = 5,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.separated(
        padding: padding ?? EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 20.h),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, _) => SizedBox(height: 10.h),
        itemBuilder: (_, _) => const OrderCardShimmer(),
      ),
    );
  }
}

// ==========================================
// 4. Wallet & Payout Shimmer
// ==========================================
class WalletOverviewShimmer extends StatelessWidget {
  const WalletOverviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 140.w, height: 13.h, borderRadius: 4.r),
                  SizedBox(height: 12.h),
                  ShimmerBox(width: 180.w, height: 32.h, borderRadius: 6.r),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(child: ShimmerBox(height: 40.h, borderRadius: 10.r)),
                      SizedBox(width: 10.w),
                      Expanded(child: ShimmerBox(height: 40.h, borderRadius: 10.r)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            ShimmerBox(width: 130.w, height: 16.h, borderRadius: 4.r),
            SizedBox(height: 10.h),
            for (int i = 0; i < 3; i++) ...[
              Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    ShimmerBox(width: 36.w, height: 36.w, borderRadius: 8.r),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(width: 110.w, height: 13.h, borderRadius: 4.r),
                          SizedBox(height: 6.h),
                          ShimmerBox(width: 70.w, height: 10.h, borderRadius: 4.r),
                        ],
                      ),
                    ),
                    ShimmerBox(width: 80.w, height: 16.h, borderRadius: 4.r),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. Profile Screen Shimmer
// ==========================================
class ProfileScreenShimmer extends StatelessWidget {
  const ProfileScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  ShimmerBox(width: 60.w, height: 60.w, borderRadius: 30.r),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 130.w, height: 16.h, borderRadius: 4.r),
                        SizedBox(height: 8.h),
                        ShimmerBox(width: 90.w, height: 12.h, borderRadius: 4.r),
                        SizedBox(height: 8.h),
                        ShimmerBox(width: 60.w, height: 18.h, borderRadius: 6.r),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            for (int i = 0; i < 3; i++) ...[
              Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    ShimmerBox(width: 34.w, height: 34.w, borderRadius: 8.r),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(width: 100.w, height: 12.h, borderRadius: 4.r),
                          SizedBox(height: 6.h),
                          ShimmerBox(width: 150.w, height: 14.h, borderRadius: 4.r),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 6. Announcement List Shimmer
// ==========================================
class AnnouncementListShimmer extends StatelessWidget {
  final int itemCount;

  const AnnouncementListShimmer({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, _) => SizedBox(height: 10.h),
        itemBuilder: (_, _) => Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBox(width: 150.w, height: 14.h, borderRadius: 4.r),
                  ShimmerBox(width: 50.w, height: 16.h, borderRadius: 4.r),
                ],
              ),
              SizedBox(height: 8.h),
              ShimmerBox(width: double.infinity, height: 11.h, borderRadius: 4.r),
              SizedBox(height: 4.h),
              ShimmerBox(width: 180.w, height: 11.h, borderRadius: 4.r),
              SizedBox(height: 8.h),
              ShimmerBox(width: 80.w, height: 10.h, borderRadius: 4.r),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer skeleton loading effect for Order Fulfillment / Details page
class OrderDetailShimmer extends StatelessWidget {
  const OrderDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Card Skeleton
            Container(
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
                      ShimmerBox(width: 170.w, height: 18.h, borderRadius: 6.r),
                      ShimmerBox(width: 75.w, height: 22.h, borderRadius: 12.r),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  ShimmerBox(width: 110.w, height: 18.h, borderRadius: 6.r),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // 2. Stepper Card Skeleton
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerBox(width: 120.w, height: 14.h, borderRadius: 4.r),
                      ShimmerBox(width: 60.w, height: 12.h, borderRadius: 4.r),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return ShimmerBox(width: 28.w, height: 28.w, borderRadius: 14.r);
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // 3. Next Action Banner Skeleton
            Container(
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
                  ShimmerBox(width: 140.w, height: 14.h, borderRadius: 4.r),
                  SizedBox(height: 8.h),
                  ShimmerBox(width: double.infinity, height: 12.h, borderRadius: 4.r),
                  SizedBox(height: 14.h),
                  ShimmerBox(width: double.infinity, height: 44.h, borderRadius: 10.r),
                ],
              ),
            ),
            SizedBox(height: 14.h),

            // 4. Timeline Card Skeleton
            Container(
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
                  ShimmerBox(width: 80.w, height: 14.h, borderRadius: 4.r),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      ShimmerBox(width: 10.w, height: 10.w, borderRadius: 5.r),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerBox(width: 100.w, height: 12.h, borderRadius: 4.r),
                            SizedBox(height: 4.h),
                            ShimmerBox(width: 140.w, height: 10.h, borderRadius: 4.r),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      ShimmerBox(width: 10.w, height: 10.w, borderRadius: 5.r),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerBox(width: 90.w, height: 12.h, borderRadius: 4.r),
                            SizedBox(height: 4.h),
                            ShimmerBox(width: 130.w, height: 10.h, borderRadius: 4.r),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),

            // 5. Items Card Skeleton
            Container(
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
                  ShimmerBox(width: 80.w, height: 14.h, borderRadius: 4.r),
                  SizedBox(height: 12.h),
                  ShimmerBox(width: double.infinity, height: 32.h, borderRadius: 8.r),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerBox(width: 120.w, height: 14.h, borderRadius: 4.r),
                      ShimmerBox(width: 30.w, height: 14.h, borderRadius: 4.r),
                      ShimmerBox(width: 60.w, height: 14.h, borderRadius: 4.r),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 8. Inventory & Stock Shimmer
// ==========================================
class InventoryCardShimmer extends StatelessWidget {
  const InventoryCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ShimmerBox(width: 42.w, height: 42.w, borderRadius: 10.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 150.w, height: 14.h, borderRadius: 4.r),
                SizedBox(height: 6.h),
                ShimmerBox(width: 90.w, height: 11.h, borderRadius: 4.r),
                SizedBox(height: 6.h),
                ShimmerBox(width: 130.w, height: 12.h, borderRadius: 4.r),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          ShimmerBox(width: 58.w, height: 32.h, borderRadius: 8.r),
        ],
      ),
    );
  }
}

class InventoryListShimmer extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry? padding;

  const InventoryListShimmer({
    super.key,
    this.itemCount = 6,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.separated(
        padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, _) => SizedBox(height: 10.h),
        itemBuilder: (_, _) => const InventoryCardShimmer(),
      ),
    );
  }
}

// ==========================================
// 9. Shimmer Pull-To-Refresh (Zero Round Spinners)
// ==========================================
class ShimmerPullToRefreshController extends GetxController {
  final RxDouble pullOffset = 0.0.obs;
  final RxBool isRefreshing = false.obs;
  static const double triggerThreshold = 60.0;

  bool handleScrollNotification(
      ScrollNotification notification, Future<void> Function() onRefresh) {
    if (isRefreshing.value) return false;

    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.pixels < 0) {
        pullOffset.value = (-notification.metrics.pixels).clamp(0.0, 90.0);
      } else if (notification.metrics.extentBefore == 0 &&
          notification.dragDetails != null &&
          notification.dragDetails!.delta.dy > 0) {
        pullOffset.value =
            (pullOffset.value + notification.dragDetails!.delta.dy * 0.45)
                .clamp(0.0, 90.0);
      }
    } else if (notification is OverscrollNotification) {
      if (notification.overscroll < 0) {
        pullOffset.value =
            (pullOffset.value - notification.overscroll * 0.45).clamp(0.0, 90.0);
      }
    } else if (notification is ScrollEndNotification) {
      if (pullOffset.value >= triggerThreshold && !isRefreshing.value) {
        triggerRefresh(onRefresh);
      } else {
        pullOffset.value = 0.0;
      }
    }
    return false;
  }

  Future<void> triggerRefresh(Future<void> Function() onRefresh) async {
    isRefreshing.value = true;
    pullOffset.value = 0.0;
    try {
      await onRefresh();
    } finally {
      isRefreshing.value = false;
    }
  }
}

/// Pull-to-refresh that displays a skeleton shimmer wave instead of
/// circular progress indicator.
class ShimmerPullToRefresh extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const ShimmerPullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ShimmerPullToRefreshController>()
        ? Get.find<ShimmerPullToRefreshController>()
        : Get.put(ShimmerPullToRefreshController());

    return NotificationListener<ScrollNotification>(
      onNotification: (n) => controller.handleScrollNotification(n, onRefresh),
      child: Column(
        children: [
          Obx(() {
            final offset = controller.pullOffset.value;
            final progress = (offset / ShimmerPullToRefreshController.triggerThreshold).clamp(0.0, 1.0);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              height: offset > 0 ? math.min(offset * 0.6, 44.0) : 0,
              alignment: Alignment.center,
              child: offset > 10
                  ? Opacity(
                      opacity: progress,
                      child: ShimmerLoading(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 24.w),
                          height: 28.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const ShimmerBox(width: 14, height: 14, borderRadius: 4),
                              SizedBox(width: 8.w),
                              ShimmerBox(
                                width: offset >= ShimmerPullToRefreshController.triggerThreshold ? 110.w : 85.w,
                                height: 11.h,
                                borderRadius: 4.r,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          }),
          Expanded(child: child),
        ],
      ),
    );
  }
}
