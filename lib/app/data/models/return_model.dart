class ReturnModel {
  final String id;
  final String orderNumber;
  final String status;
  final String reason;
  final String customerName;
  final int refundAmountMinor;
  final String productName;
  final DateTime? createdAt;

  ReturnModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.reason,
    required this.customerName,
    required this.refundAmountMinor,
    required this.productName,
    this.createdAt,
  });

  String get formattedRefund => '৳${(refundAmountMinor / 100).toStringAsFixed(2)}';

  factory ReturnModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    final item = json['item'] as Map<String, dynamic>?;
    return ReturnModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? 'ORD-000',
      status: json['status']?.toString() ?? 'requested',
      reason: json['reason']?.toString() ?? 'Defective or wrong item',
      customerName: customer?['name']?.toString() ?? json['customerName']?.toString() ?? 'Customer',
      refundAmountMinor: (json['refundAmountMinor'] as num?)?.toInt() ?? 0,
      productName: item?['name']?.toString() ?? json['productName']?.toString() ?? 'Return Item',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}

