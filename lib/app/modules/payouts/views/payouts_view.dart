import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../data/models/payout_model.dart';
import '../../../data/theme/app_colors.dart';
import '../../../data/widgets/shimmer_widget.dart';
import '../controllers/payouts_controller.dart';

class PayoutsView extends GetView<PayoutsController> {
  const PayoutsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Iconsax.arrow_left,
            color: AppColors.textPrimary,
            size: 22,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Payouts',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(
              Iconsax.refresh,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: controller.loadAllData,
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const WalletOverviewShimmer();
        }

        return RefreshIndicator(
          onRefresh: controller.loadAllData,
          color: const Color(0xFFFF630F),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Payouts',
                      style: GoogleFonts.inter(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        'Manage where your earnings are sent.',
                        textAlign: TextAlign.end,
                        style: GoogleFonts.inter(
                          fontSize: 11.5.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Card 1: Payout Accounts (With Inline Add Account Form)
                _buildPayoutAccountsCard(context),
                SizedBox(height: 16.h),

                // Card 2: Request Payout
                _buildRequestPayoutCard(context),
                SizedBox(height: 16.h),

                // Card 3: Payout History
                _buildPayoutHistoryCard(context),
              ],
            ),
          ),
        );
      }),
    );
  }

  // =========================================================================
  // CARD 1: Payout accounts (With Inline Add Account Form as in Web Screenshot)
  // =========================================================================
  Widget _buildPayoutAccountsCard(BuildContext context) {
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payout accounts',
                style: GoogleFonts.inter(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Obx(() {
                if (controller.showAddAccountForm.value) {
                  return const SizedBox.shrink();
                }
                return OutlinedButton(
                  onPressed: controller.toggleAddAccountForm,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 6.h,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Add account',
                    style: GoogleFonts.inter(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: 14.h),

          // INLINE FORM: When "Add account" is clicked
          Obx(() {
            if (!controller.showAddAccountForm.value) {
              return const SizedBox.shrink();
            }

            return Container(
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Label * & Provider *
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 500;
                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildLabelField()),
                            SizedBox(width: 14.w),
                            Expanded(child: _buildProviderField()),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabelField(),
                          SizedBox(height: 12.h),
                          _buildProviderField(),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 12.h),

                  // Row 2: Account number * & Account holder name
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 500;
                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildAccountNumberField()),
                            SizedBox(width: 14.w),
                            Expanded(child: _buildAccountHolderField()),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAccountNumberField(),
                          SizedBox(height: 12.h),
                          _buildAccountHolderField(),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Row 3: Action Buttons [Save] and [Cancel]
                  Row(
                    children: [
                      Obx(() {
                        final isSaving = controller.isAddingAccount.value;
                        return ElevatedButton(
                          onPressed: isSaving
                              ? null
                              : controller.addPayoutAccount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF630F),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                              horizontal: 22.w,
                              vertical: 10.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: isSaving
                              ? SizedBox(
                                  width: 16.w,
                                  height: 16.w,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Save',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        );
                      }),
                      SizedBox(width: 10.w),
                      OutlinedButton(
                        onPressed: controller.toggleAddAccountForm,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 10.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          // Content Box: Empty state or List of Accounts
          Obx(() {
            if (controller.accounts.isEmpty) {
              return _buildDashedEmptyBox(
                icon: Iconsax.box,
                title: 'No payout accounts yet.',
              );
            }

            return Column(
              children: controller.accounts.map((acc) {
                return _buildAccountItem(context, acc);
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLabelField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Label *'),
        SizedBox(height: 5.h),
        TextField(
          controller: controller.labelController,
          style: GoogleFonts.inter(fontSize: 13.sp),
          decoration: _buildInputDecoration(hint: ''),
        ),
        SizedBox(height: 4.h),
        Text(
          'A nickname for this account, e.g. Personal bKash.',
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Provider *'),
        SizedBox(height: 5.h),
        Obx(() {
          return DropdownButtonFormField<String>(
            initialValue: controller.provider.value,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: const Color(0xFF1E293B),
            ),
            decoration: _buildInputDecoration(hint: ''),
            items: controller.providerList.map((p) {
              return DropdownMenuItem<String>(value: p, child: Text(p));
            }).toList(),
            onChanged: (val) {
              if (val != null) controller.provider.value = val;
            },
          );
        }),
      ],
    );
  }

  Widget _buildAccountNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Account number *'),
        SizedBox(height: 5.h),
        TextField(
          controller: controller.accountNumberController,
          keyboardType: TextInputType.phone,
          style: GoogleFonts.inter(fontSize: 13.sp),
          decoration: _buildInputDecoration(hint: ''),
        ),
      ],
    );
  }

  Widget _buildAccountHolderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Account holder name'),
        SizedBox(height: 5.h),
        TextField(
          controller: controller.accountHolderNameController,
          style: GoogleFonts.inter(fontSize: 13.sp),
          decoration: _buildInputDecoration(hint: ''),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: Color(0xFFFF630F), width: 1.2),
      ),
    );
  }

  Widget _buildAccountItem(BuildContext context, PayoutAccountModel acc) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Icon(
              acc.mobileBanking != null ? Iconsax.mobile : Iconsax.bank,
              size: 20.sp,
              color: const Color(0xFFFF630F),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        acc.label,
                        style: GoogleFonts.inter(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    if (acc.isDefault) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 1.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'Default',
                          style: GoogleFonts.inter(
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  '${acc.mobileBanking ?? acc.bankName ?? "Account"} • ${acc.accountNumberMasked}',
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Iconsax.trash, size: 18, color: Color(0xFFEF4444)),
            tooltip: 'Remove',
            onPressed: () => _confirmDeleteAccount(context, acc),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // CARD 2: Request payout (Matches Screenshot Exactly)
  // =========================================================================
  Widget _buildRequestPayoutCard(BuildContext context) {
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
            'Request payout',
            style: GoogleFonts.inter(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 14.h),

          // Payout account *
          Text(
            'Payout account *',
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          SizedBox(height: 6.h),
          Obx(() {
            final accList = controller.accounts;
            final selectedVal = controller.selectedAccountId.value;

            return DropdownButtonFormField<String>(
              initialValue: accList.any((a) => a.id == selectedVal)
                  ? selectedVal
                  : null,
              style: GoogleFonts.inter(
                fontSize: 13.5.sp,
                color: const Color(0xFF1E293B),
              ),
              decoration: InputDecoration(
                hintText: 'Select a payout account...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: const Color(0xFF94A3B8),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(
                    color: Color(0xFFFF630F),
                    width: 1.4,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(
                    color: Color(0xFFFF630F),
                    width: 1.4,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(
                    color: Color(0xFFFF630F),
                    width: 1.6,
                  ),
                ),
              ),
              items: accList.map((acc) {
                return DropdownMenuItem<String>(
                  value: acc.id,
                  child: Text(
                    '${acc.label} (${acc.accountNumberMasked})',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) => controller.selectedAccountId.value = val,
            );
          }),
          SizedBox(height: 14.h),

          // Amount (minor units) *
          Text(
            'Amount (minor units) *',
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: controller.amountController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(fontSize: 13.5.sp),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(
                  color: Color(0xFFFF630F),
                  width: 1.2,
                ),
              ),
            ),
          ),
          SizedBox(height: 5.h),

          // Helper Text & Live Taka Preview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Amounts are entered in minor units (for example, cents or poisha).',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              Obx(() {
                if (controller.calculatedTaka.value > 0) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '= ৳${controller.calculatedTaka.value.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
          SizedBox(height: 16.h),

          // Submit Button (Orange)
          Obx(() {
            final isBusy = controller.isSubmittingPayout.value;

            return ElevatedButton(
              onPressed: isBusy ? null : controller.submitPayoutRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF630F),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 11.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: isBusy
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Submit',
                      style: GoogleFonts.inter(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            );
          }),
        ],
      ),
    );
  }

  // =========================================================================
  // CARD 3: Payout history
  // =========================================================================
  Widget _buildPayoutHistoryCard(BuildContext context) {
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
            'Payout history',
            style: GoogleFonts.inter(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 14.h),

          Obx(() {
            if (controller.payouts.isEmpty) {
              return _buildDashedEmptyBox(
                icon: Iconsax.box,
                title: 'No payouts yet.',
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.payouts.length,
              separatorBuilder: (_, _) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final p = controller.payouts[index];
                return _buildPayoutItem(p);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPayoutItem(PayoutRequestModel p) {
    Color statusBg;
    Color statusColor;

    switch (p.status.toLowerCase()) {
      case 'approved':
      case 'completed':
        statusBg = const Color(0xFFECFDF5);
        statusColor = const Color(0xFF059669);
        break;
      case 'rejected':
      case 'failed':
        statusBg = const Color(0xFFFEF2F2);
        statusColor = const Color(0xFFDC2626);
        break;
      default:
        statusBg = const Color(0xFFFFFBEB);
        statusColor = const Color(0xFFD97706);
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                p.formattedAmount,
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  p.status.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                p.payoutAccountLabel,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: const Color(0xFF475569),
                ),
              ),
              if (p.createdAt != null)
                Text(
                  '${p.createdAt!.day}/${p.createdAt!.month}/${p.createdAt!.year}',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
            ],
          ),
          if (p.reviewNote != null && p.reviewNote!.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                'Note: ${p.reviewNote}',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================================
  // EMPTY STATE (Matches web dashed box with 3D isometric box icon)
  // =========================================================================
  Widget _buildDashedEmptyBox({required IconData icon, required String title}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 36.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: const Color(0xFFCBD5E1),
          style: BorderStyle.solid,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 38.sp, color: const Color(0xFF64748B)),
          SizedBox(height: 12.h),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, PayoutAccountModel acc) {
    Get.defaultDialog(
      title: 'Remove Account',
      titleStyle: GoogleFonts.inter(
        fontWeight: FontWeight.bold,
        fontSize: 16.sp,
      ),
      middleText: 'Are you sure you want to remove "${acc.label}"?',
      middleTextStyle: GoogleFonts.inter(fontSize: 13.sp),
      textConfirm: 'Remove',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFEF4444),
      onConfirm: () {
        Get.back();
        controller.deleteAccount(acc.id);
      },
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF334155),
      ),
    );
  }
}
