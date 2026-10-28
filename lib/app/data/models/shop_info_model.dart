class ShopInfoModel {
  String shopName;
  String shopSlug;
  String shopDescription;
  String? businessCategory;
  String? supportPhone;
  String? supportEmail;

  ShopInfoModel({
    this.shopName = '',
    this.shopSlug = '',
    this.shopDescription = '',
    this.businessCategory,
    this.supportPhone,
    this.supportEmail,
  });

  // Generates slug just like the website:
  // O.toLowerCase().normalize("NFKD").replace(/[\u0300-\u036f]/g,"").replace(/[^a-z0-9]+/g,"-").replace(/^-+|-+$/g,"")
  static String generateSlug(String name) {
    return name
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  Map<String, dynamic> toJson() {
    return {
      'shopName': shopName,
      'shopSlug': shopSlug,
      'shopDescription': shopDescription,
      'businessCategory': businessCategory,
      'supportPhone': supportPhone,
      'supportEmail': supportEmail,
    };
  }

  factory ShopInfoModel.fromJson(Map<String, dynamic> json) {
    return ShopInfoModel(
      shopName: json['shopName'] ?? '',
      shopSlug: json['shopSlug'] ?? '',
      shopDescription: json['shopDescription'] ?? '',
      businessCategory: json['businessCategory'],
      supportPhone: json['supportPhone'],
      supportEmail: json['supportEmail'],
    );
  }
}

