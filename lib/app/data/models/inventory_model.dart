class InventoryProductModel {
  final String productId;
  final String productName;
  final String variantId;
  final String variantLabel;
  final String sku;
  int stockQty;
  final int lowStockThreshold;
  final bool isLowStock;

  InventoryProductModel({
    required this.productId,
    required this.productName,
    required this.variantId,
    required this.variantLabel,
    required this.sku,
    required this.stockQty,
    required this.lowStockThreshold,
    required this.isLowStock,
  });

  factory InventoryProductModel.fromJson(Map<String, dynamic> json) {
    return InventoryProductModel(
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? 'Product',
      variantId: json['variantId']?.toString() ?? '',
      variantLabel: json['variantLabel']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      stockQty: (json['stockQty'] as num?)?.toInt() ?? 0,
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 5,
      isLowStock: json['isLowStock'] as bool? ?? false,
    );
  }
}

class InventoryLedgerEntry {
  final String id;
  final String variantId;
  final String variantSku;
  final String variantLabel;
  final int changeQty; // Signed: negative for out, positive for in, either for adjustment
  final int balanceQty; // Resulting stock after this movement
  final String kind; // 'in' | 'out' | 'adjustment'
  final String referenceType; // 'manual' | 'seed' | 'order_batch'
  final String? referenceId;
  final String? note;
  final String createdBy;
  final DateTime? createdAt;

  InventoryLedgerEntry({
    required this.id,
    required this.variantId,
    required this.variantSku,
    required this.variantLabel,
    required this.changeQty,
    required this.balanceQty,
    required this.kind,
    required this.referenceType,
    this.referenceId,
    this.note,
    required this.createdBy,
    this.createdAt,
  });

  factory InventoryLedgerEntry.fromJson(Map<String, dynamic> json) {
    DateTime? dt;
    if (json['createdAt'] != null) {
      dt = DateTime.tryParse(json['createdAt'].toString());
    }

    return InventoryLedgerEntry(
      id: json['id']?.toString() ?? '',
      variantId: json['variantId']?.toString() ?? '',
      variantSku: json['variantSku']?.toString() ?? '',
      variantLabel: json['variantLabel']?.toString() ?? '',
      changeQty: (json['changeQty'] as num?)?.toInt() ?? 0,
      balanceQty: (json['balanceQty'] as num?)?.toInt() ?? 0,
      kind: json['kind']?.toString() ?? 'in',
      referenceType: json['referenceType']?.toString() ?? 'manual',
      referenceId: json['referenceId']?.toString(),
      note: json['note']?.toString(),
      createdBy: json['createdBy']?.toString() ?? '',
      createdAt: dt,
    );
  }
}
