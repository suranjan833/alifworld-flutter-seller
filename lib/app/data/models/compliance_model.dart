class ComplianceFieldModel {
  final String id;
  final String label;
  final String fieldType; // 'text' | 'numeric'
  final bool required;
  final String? helpHint;
  final String? regex;
  String value;

  ComplianceFieldModel({
    required this.id,
    required this.label,
    this.fieldType = 'text',
    this.required = true,
    this.helpHint,
    this.regex,
    this.value = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'fieldId': id,
      'value': value,
    };
  }
}

class ComplianceModel {
  String businessType; // Individual, Proprietorship, Limited Company
  String nidNumber;
  String tradeLicenseNumber;
  String tinNumber;
  String binNumber;
  String division;
  String district;
  String addressLine;
  Map<String, String> dynamicFields;

  ComplianceModel({
    this.businessType = 'Individual',
    this.nidNumber = '',
    this.tradeLicenseNumber = '',
    this.tinNumber = '',
    this.binNumber = '',
    this.division = 'Dhaka',
    this.district = 'Dhaka',
    this.addressLine = '',
    Map<String, String>? dynamicFields,
  }) : dynamicFields = dynamicFields ?? {};

  Map<String, dynamic> toJson() {
    return {
      'businessType': businessType,
      'nidNumber': nidNumber,
      'tradeLicenseNumber': tradeLicenseNumber,
      'tinNumber': tinNumber,
      'binNumber': binNumber,
      'division': division,
      'district': district,
      'addressLine': addressLine,
      'dynamicFields': dynamicFields,
    };
  }

  factory ComplianceModel.fromJson(Map<String, dynamic> json) {
    return ComplianceModel(
      businessType: json['businessType'] ?? 'Individual',
      nidNumber: json['nidNumber'] ?? '',
      tradeLicenseNumber: json['tradeLicenseNumber'] ?? '',
      tinNumber: json['tinNumber'] ?? '',
      binNumber: json['binNumber'] ?? '',
      division: json['division'] ?? 'Dhaka',
      district: json['district'] ?? 'Dhaka',
      addressLine: json['addressLine'] ?? '',
      dynamicFields: json['dynamicFields'] != null
          ? Map<String, String>.from(json['dynamicFields'])
          : {},
    );
  }
}

