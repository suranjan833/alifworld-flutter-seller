class ReviewModel {
  final String id;
  final String customerName;
  final String productName;
  final double rating;
  final String comment;
  final String status;
  final String? reply;
  final DateTime? createdAt;

  ReviewModel({
    required this.id,
    required this.customerName,
    required this.productName,
    required this.rating,
    required this.comment,
    required this.status,
    this.reply,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    final product = json['product'] as Map<String, dynamic>?;
    return ReviewModel(
      id: json['id']?.toString() ?? '',
      customerName: customer?['name']?.toString() ?? json['customerName']?.toString() ?? 'Customer',
      productName: product?['name']?.toString() ?? json['productName']?.toString() ?? 'Purchased Item',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      comment: json['comment']?.toString() ?? json['content']?.toString() ?? 'Great product!',
      status: json['status']?.toString() ?? 'approved',
      reply: json['reply']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}

