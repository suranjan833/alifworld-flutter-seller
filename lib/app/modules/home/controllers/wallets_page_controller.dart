import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../data/services/api_service.dart';

class WalletsPageController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final RxBool isLoading = true.obs;
  final RxList<dynamic> wallets = <dynamic>[].obs;
  final RxList<dynamic> transactions = <dynamic>[].obs;
  final RxList<dynamic> payoutAccounts = <dynamic>[].obs;

  final Map<String, String> walletNames = const {
    'seller_main': 'Main Withdrawable',
    'seller_total_sales': 'Total Sales',
    'seller_club_bonus': 'Club Bonus',
    'seller_star_bonus': 'Star Bonus',
    'seller_total_point': 'Total Reward Points',
    'seller_good_luck': 'Good Luck Bonus',
    'seller_charity': 'Charity Fund (View-only)',
  };

  final Map<String, String> walletDescriptions = const {
    'seller_main': 'Primary withdrawable balance for payouts',
    'seller_total_sales': 'Total gross sales from customer orders',
    'seller_club_bonus': 'Special club tier performance earnings',
    'seller_star_bonus': 'Rating rewards & performance bonuses',
    'seller_total_point': 'Accrued loyalty and reward points',
    'seller_good_luck': 'Promotional campaign bonus funds',
    'seller_charity': 'Charity fund allocations (view-only)',
  };

  final Map<String, IconData> walletIcons = const {
    'seller_main': Iconsax.wallet_3,
    'seller_total_sales': Iconsax.chart_21,
    'seller_club_bonus': Iconsax.crown_1,
    'seller_star_bonus': Iconsax.star_1,
    'seller_total_point': Iconsax.medal_star,
    'seller_good_luck': Iconsax.gift,
    'seller_charity': Iconsax.heart,
  };

  @override
  void onInit() {
    super.onInit();
    loadAllWalletData();
  }

  Future<void> loadAllWalletData() async {
    isLoading.value = true;
    try {
      final walletRes = await _api.getSellerWallets();
      final accountsRes = await _api.getPayoutAccounts();
      if (walletRes != null) {
        wallets.value = (walletRes['items'] as List<dynamic>?) ?? [];
        transactions.value = (walletRes['transactions'] as List<dynamic>?) ?? [];
      } else {
        wallets.clear();
        transactions.clear();
      }
      payoutAccounts.value = accountsRes;
    } catch (_) {
      wallets.clear();
      transactions.clear();
      payoutAccounts.clear();
    } finally {
      isLoading.value = false;
    }
  }

  double get combinedBalanceMinor {
    double total = 0;
    for (var w in wallets) {
      total += (w['balanceMinor'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }

  Future<bool> submitPayout({
    required String payoutAccountId,
    required int amountMinor,
  }) async {
    final res = await _api.requestPayout(
      payoutAccountId: payoutAccountId,
      amountMinor: amountMinor,
    );
    if (res != null) {
      await loadAllWalletData();
      return true;
    }
    return false;
  }
}
