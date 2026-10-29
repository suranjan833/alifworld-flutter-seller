import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../data/theme/app_colors.dart';
import '../../../data/widgets/shimmer_widget.dart';
import '../controllers/wallets_page_controller.dart';

class WalletsSheet extends GetView<WalletsPageController> {
  const WalletsSheet({super.key});

  static Future<void> show(BuildContext context) {
    if (!Get.isRegistered<WalletsPageController>()) {
      Get.put(WalletsPageController());
    }
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WalletsSheet(),
    );
  }

  void _showPayoutDialog(BuildContext context, WalletsPageController walletsCtrl) {
    if (walletsCtrl.payoutAccounts.isEmpty) {
      Get.snackbar(
        'Add Payout Account',
        'Please add a bank or mobile banking (bKash/Nagad) account first.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final amountController = TextEditingController();
    final selectedAccountId = (walletsCtrl.payoutAccounts.first['id']?.toString() ?? '').obs;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Request Payout',
          style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Account:', style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textSecondary)),
            SizedBox(height: 6.h),
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: selectedAccountId.value,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                items: walletsCtrl.payoutAccounts.map((acc) {
                  final label = acc['label'] ?? acc['bankName'] ?? acc['mobileBanking'] ?? 'Account';
                  final masked = acc['accountNumberMasked'] ?? '';
                  return DropdownMenuItem<String>(
                    value: acc['id']?.toString() ?? '',
                    child: Text('$label ($masked)', style: TextStyle(fontSize: 13.sp)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) selectedAccountId.value = val;
                },
              ),
            ),
            SizedBox(height: 14.h),
            Text('Withdrawal Amount (৳ BDT):', style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textSecondary)),
            SizedBox(height: 6.h),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 500',
                prefixText: '৳ ',
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final amountTaka = double.tryParse(amountController.text.trim()) ?? 0;
              if (amountTaka <= 0) {
                Get.snackbar('Invalid Amount', 'Enter a valid amount to withdraw.', snackPosition: SnackPosition.TOP);
                return;
              }
              final amountMinor = (amountTaka * 100).toInt();
              Navigator.pop(ctx);

              final success = await walletsCtrl.submitPayout(
                payoutAccountId: selectedAccountId.value,
                amountMinor: amountMinor,
              );

              if (success) {
                Get.snackbar(
                  'Payout Requested',
                  'Your payout request for ৳${amountTaka.toStringAsFixed(2)} was submitted.',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  'Request Failed',
                  'Could not submit payout request. Check your balance.',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.redAccent,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletsCtrl = Get.isRegistered<WalletsPageController>()
        ? controller
        : Get.put(WalletsPageController());

    return Container(
      height: 0.90.sh,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // Drag handle
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 12.h),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3E8FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.card_pos,
                    color: const Color(0xFF8B5CF6),
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wallets & Payouts',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '7-Wallet balances & settlement',
                        style: GoogleFonts.inter(
                          fontSize: 11.5.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Iconsax.refresh, size: 20),
                  onPressed: walletsCtrl.loadAllWalletData,
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),

          // Content
          Expanded(
            child: Obx(() {
              if (walletsCtrl.isLoading.value) {
                return const WalletOverviewShimmer();
              }
              return RefreshIndicator(
                onRefresh: walletsCtrl.loadAllWalletData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Primary Withdrawable Balance Hero Card
                      _buildMainWalletHero(context, walletsCtrl),
                      SizedBox(height: 16.h),

                      // All 7 Seller Wallets Grid
                      Text(
                        'All Seller Wallets',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      _buildWalletsList(walletsCtrl),
                      SizedBox(height: 20.h),

                      // Recent Transactions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Transactions',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Last 20 entries',
                            style: GoogleFonts.inter(fontSize: 11.sp, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      _buildTransactionsList(walletsCtrl),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMainWalletHero(BuildContext context, WalletsPageController walletsCtrl) {
    final taka = (walletsCtrl.combinedBalanceMinor / 100).toStringAsFixed(2);

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Combined Wallet Balance',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'BDT ৳',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '৳$taka',
            style: GoogleFonts.inter(
              fontSize: 26.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Iconsax.export_1, color: Color(0xFF6D28D9), size: 18),
              label: Text(
                'Request Payout',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6D28D9),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              onPressed: () => _showPayoutDialog(context, walletsCtrl),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletsList(WalletsPageController walletsCtrl) {
    final allKinds = [
      'seller_main',
      'seller_total_sales',
      'seller_club_bonus',
      'seller_star_bonus',
      'seller_total_point',
      'seller_good_luck',
      'seller_charity',
    ];

    return Column(
      children: allKinds.map((kind) {
        double balanceMinor = 0;
        for (var w in walletsCtrl.wallets) {
          if (w['kind'] == kind) {
            balanceMinor = (w['balanceMinor'] as num?)?.toDouble() ?? 0;
            break;
          }
        }
        final taka = (balanceMinor / 100).toStringAsFixed(2);
        final name = walletsCtrl.walletNames[kind] ?? kind;
        final description = walletsCtrl.walletDescriptions[kind] ?? kind;
        final icon = walletsCtrl.walletIcons[kind] ?? Iconsax.wallet;

        return Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, size: 18.sp, color: AppColors.primary),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '৳$taka',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTransactionsList(WalletsPageController walletsCtrl) {
    if (walletsCtrl.transactions.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            'No transactions recorded yet.',
            style: GoogleFonts.inter(fontSize: 12.5.sp, color: AppColors.textMuted),
          ),
        ),
      );
    }

    return Column(
      children: walletsCtrl.transactions.map((tx) {
        final type = tx['type']?.toString().toLowerCase() ?? 'credit';
        final isCredit = type == 'credit';
        final amountMinor = (tx['amountMinor'] as num?)?.toDouble() ?? 0;
        final taka = (amountMinor / 100).toStringAsFixed(2);
        final note = tx['note']?.toString() ?? 'settlement';
        final walletKind = tx['walletKind']?.toString() ?? 'seller_main';

        return Container(
          margin: EdgeInsets.only(bottom: 6.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(
                isCredit ? Iconsax.arrow_down_2 : Iconsax.arrow_up_3,
                size: 16.sp,
                color: isCredit ? AppColors.success : AppColors.error,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.replaceAll('_', ' ').toUpperCase(),
                      style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      walletKind,
                      style: GoogleFonts.inter(fontSize: 10.sp, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Text(
                '${isCredit ? "+" : "-"}৳$taka',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: isCredit ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
