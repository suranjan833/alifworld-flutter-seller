class CouponModel {
  final String id;
  final String code;
  final String? description;
  final String type; // 'percent' | 'flat'
  final int value;
  final int minOrderMinor;
  final int usageLimit;
  final int usedCount;
  final bool isActive;
  final DateTime? startsAt;
  final DateTime? endsAt;

  CouponModel({
    required this.id,
    required this.code,
    this.description,
    required this.type,
    required this.value,
    required this.minOrderMinor,
    this.usageLimit = 100,
    this.usedCount = 0,
    this.isActive = true,
    this.startsAt,
    this.endsAt,
  });

  String get formattedDiscount =>
      type == 'percent' ? '$value% OFF' : '৳${(value / 100).toStringAsFixed(0)} OFF';

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString().toUpperCase() ?? '',
      description: json['description']?.toString(),
      type: json['type']?.toString() ?? 'percent',
      value: (json['value'] as num?)?.toInt() ?? 0,
      minOrderMinor: (json['minOrderMinor'] as num?)?.toInt() ?? 0,
      usageLimit: (json['usageLimit'] as num?)?.toInt() ?? 100,
      usedCount: (json['usedCount'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      startsAt: json['startsAt'] != null ? DateTime.tryParse(json['startsAt']) : null,
      endsAt: json['endsAt'] != null ? DateTime.tryParse(json['endsAt']) : null,
    );
  }
}

