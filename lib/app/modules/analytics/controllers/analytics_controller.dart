import 'dart:developer';
import 'package:get/get.dart';
import '../../../data/models/analytics_dashboard_model.dart';
import '../../../data/models/dashboard_stats_model.dart';
import '../../../data/services/api_service.dart';

class AnalyticsController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final selectedRange = '30d'.obs;
  final ranges = ['7d', '30d', '90d'];

  final isLoading = false.obs;
  final analytics = Rxn<AnalyticsDashboardModel>();
  final summary = Rxn<AnalyticsSummaryModel>();

  @override
  void onInit() {
    super.onInit();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _api.getAnalyticsDashboard(range: selectedRange.value),
        _api.getAnalyticsSummary(),
      ]);

      final dash = results[0] as AnalyticsDashboardModel?;
      final summ = results[1] as AnalyticsSummaryModel?;

      if (summ != null) {
        summary.value = summ;
      }

      if (dash != null) {
        if (summ != null && summ.lowStockCount > 0 && dash.lowStockVariants == 0) {
          analytics.value = AnalyticsDashboardModel(
            range: dash.range,
            revenue: dash.revenue,
            orders: dash.orders,
            unitsSold: dash.unitsSold,
            avgOrderValue: dash.avgOrderValue,
            cancellationRate: dash.cancellationRate,
            avgRating: dash.avgRating,
            customers: dash.customers,
            repeatCustomersPct: dash.repeatCustomersPct,
            lowStockVariants: summ.lowStockCount,
            revenueOverTime: dash.revenueOverTime,
            topProducts: dash.topProducts,
            orderFunnel: dash.orderFunnel,
            paymentMethods: dash.paymentMethods,
            starRatings: dash.starRatings,
            approvedReviewsCount: dash.approvedReviewsCount,
            coupons: dash.coupons,
          );
        } else {
          analytics.value = dash;
        }
      }
    } catch (e) {
      log('Error fetching analytics: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setRange(String range) {
    if (selectedRange.value == range) return;
    selectedRange.value = range;
    fetchAnalytics();
  }
}

