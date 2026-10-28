class BrandingModel {
  String? logoUrl;
  String? logoPath;
  String? bannerUrl;
  String? bannerPath;
  String policies;

  BrandingModel({
    this.logoUrl,
    this.logoPath,
    this.bannerUrl,
    this.bannerPath,
    this.policies = '',
  });

  Map<String, dynamic> toJson() {
    return {'logoUrl': logoUrl, 'bannerUrl': bannerUrl, 'policies': policies};
  }

  factory BrandingModel.fromJson(Map<String, dynamic> json) {
    return BrandingModel(
      logoUrl: json['logoUrl'] as String?,
      bannerUrl: json['bannerUrl'] as String?,
      policies: json['policies'] as String? ?? '',
    );
  }
}
