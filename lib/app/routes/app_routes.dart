// ignore_for_file: constant_identifier_names

part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const ONBOARDING = _Paths.ONBOARDING;
  static const SELLER_GATE = _Paths.SELLER_GATE;
  static const STORE_SETUP = _Paths.STORE_SETUP;
  static const ONBOARDING_PENDING = _Paths.ONBOARDING_PENDING;
  static const HOME = _Paths.HOME;
  static const LEADERBOARD = _Paths.LEADERBOARD;
  static const COUPONS = _Paths.COUPONS;
  static const REVIEWS = _Paths.REVIEWS;
  static const RETURNS = _Paths.RETURNS;
  static const INVENTORY = _Paths.INVENTORY;
  static const PAYOUTS = _Paths.PAYOUTS;
  static const ADD_PRODUCT = _Paths.ADD_PRODUCT;
  static const ANALYTICS = _Paths.ANALYTICS;
  static const ORDER_DETAIL = _Paths.ORDER_DETAIL;
}

abstract class _Paths {
  _Paths._();
  static const ONBOARDING = '/onboarding';
  static const SELLER_GATE = '/seller-gate';
  static const STORE_SETUP = '/store-setup';
  static const ONBOARDING_PENDING = '/onboarding-pending';
  static const HOME = '/home';
  static const LEADERBOARD = '/leaderboard';
  static const COUPONS = '/coupons';
  static const REVIEWS = '/reviews';
  static const RETURNS = '/returns';
  static const INVENTORY = '/inventory';
  static const PAYOUTS = '/payouts';
  static const ADD_PRODUCT = '/add-product';
  static const ANALYTICS = '/analytics';
  static const ORDER_DETAIL = '/order-detail';
}
