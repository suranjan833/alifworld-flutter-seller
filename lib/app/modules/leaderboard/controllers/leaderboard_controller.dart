import 'package:get/get.dart';
import '../../../data/models/leaderboard_model.dart';
import '../../../data/services/api_service.dart';
import '../../home/controllers/home_controller.dart';

class LeaderboardController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final isLoading = true.obs;
  final selectedPeriod = 'weekly'.obs; // 'daily' | 'weekly' | 'monthly' | 'yearly'
  final periods = const ['Daily', 'Weekly', 'Monthly', 'Yearly'];

  final leaderboardData = Rxn<LeaderboardDataModel>();

  @override
  void onInit() {
    super.onInit();
    fetchLeaderboard();
  }

  void changePeriod(String periodLabel) {
    final p = periodLabel.toLowerCase();
    if (selectedPeriod.value != p) {
      selectedPeriod.value = p;
      fetchLeaderboard(p);
    }
  }

  Future<void> fetchLeaderboard([String? period]) async {
    isLoading.value = true;
    final p = period ?? selectedPeriod.value;

    String currentSellerName = '';
    if (Get.isRegistered<HomeController>()) {
      currentSellerName = Get.find<HomeController>().sellerName;
    }

    try {
      final res = await _api.getLeaderboard(period: p);
      if (res != null) {
        leaderboardData.value = LeaderboardDataModel.fromJson(
          res,
          defaultPeriod: p,
          currentSellerName: currentSellerName,
        );
      } else {
        leaderboardData.value = LeaderboardDataModel(
          myRank: 0,
          totalSellers: 0,
          myRevenue: 0.0,
          myOrders: 0,
          period: p,
          sellers: [],
        );
      }
    } catch (e) {
      Get.log('Error fetching leaderboard from API: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
