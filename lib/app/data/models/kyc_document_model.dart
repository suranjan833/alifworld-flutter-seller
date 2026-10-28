class KycDocumentModel {
  final String id;
  final String label;
  final bool required;
  final List<String> allowedExtensions;
  final int minKb;
  final int maxKb;
  final String? helpHint;

  String? fileName;
  String? filePath;
  String? fileUrl;
  int? fileSizeKb;
  bool isUploading;
  bool isUploaded;

  KycDocumentModel({
    required this.id,
    required this.label,
    this.required = true,
    this.allowedExtensions = const ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
    this.minKb = 20,
    this.maxKb = 5120,
    this.helpHint,
    this.fileName,
    this.filePath,
    this.fileUrl,
    this.fileSizeKb,
    this.isUploading = false,
    this.isUploaded = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'required': required,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileSizeKb': fileSizeKb,
      'isUploaded': isUploaded,
    };
  }

  factory KycDocumentModel.fromJson(Map<String, dynamic> json) {
    return KycDocumentModel(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      required: json['required'] ?? true,
      allowedExtensions: (json['allowedExtensions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      minKb: json['minKb'] ?? 20,
      maxKb: json['maxKb'] ?? 5120,
      helpHint: json['helpHint'],
      fileName: json['fileName'],
      fileUrl: json['fileUrl'],
      fileSizeKb: json['fileSizeKb'],
      isUploaded: json['isUploaded'] ?? false,
    );
  }
}

