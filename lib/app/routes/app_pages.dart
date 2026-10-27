// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/seller_gate/bindings/seller_gate_binding.dart';
import '../modules/seller_gate/views/seller_gate_view.dart';
import '../modules/store_setup/bindings/store_setup_binding.dart';
import '../modules/store_setup/views/store_setup_view.dart';
import '../modules/onboarding_pending/bindings/onboarding_pending_binding.dart';
import '../modules/onboarding_pending/views/onboarding_pending_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/leaderboard/bindings/leaderboard_binding.dart';
import '../modules/leaderboard/views/leaderboard_view.dart';
import '../modules/coupons/bindings/coupons_binding.dart';
import '../modules/coupons/views/coupons_view.dart';
import '../modules/reviews/bindings/reviews_binding.dart';
import '../modules/reviews/views/reviews_view.dart';
import '../modules/returns/bindings/returns_binding.dart';
import '../modules/returns/views/returns_view.dart';
import '../modules/inventory/bindings/inventory_binding.dart';
import '../modules/inventory/views/inventory_view.dart';
import '../modules/payouts/bindings/payouts_binding.dart';
import '../modules/payouts/views/payouts_view.dart';
import '../modules/products/add_product/bindings/add_product_binding.dart';
import '../modules/products/add_product/views/add_product_view.dart';
import '../modules/analytics/bindings/analytics_binding.dart';
import '../modules/analytics/views/analytics_view.dart';
import '../modules/orders/order_detail/bindings/order_detail_binding.dart';
import '../modules/orders/order_detail/views/order_detail_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.ONBOARDING;

  static final routes = [
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.SELLER_GATE,
      page: () => const SellerGateView(),
      binding: SellerGateBinding(),
    ),
    GetPage(
      name: _Paths.STORE_SETUP,
      page: () => const StoreSetupView(),
      binding: StoreSetupBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING_PENDING,
      page: () => const OnboardingPendingView(),
      binding: OnboardingPendingBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LEADERBOARD,
      page: () => const LeaderboardView(),
      binding: LeaderboardBinding(),
    ),
    GetPage(
      name: _Paths.COUPONS,
      page: () => const CouponsView(),
      binding: CouponsBinding(),
    ),
    GetPage(
      name: _Paths.REVIEWS,
      page: () => const ReviewsView(),
      binding: ReviewsBinding(),
    ),
    GetPage(
      name: _Paths.RETURNS,
      page: () => const ReturnsView(),
      binding: ReturnsBinding(),
    ),
    GetPage(
      name: _Paths.INVENTORY,
      page: () => const InventoryView(),
      binding: InventoryBinding(),
    ),
    GetPage(
      name: _Paths.PAYOUTS,
      page: () => const PayoutsView(),
      binding: PayoutsBinding(),
    ),
    GetPage(
      name: _Paths.ADD_PRODUCT,
      page: () => const AddProductView(),
      binding: AddProductBinding(),
    ),
    GetPage(
      name: _Paths.ANALYTICS,
      page: () => const AnalyticsView(),
      binding: AnalyticsBinding(),
    ),
    GetPage(
      name: _Paths.ORDER_DETAIL,
      page: () => const OrderDetailView(),
      binding: OrderDetailBinding(),
    ),
  ];
}
