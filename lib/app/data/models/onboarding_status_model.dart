enum OnboardingStatus {
  draft,
  pending,
  approved,
  rejected,
  suspended,
}

class SellerOnboardingProfile {
  final String id;
  final String shopName;
  final String slug;
  final OnboardingStatus status;
  final String description;
  final String? logoUrl;
  final String? bannerUrl;
  final String policies;
  final String? rejectionReason;

  SellerOnboardingProfile({
    this.id = '',
    this.shopName = '',
    this.slug = '',
    this.status = OnboardingStatus.draft,
    this.description = '',
    this.logoUrl,
    this.bannerUrl,
    this.policies = '',
    this.rejectionReason,
  });

  factory SellerOnboardingProfile.fromJson(Map<String, dynamic> json) {
    OnboardingStatus parseStatus(String? st) {
      switch (st?.toLowerCase()) {
        case 'approved':
          return OnboardingStatus.approved;
        case 'pending':
          return OnboardingStatus.pending;
        case 'rejected':
          return OnboardingStatus.rejected;
        case 'suspended':
          return OnboardingStatus.suspended;
        default:
          return OnboardingStatus.draft;
      }
    }

    return SellerOnboardingProfile(
      id: json['id']?.toString() ?? '',
      shopName: json['shopName']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      status: parseStatus(json['status']?.toString()),
      description: json['description']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString(),
      bannerUrl: json['bannerUrl']?.toString(),
      policies: json['policies']?.toString() ?? '',
      rejectionReason: json['rejectionReason']?.toString(),
    );
  }
}

class OnboardingStepsCompletion {
  final bool shop;
  final bool branding;
  final bool compliance;
  final bool kyc;
  final bool review;

  OnboardingStepsCompletion({
    this.shop = false,
    this.branding = false,
    this.compliance = false,
    this.kyc = false,
    this.review = false,
  });

  factory OnboardingStepsCompletion.fromJson(Map<String, dynamic> json) {
    return OnboardingStepsCompletion(
      shop: json['shop'] == true,
      branding: json['branding'] == true,
      compliance: json['compliance'] == true,
      kyc: json['kyc'] == true,
      review: json['review'] == true,
    );
  }

  int get completedCount => [shop, branding, compliance, kyc, review].where((v) => v).length;
}

class DynamicComplianceField {
  final String id;
  final String label;
  final String fieldType; // 'text' | 'numeric' | 'file'
  final String? regex;
  final bool required;
  final String? helpHint;

  DynamicComplianceField({
    required this.id,
    required this.label,
    this.fieldType = 'text',
    this.regex,
    this.required = false,
    this.helpHint,
  });

  factory DynamicComplianceField.fromJson(Map<String, dynamic> json) {
    return DynamicComplianceField(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      fieldType: json['fieldType']?.toString() ?? 'text',
      regex: json['regex']?.toString(),
      required: json['required'] == true,
      helpHint: json['helpHint']?.toString(),
    );
  }
}

class DynamicKycField {
  final String id;
  final String label;
  final List<String> allowedExtensions;
  final int minKb;
  final int maxKb;
  final bool required;
  final String? helpHint;

  DynamicKycField({
    required this.id,
    required this.label,
    this.allowedExtensions = const ['pdf', 'jpg', 'jpeg', 'png'],
    this.minKb = 10,
    this.maxKb = 10240,
    this.required = false,
    this.helpHint,
  });

  factory DynamicKycField.fromJson(Map<String, dynamic> json) {
    return DynamicKycField(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      allowedExtensions: (json['allowedExtensions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['pdf', 'jpg', 'jpeg', 'png'],
      minKb: (json['minKb'] as num?)?.toInt() ?? 10,
      maxKb: (json['maxKb'] as num?)?.toInt() ?? 10240,
      required: json['required'] == true,
      helpHint: json['helpHint']?.toString(),
    );
  }
}

class UploadedKycDoc {
  final String id;
  final String fieldId;
  final String fileUrl;

  UploadedKycDoc({
    required this.id,
    required this.fieldId,
    required this.fileUrl,
  });

  factory UploadedKycDoc.fromJson(Map<String, dynamic> json) {
    return UploadedKycDoc(
      id: json['id']?.toString() ?? '',
      fieldId: json['fieldId']?.toString() ?? '',
      fileUrl: json['fileUrl']?.toString() ?? '',
    );
  }
}

class OnboardingStatusModel {
  final SellerOnboardingProfile seller;
  final OnboardingStepsCompletion steps;
  final List<String> missingCompliance;
  final List<String> missingKyc;
  final List<DynamicComplianceField> complianceFields;
  final List<DynamicKycField> kycFields;
  final Map<String, String> values;
  final List<UploadedKycDoc> docs;

  OnboardingStatusModel({
    required this.seller,
    required this.steps,
    this.missingCompliance = const [],
    this.missingKyc = const [],
    this.complianceFields = const [],
    this.kycFields = const [],
    this.values = const {},
    this.docs = const [],
  });

  bool get isPending => seller.status == OnboardingStatus.pending;
  bool get isApproved => seller.status == OnboardingStatus.approved;
  bool get isRejected => seller.status == OnboardingStatus.rejected;
  bool get isDraft => seller.status == OnboardingStatus.draft;

  factory OnboardingStatusModel.fromJson(Map<String, dynamic> json) {
    final sellerJson = json['seller'] as Map<String, dynamic>? ?? {};
    final stepsJson = json['steps'] as Map<String, dynamic>? ?? {};

    final compFields = (json['complianceFields'] as List<dynamic>? ?? [])
        .map((e) => DynamicComplianceField.fromJson(e as Map<String, dynamic>))
        .toList();

    final kycFieldsList = (json['kycFields'] as List<dynamic>? ?? [])
        .map((e) => DynamicKycField.fromJson(e as Map<String, dynamic>))
        .toList();

    final docsList = (json['docs'] as List<dynamic>? ?? [])
        .map((e) => UploadedKycDoc.fromJson(e as Map<String, dynamic>))
        .toList();

    final valuesMap = <String, String>{};
    if (json['values'] is Map) {
      (json['values'] as Map).forEach((k, v) {
        if (k != null && v != null) {
          valuesMap[k.toString()] = v.toString();
        }
      });
    }

    return OnboardingStatusModel(
      seller: SellerOnboardingProfile.fromJson(sellerJson),
      steps: OnboardingStepsCompletion.fromJson(stepsJson),
      missingCompliance: (json['missingCompliance'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      missingKyc: (json['missingKyc'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      complianceFields: compFields,
      kycFields: kycFieldsList,
      values: valuesMap,
      docs: docsList,
    );
  }
}
