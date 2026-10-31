import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/payout_model.dart';
import '../../../data/services/api_service.dart';

class PayoutsController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  // Page Loading & Submitting State
  final isLoading = true.obs;
  final isSubmittingPayout = false.obs;
  final isAddingAccount = false.obs;

  // Data lists
  final accounts = <PayoutAccountModel>[].obs;
  final payouts = <PayoutRequestModel>[].obs;

  // Request Payout Form
  final selectedAccountId = RxnString();
  final amountController = TextEditingController();
  final calculatedTaka = 0.0.obs;

  // Inline "Add Account" Form State & Fields (Matches Web Panel)
  final showAddAccountForm = false.obs;
  final labelController = TextEditingController();
  final provider = 'bKash'.obs; // 'bKash' | 'Nagad' | 'Rocket' | 'Bank'
  final accountNumberController = TextEditingController();
  final accountHolderNameController = TextEditingController();
  final isDefaultAccount = true.obs;

  final List<String> providerList = ['bKash', 'Nagad', 'Rocket', 'Bank'];

  @override
  void onInit() {
    super.onInit();
    amountController.addListener(_onAmountChanged);
    loadAllData();
  }

  void _onAmountChanged() {
    final minor = int.tryParse(amountController.text.trim()) ?? 0;
    calculatedTaka.value = minor / 100.0;
  }

  @override
  void onClose() {
    amountController.removeListener(_onAmountChanged);
    amountController.dispose();
    labelController.dispose();
    accountNumberController.dispose();
    accountHolderNameController.dispose();
    super.onClose();
  }

  void toggleAddAccountForm() {
    showAddAccountForm.value = !showAddAccountForm.value;
    if (!showAddAccountForm.value) {
      clearAddAccountForm();
    }
  }

  void clearAddAccountForm() {
    labelController.clear();
    accountNumberController.clear();
    accountHolderNameController.clear();
    provider.value = 'bKash';
    isDefaultAccount.value = true;
  }

  Future<void> loadAllData() async {
    isLoading.value = true;
    await Future.wait([
      fetchAccounts(),
      fetchPayouts(),
    ]);
    isLoading.value = false;
  }

  Future<void> fetchAccounts() async {
    try {
      final list = await _api.getPayoutAccounts();
      accounts.value = list
          .map((item) => PayoutAccountModel.fromJson(item as Map<String, dynamic>))
          .toList();

      // Set default selected account if not set or invalid
      if (accounts.isNotEmpty) {
        final hasCurrent = accounts.any((a) => a.id == selectedAccountId.value);
        if (!hasCurrent) {
          final defaultAcc = accounts.firstWhere(
            (a) => a.isDefault,
            orElse: () => accounts.first,
          );
          selectedAccountId.value = defaultAcc.id;
        }
      } else {
        selectedAccountId.value = null;
      }
    } catch (_) {}
  }

  Future<void> fetchPayouts() async {
    try {
      final list = await _api.getPayouts();
      payouts.value = list
          .map((item) => PayoutRequestModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {}
  }

  /// Request Payout (`POST /seller/payouts`)
  Future<bool> submitPayoutRequest() async {
    final accountId = selectedAccountId.value;
    if (accountId == null || accountId.isEmpty) {
      Get.snackbar(
        'Account Required',
        'Please select a payout account first.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
      );
      return false;
    }

    final amountMinor = int.tryParse(amountController.text.trim()) ?? 0;
    if (amountMinor <= 0) {
      Get.snackbar(
        'Invalid Amount',
        'Please enter a valid amount in minor units (e.g. 50000 = ৳500).',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }

    isSubmittingPayout.value = true;
    final res = await _api.requestPayout(
      payoutAccountId: accountId,
      amountMinor: amountMinor,
    );
    isSubmittingPayout.value = false;

    if (res != null && res['error'] == null) {
      amountController.clear();
      calculatedTaka.value = 0.0;
      Get.snackbar(
        'Payout Requested',
        'Withdrawal request for ৳${(amountMinor / 100).toStringAsFixed(2)} submitted for admin review.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
      await fetchPayouts();
      return true;
    } else {
      final errorMsg = res?['error']?.toString() ??
          'Unable to process payout request. Ensure sufficient wallet balance.';
      Get.snackbar(
        'Request Failed',
        errorMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// Create Payout Account (`POST /seller/payout-accounts`)
  Future<bool> addPayoutAccount() async {
    final label = labelController.text.trim();
    final accNum = accountNumberController.text.trim();
    final holderName = accountHolderNameController.text.trim();

    if (label.isEmpty) {
      Get.snackbar(
        'Field Required',
        'Please enter an account label.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
      );
      return false;
    }
    if (accNum.isEmpty) {
      Get.snackbar(
        'Field Required',
        'Please enter an account number.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
      );
      return false;
    }

    final name = holderName.isNotEmpty ? holderName : label;

    final Map<String, dynamic> payload = {
      'label': label,
      'accountName': name,
      'accountNumber': accNum,
      'isDefault': isDefaultAccount.value,
    };

    if (provider.value == 'Bank') {
      payload['bankName'] = 'Bank';
    } else {
      payload['mobileBanking'] = provider.value;
      payload['mobileNumber'] = accNum;
    }

    isAddingAccount.value = true;
    final res = await _api.createPayoutAccount(payload);
    isAddingAccount.value = false;

    if (res != null && res['error'] == null) {
      clearAddAccountForm();
      showAddAccountForm.value = false;

      Get.snackbar(
        'Account Added',
        'Payout account "$label" successfully connected.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
      await fetchAccounts();
      return true;
    } else {
      final errorMsg = res?['error']?.toString() ??
          'Could not save payout account. Please check details and try again.';
      Get.snackbar(
        'Failed to Add Account',
        errorMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// Delete Payout Account (`DELETE /seller/payout-accounts/{id}`)
  Future<void> deleteAccount(String accountId) async {
    final ok = await _api.deletePayoutAccount(accountId);
    if (ok) {
      Get.snackbar(
        'Account Removed',
        'Payout account removed successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      await fetchAccounts();
    } else {
      Get.snackbar(
        'Delete Failed',
        'Could not delete payout account.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
