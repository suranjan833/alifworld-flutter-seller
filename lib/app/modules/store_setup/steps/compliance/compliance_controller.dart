import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/compliance_model.dart';
import '../../../../data/models/onboarding_status_model.dart';

/// Represents a single dynamic compliance field rendered from the backend.
class ComplianceFieldState {
  final String id;
  final String label;
  final String fieldType; // "text" | "numeric" | "file"
  final String? regex;
  final bool required;
  final String? helpHint;
  final TextEditingController controller;

  ComplianceFieldState({
    required this.id,
    required this.label,
    required this.fieldType,
    this.regex,
    required this.required,
    this.helpHint,
  }) : controller = TextEditingController();

  void dispose() {
    controller.dispose();
  }
}

class ComplianceController extends GetxController {
  final formKey = GlobalKey<FormState>();

  /// Dynamic compliance fields loaded from GET /seller/onboarding/status
  final dynamicFields = <ComplianceFieldState>[].obs;

  /// Whether fields have been loaded from the API
  final fieldsLoaded = false.obs;

  /// Geo divisions loaded from GET /geo/divisions
  final divisions = <Map<String, dynamic>>[].obs;
  final selectedDivisionId = RxnString();
  final selectedDivisionName = 'Dhaka'.obs;
  final isDivisionsLoading = false.obs;

  /// Warehouse address (not a compliance field — sent separately in future)
  final addressController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadFallbackDivisions();
    _loadDefaultFields();
  }

  void _loadDefaultFields() {
    if (dynamicFields.isEmpty) {
      dynamicFields.assignAll([
        ComplianceFieldState(
          id: 'trade_license',
          label: 'Trade License Number',
          fieldType: 'text',
          required: true,
          helpHint: 'As printed on your trade license.',
        ),
        ComplianceFieldState(
          id: 'nbr_bin',
          label: 'NBR BIN',
          fieldType: 'numeric',
          regex: r'^\d{9,13}$',
          required: true,
          helpHint: '9–13 digit Business Identification Number.',
        ),
        ComplianceFieldState(
          id: 'e_tin',
          label: 'e-TIN',
          fieldType: 'numeric',
          regex: r'^\d{12}$',
          required: false,
          helpHint: '12 digit electronic Taxpayer Identification Number.',
        ),
      ]);
      fieldsLoaded.value = true;
    }
  }

  /// Fallback static divisions in case the geo API is not called yet
  void _loadFallbackDivisions() {
    divisions.assignAll([
      {'id': '', 'name': 'Barisal'},
      {'id': '', 'name': 'Chattagram'},
      {'id': '', 'name': 'Dhaka'},
      {'id': '', 'name': 'Khulna'},
      {'id': '', 'name': 'Mymensingh'},
      {'id': '', 'name': 'Rajshahi'},
      {'id': '', 'name': 'Rangpur'},
      {'id': '', 'name': 'Sylhet'},
    ]);
  }

  /// Called by StoreSetupController after fetching /seller/onboarding/status
  void configureFromBackend({
    required List<DynamicComplianceField> fields,
    required Map<String, String> values,
    List<Map<String, dynamic>> geoDivisions = const [],
  }) {
    // Dispose existing controllers before replacing
    for (final f in dynamicFields) {
      f.dispose();
    }

    if (fields.isEmpty) {
      // No compliance fields configured by admin — no fields to show
      dynamicFields.clear();
      fieldsLoaded.value = true;
      return;
    }

    final newFields = fields.map((f) {
      final state = ComplianceFieldState(
        id: f.id,
        label: f.label,
        fieldType: f.fieldType,
        regex: f.regex,
        required: f.required,
        helpHint: f.helpHint,
      );
      // Pre-fill from saved values if available
      if (values.containsKey(f.id)) {
        state.controller.text = values[f.id] ?? '';
      }
      return state;
    }).toList();

    dynamicFields.assignAll(newFields);
    fieldsLoaded.value = true;

    // Load geo divisions if provided
    if (geoDivisions.isNotEmpty) {
      divisions.assignAll(geoDivisions);
    }
  }

  /// Update geo divisions from API response
  void setGeoDivisions(List<Map<String, dynamic>> divisionList) {
    if (divisionList.isNotEmpty) {
      divisions.assignAll(divisionList);
      // Keep current selection if still valid, else default to first
      final currentName = selectedDivisionName.value;
      final match = divisionList.firstWhereOrNull((d) => d['name'] == currentName);
      if (match != null) {
        selectedDivisionId.value = match['id'];
      } else {
        selectedDivisionName.value = divisionList.first['name'] ?? 'Dhaka';
        selectedDivisionId.value = divisionList.first['id'];
      }
    }
  }

  void setDivision(String name, String id) {
    selectedDivisionName.value = name;
    selectedDivisionId.value = id;
  }

  /// Validate all dynamic fields using their regex and required flags
  bool validate() {
    bool isValid = true;

    for (final field in dynamicFields) {
      final value = field.controller.text.trim();

      if (field.required && value.isEmpty) {
        Get.snackbar(
          'Required',
          '${field.label} is required',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return false;
      }

      if (value.isNotEmpty && field.regex != null && field.regex!.isNotEmpty) {
        final regExp = RegExp(field.regex!);
        if (!regExp.hasMatch(value)) {
          Get.snackbar(
            'Invalid Format',
            '${field.label}: incorrect format. ${field.helpHint ?? ''}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return false;
        }
      }
    }

    return isValid && (formKey.currentState?.validate() ?? true);
  }

  /// Build the `compliance` array for POST /seller/onboarding/draft
  List<Map<String, String>> toCompliancePayload() {
    final list = <Map<String, String>>[];
    for (final field in dynamicFields) {
      final value = field.controller.text.trim();
      if (value.isNotEmpty) {
        list.add({'fieldId': field.id, 'value': value});
      }
    }
    return list;
  }

  ComplianceModel getModel() {
    final map = <String, String>{};
    for (final field in dynamicFields) {
      map[field.label] = field.controller.text.trim();
    }
    return ComplianceModel(
      division: selectedDivisionName.value,
      addressLine: addressController.text.trim(),
      dynamicFields: map,
    );
  }

  @override
  void onClose() {
    for (final f in dynamicFields) {
      f.dispose();
    }
    addressController.dispose();
    super.onClose();
  }
}
