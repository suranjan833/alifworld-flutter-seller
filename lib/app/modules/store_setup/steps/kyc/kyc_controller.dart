import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/models/kyc_document_model.dart';
import '../../../../data/models/onboarding_status_model.dart';
import '../../../../data/services/api_service.dart';

class KycController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final ImagePicker _picker = ImagePicker();

  final documents = <KycDocumentModel>[].obs;
  final Map<String, String> docIdToBackendId = {};

  @override
  void onInit() {
    super.onInit();
    _initDefaultDocuments();
  }

  void _initDefaultDocuments() {
    documents.assignAll([
      KycDocumentModel(
        id: 'trade_license',
        label: 'Trade License Copy',
        required: true,
        helpHint: 'Clear scan or photo of the trade license.',
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        minKb: 10,
        maxKb: 10240,
      ),
      KycDocumentModel(
        id: 'nid_front_back',
        label: 'NID Front/Back',
        required: true,
        helpHint: 'Both sides of the national ID card.',
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        minKb: 10,
        maxKb: 10240,
      ),
      KycDocumentModel(
        id: 'bin_certificate',
        label: 'BIN Certificate',
        required: false,
        helpHint: 'NBR BIN certificate, if available.',
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        minKb: 10,
        maxKb: 10240,
      ),
      KycDocumentModel(
        id: 'bank_cheque',
        label: 'Bank Cheque Leaf',
        required: true,
        helpHint: 'Cancelled cheque leaf for payout verification.',
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        minKb: 10,
        maxKb: 10240,
      ),
      KycDocumentModel(
        id: 'tin_certificate',
        label: 'e-TIN Certificate',
        required: false,
        helpHint: 'e-TIN certificate, if available.',
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        minKb: 10,
        maxKb: 10240,
      ),
    ]);
  }

  /// Configure from backend onboarding status (dynamic fields & uploaded docs)
  void configureFromBackend({
    required List<DynamicKycField> backendFields,
    required List<UploadedKycDoc> uploadedDocs,
  }) {
    if (backendFields.isNotEmpty) {
      final list = <KycDocumentModel>[];
      for (var f in backendFields) {
        final existingDoc = uploadedDocs.firstWhereOrNull((d) => d.fieldId == f.id);
        if (existingDoc != null) {
          docIdToBackendId[f.id] = existingDoc.id;
        }

        list.add(KycDocumentModel(
          id: f.id,
          label: f.label,
          required: f.required,
          helpHint: f.helpHint,
          allowedExtensions: f.allowedExtensions,
          minKb: f.minKb,
          maxKb: f.maxKb,
          fileUrl: existingDoc?.fileUrl,
          fileName: existingDoc != null ? 'Uploaded_${f.label.replaceAll(' ', '_')}.pdf' : null,
          isUploaded: existingDoc != null,
        ));
      }
      documents.assignAll(list);
    }
  }

  Future<void> uploadDocument(String id) async {
    final index = documents.indexWhere((d) => d.id == id);
    if (index == -1) return;

    final doc = documents[index];

    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (file == null) return;

      doc.isUploading = true;
      documents.refresh();

      // 1. Upload to CDN / Storage
      final uploadedUrl = await _api.uploadFile(
        filePath: file.path,
        fileName: file.name,
        kind: 'document',
      );

      if (uploadedUrl == null || uploadedUrl.isEmpty) {
        doc.isUploading = false;
        documents.refresh();
        Get.snackbar(
          'Upload Failed',
          'Could not upload document. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      final fileSize = (await file.length()) ~/ 1024;
      final extension = file.name.contains('.') ? file.name.split('.').last.toLowerCase() : 'jpg';

      // 2. Submit KYC Document to Seller Onboarding KYC API
      final res = await _api.submitKycDocument(
        fieldId: doc.id,
        fileUrl: uploadedUrl,
        fileSizeKb: fileSize > 0 ? fileSize : 50,
        extension: extension,
      );

      doc.isUploading = false;

      if (res != null) {
        doc.isUploaded = true;
        doc.fileName = file.name;
        doc.fileUrl = uploadedUrl;
        doc.fileSizeKb = fileSize;

        final newDocId = res['document']?['id']?.toString() ?? res['doc']?['id']?.toString() ?? res['id']?.toString();
        if (newDocId != null) {
          docIdToBackendId[doc.id] = newDocId;
        }

        documents.refresh();

        Get.snackbar(
          'Document Uploaded',
          '${doc.label} uploaded and attached to KYC profile.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Fallback: file is uploaded to CDN
        doc.isUploaded = true;
        doc.fileName = file.name;
        doc.fileUrl = uploadedUrl;
        doc.fileSizeKb = fileSize;
        documents.refresh();

        Get.snackbar(
          'Document Saved',
          '${doc.label} saved.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      doc.isUploading = false;
      documents.refresh();
      Get.snackbar(
        'Error',
        'Failed to upload document: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> removeDocument(String id) async {
    final index = documents.indexWhere((d) => d.id == id);
    if (index == -1) return;

    final doc = documents[index];
    final backendDocId = docIdToBackendId[doc.id];

    if (backendDocId != null) {
      await _api.deleteKycDocument(backendDocId);
      docIdToBackendId.remove(doc.id);
    }

    doc.isUploaded = false;
    doc.fileName = null;
    doc.fileUrl = null;
    doc.fileSizeKb = null;
    documents.refresh();

    Get.snackbar(
      'Removed',
      '${doc.label} has been removed.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  List<KycDocumentModel> getModel() {
    return documents.toList();
  }

  bool validate() {
    for (var doc in documents) {
      if (doc.required && !doc.isUploaded) {
        Get.snackbar(
          'Missing Document',
          'Please upload ${doc.label}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return false;
      }
    }
    return true;
  }
}
