import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/announcement_model.dart';
import '../../../data/models/analytics_dashboard_model.dart';
import '../../../data/models/dashboard_stats_model.dart';
import '../../../data/services/api_service.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // State Observables
  final currentNavIndex = 0.obs;
  final isLoading = false.obs;
  final isAnnouncementsLoading = false.obs;
  final isStatsLoading = false.obs;
  final productCatalogRefreshTrigger = 0.obs;

  void triggerCatalogRefresh() {
    productCatalogRefreshTrigger.value++;
  }

  void changeNavIndex(int index) {
    currentNavIndex.value = index;
  }

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  // Contract: 7D / 30D / 90D only, default 30D
  final selectedRange = '30d'.obs;
  final List<String> availableRanges = const ['7d', '30d', '90d'];

  // Data from the 3 dashboard calls
  final userData = Rxn<Map<String, dynamic>>();
  final announcements = <AnnouncementModel>[].obs;
  final dashboardStats = Rxn<DashboardStatsModel>(); // Call 1
  final analyticsSummary = Rxn<AnalyticsSummaryModel>(); // Call 2
  final growthAnalytics = Rxn<AnalyticsDashboardModel>(); // Call 3

  // Announcements getters
  List<AnnouncementModel> get unreadAnnouncements =>
      announcements.where((a) => !a.isRead).toList();

  int get unreadCount => unreadAnnouncements.length;

  List<AnnouncementModel> get urgentAnnouncements =>
      announcements.where((a) => a.priority == AnnouncementPriority.urgent && !a.isRead).toList();

  String get timeGreeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good evening';
    } else {
      return 'Good night';
    }
  }

  String get greetingIcon {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return '🌅';
    } else if (hour >= 12 && hour < 17) {
      return '☀️';
    } else if (hour >= 17 && hour < 21) {
      return '🌇';
    } else {
      return '🌙';
    }
  }

  String get sellerName {
    final user = userData.value;
    if (user != null) {
      final fName = user['firstName'] ?? '';
      final lName = user['lastName'] ?? '';
      if (fName.isNotEmpty || lName.isNotEmpty) return '$fName $lName'.trim();
    }
    return 'Seller Partner';
  }

  String get sellerStatus {
    return userData.value?['sellerStatus']?.toString().toUpperCase() ?? 'APPROVED';
  }

  @override
  void onInit() {
    super.onInit();
    loadAllData();
  }

  /// Gated load: only calls dashboard endpoints if seller is approved
  Future<void> loadAllData() async {
    isLoading.value = true;
    try {
      final user = await _api.getProfile();
      if (user != null) {
        userData.value = user;
        final status = user['sellerStatus']?.toString().toLowerCase();
        if (status == 'pending') {
          isLoading.value = false;
          Get.offAllNamed(Routes.ONBOARDING_PENDING);
          return;
        } else if (status != null && status != 'approved') {
          isLoading.value = false;
          Get.offAllNamed(Routes.STORE_SETUP);
          return;
        }
      }

      // Approved seller -> load the 3 calls + announcements
      await Future.wait([
        fetchAnnouncements(),
        fetchDashboardStats(),
        fetchAnalyticsSummary(),
        fetchGrowthAnalytics(),
      ]);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      final user = await _api.getProfile();
      if (user != null) {
        userData.value = user;
      }
    } catch (_) {}
  }

  Future<void> fetchAnnouncements() async {
    isAnnouncementsLoading.value = true;
    try {
      final list = await _api.getAnnouncements();
      announcements.assignAll(list);
    } catch (_) {
    } finally {
      isAnnouncementsLoading.value = false;
    }
  }

  /// Call 1: GET /seller/dashboard/stats?range=...
  Future<void> fetchDashboardStats() async {
    try {
      final stats = await _api.getDashboardStats(range: selectedRange.value);
      if (stats != null) {
        dashboardStats.value = stats;
      }
    } catch (_) {}
  }

  /// Call 2: GET /seller/analytics/summary
  Future<void> fetchAnalyticsSummary() async {
    try {
      final summary = await _api.getAnalyticsSummary();
      if (summary != null) {
        analyticsSummary.value = summary;
      }
    } catch (_) {}
  }

  /// Call 3: GET /seller/analytics/dashboard?range=...
  Future<void> fetchGrowthAnalytics() async {
    try {
      final growth = await _api.getAnalyticsDashboard(range: selectedRange.value);
      if (growth != null) {
        growthAnalytics.value = growth;
      }
    } catch (_) {}
  }

  /// Range change: Stale-while-revalidate, refetches Call 1 + Call 3 together. Call 2 untouched.
  void changeDateRange(String newRange) {
    if (selectedRange.value == newRange) return;
    selectedRange.value = newRange;
    fetchDashboardStatsAndGrowth();
  }

  Future<void> fetchDashboardStatsAndGrowth() async {
    isStatsLoading.value = true;
    await Future.wait([
      fetchDashboardStats(),
      fetchGrowthAnalytics(),
    ]);
    isStatsLoading.value = false;
  }

  /// Mark single announcement as read
  Future<void> markAnnouncementAsRead(AnnouncementModel announcement) async {
    if (announcement.isRead) return;

    final success = await _api.markAnnouncementAsRead(announcement.id);
    if (success) {
      final index = announcements.indexWhere((a) => a.id == announcement.id);
      if (index != -1) {
        announcements[index] = announcements[index].copyWith(isRead: true);
      }
      // Decrement summary counter if available
      if (analyticsSummary.value != null && analyticsSummary.value!.announcementsUnread > 0) {
        analyticsSummary.value = AnalyticsSummaryModel(
          productsTotal: analyticsSummary.value!.productsTotal,
          productsLive: analyticsSummary.value!.productsLive,
          productsPending: analyticsSummary.value!.productsPending,
          lowStockCount: analyticsSummary.value!.lowStockCount,
          couponsActive: analyticsSummary.value!.couponsActive,
          reviewsPending: analyticsSummary.value!.reviewsPending,
          announcementsUnread: analyticsSummary.value!.announcementsUnread - 1,
        );
      }
    }
  }

  /// Mark all announcements as read
  Future<void> markAllAsRead() async {
    final unread = unreadAnnouncements;
    if (unread.isEmpty) return;

    for (var a in unread) {
      await markAnnouncementAsRead(a);
    }
    Get.snackbar(
      'Announcements Updated',
      'All announcements marked as read.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> logout() async {
    await _api.logout();
    Get.offAllNamed(Routes.SELLER_GATE);
  }
}
