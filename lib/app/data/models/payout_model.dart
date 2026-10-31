class PayoutAccountModel {
  final String id;
  final String label;
  final String? bankName;
  final String? accountName;
  final String accountNumberMasked;
  final String? mobileBanking; // bKash | Nagad | Rocket
  final bool isDefault;

  PayoutAccountModel({
    required this.id,
    required this.label,
    this.bankName,
    this.accountName,
    required this.accountNumberMasked,
    this.mobileBanking,
    this.isDefault = false,
  });

  factory PayoutAccountModel.fromJson(Map<String, dynamic> json) {
    return PayoutAccountModel(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? 'Account',
      bankName: json['bankName']?.toString(),
      accountName: json['accountName']?.toString(),
      accountNumberMasked: json['accountNumberMasked']?.toString() ??
          json['mobileNumber']?.toString() ??
          '***',
      mobileBanking: json['mobileBanking']?.toString(),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

class PayoutRequestModel {
  final String id;
  final String payoutAccountLabel;
  final int amountMinor;
  final String status;
  final String? reviewNote;
  final DateTime? createdAt;

  PayoutRequestModel({
    required this.id,
    required this.payoutAccountLabel,
    required this.amountMinor,
    required this.status,
    this.reviewNote,
    this.createdAt,
  });

  String get formattedAmount => '৳${(amountMinor / 100).toStringAsFixed(2)}';

  factory PayoutRequestModel.fromJson(Map<String, dynamic> json) {
    return PayoutRequestModel(
      id: json['id']?.toString() ?? '',
      payoutAccountLabel: json['payoutAccountLabel']?.toString() ?? 'Payout Account',
      amountMinor: (json['amountMinor'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'pending',
      reviewNote: json['reviewNote']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}

