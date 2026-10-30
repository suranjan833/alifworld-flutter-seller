import 'dart:developer';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../data/services/api_service.dart';
import '../../../home/controllers/home_controller.dart';

/// Catalog Attribute from GET /catalog/attributes
class CatalogAttribute {
  final String id;
  final String name;
  final String type; // 'text', 'select', 'boolean', 'numeric'
  final List<String> options;
  final bool isVariant;

  CatalogAttribute({
    required this.id,
    required this.name,
    required this.type,
    required this.options,
    required this.isVariant,
  });

  factory CatalogAttribute.fromJson(Map<String, dynamic> json) {
    return CatalogAttribute(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'text',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList() ??
          [],
      isVariant: json['isVariant'] == true,
    );
  }
}

/// Variant dimension used in Step 2 to generate combinations
class VariantAttribute {
  final String id;
  String name;
  final String type;
  final List<String> options;
  List<String> values;

  VariantAttribute({
    String? id,
    required this.name,
    this.type = 'select',
    List<String>? options,
    List<String>? values,
  })  : id = id ?? '',
        options = options ?? [],
        values = values ?? [];

  bool get isSelect => type == 'select';
  bool get hasOptions => options.isNotEmpty;
  bool get mustPickFromOptions => isSelect && hasOptions;
}

class FlatCategory {
  final String id;
  final String name;
  final String? parentName;
  final String path;
  final Color color;
  final Color bgColor;
  final IconData icon;

  FlatCategory({
    required this.id,
    required this.name,
    this.parentName,
    required this.path,
    required this.color,
    required this.bgColor,
    required this.icon,
  });
}

class ProductVariantCombination {
  final String label;
  final Map<String, String> attributes;
  final TextEditingController mrpCtrl;
  final RxString discountType; // 'none', 'percent', 'flat'
  final TextEditingController discountValueCtrl;
  final TextEditingController pointsCtrl;
  final TextEditingController stockCtrl;
  final TextEditingController lowStockThresholdCtrl;
  final TextEditingController skuCtrl;
  final RxBool openBoxDelivery;
  final RxBool isEnabled;
  final RxList<String> images;
  final RxMap<String, String> customAttributes;

  ProductVariantCombination({
    required this.label,
    required this.attributes,
    String mrp = '',
    String discountType = 'none',
    String discountValue = '',
    String points = '0',
    String stock = '10',
    String lowStockThreshold = '5',
    String sku = '',
    bool openBox = false,
    bool enabled = true,
    List<String>? initialImages,
    Map<String, String>? initialCustomAttributes,
  })  : mrpCtrl = TextEditingController(text: mrp),
        discountType = discountType.obs,
        discountValueCtrl = TextEditingController(text: discountValue),
        pointsCtrl = TextEditingController(text: points),
        stockCtrl = TextEditingController(text: stock),
        lowStockThresholdCtrl = TextEditingController(text: lowStockThreshold),
        skuCtrl = TextEditingController(text: sku),
        openBoxDelivery = openBox.obs,
        isEnabled = enabled.obs,
        images = (initialImages ?? <String>[]).obs,
        customAttributes = (initialCustomAttributes != null
                ? Map<String, String>.from(initialCustomAttributes)
                : <String, String>{})
            .obs;

  final priceUpdateTrigger = 0.obs;

  double get calculatedSellingPrice {
    // Unconditionally register observable dependencies so Obx never throws
    priceUpdateTrigger.value;
    final type = discountType.value;

    final mrp = double.tryParse(mrpCtrl.text.trim()) ?? 0.0;
    if (mrp <= 0) return 0.0;
    if (type == 'percent') {
      final pct = double.tryParse(discountValueCtrl.text.trim()) ?? 0.0;
      final val = mrp * (1.0 - (pct / 100.0));
      return val > 0 ? val : 0.0;
    } else if (type == 'flat') {
      final flat = double.tryParse(discountValueCtrl.text.trim()) ?? 0.0;
      final val = mrp - flat;
      return val > 0 ? val : 0.0;
    }
    return mrp;
  }

  void dispose() {
    mrpCtrl.dispose();
    discountValueCtrl.dispose();
    pointsCtrl.dispose();
    stockCtrl.dispose();
    lowStockThresholdCtrl.dispose();
    skuCtrl.dispose();
  }
}

class AddProductController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  // Stepper State: 0 = Basic info, 1 = Variant attributes, 2 = Combinations
  final currentStep = 0.obs;
  final isLoadingMeta = true.obs;
  final isSaving = false.obs;

  // Seller status & slug (§0.1, §5.2)
  final sellerStatus = 'approved'.obs;
  String shopSlug = 'seller';

  // Metadata
  final categories = <Map<String, dynamic>>[].obs;
  final flatCategories = <FlatCategory>[].obs;
  final brands = <Map<String, dynamic>>[].obs;
  final catalogAttributes = <CatalogAttribute>[].obs;

  List<CatalogAttribute> get variantCatalogAttributes =>
      catalogAttributes.where((a) => a.isVariant).toList();

  List<CatalogAttribute> get customCatalogAttributes =>
      catalogAttributes.where((a) => !a.isVariant).toList();

  FlatCategory? get selectedCategory {
    final id = selectedCategoryId.value;
    if (id == null) return null;
    return flatCategories.firstWhereOrNull((c) => c.id == id);
  }

  String get selectedCategoryPath {
    final cat = selectedCategory;
    return cat?.path ?? '';
  }

  (Color, Color, IconData) _getCategoryTheme(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('fashion') ||
        lower.contains('cloth') ||
        lower.contains('wear') ||
        lower.contains('shoe')) {
      return (
        const Color(0xFFE11D48),
        const Color(0xFFFFF1F2),
        Icons.checkroom_rounded,
      );
    } else if (lower.contains('electronic') ||
        lower.contains('phone') ||
        lower.contains('laptop') ||
        lower.contains('computer') ||
        lower.contains('audio')) {
      return (
        const Color(0xFF2563EB),
        const Color(0xFFEFF6FF),
        Icons.devices_rounded,
      );
    } else if (lower.contains('home') ||
        lower.contains('kitchen') ||
        lower.contains('appliance') ||
        lower.contains('living')) {
      return (
        const Color(0xFF0D9488),
        const Color(0xFFF0FDFA),
        Icons.kitchen_rounded,
      );
    } else if (lower.contains('beauty') ||
        lower.contains('health') ||
        lower.contains('care')) {
      return (
        const Color(0xFF9333EA),
        const Color(0xFFFAF5FF),
        Icons.spa_rounded,
      );
    } else if (lower.contains('pet')) {
      return (
        const Color(0xFFD97706),
        const Color(0xFFFFFBEB),
        Icons.pets_rounded,
      );
    } else if (lower.contains('tool') || lower.contains('industrial')) {
      return (
        const Color(0xFFEA580C),
        const Color(0xFFFFF7ED),
        Icons.build_rounded,
      );
    } else if (lower.contains('sport') ||
        lower.contains('outdoor') ||
        lower.contains('fitness')) {
      return (
        const Color(0xFF16A34A),
        const Color(0xFFF0FDF4),
        Icons.sports_soccer_rounded,
      );
    } else if (lower.contains('eyewear') ||
        lower.contains('sunglass') ||
        lower.contains('jewel') ||
        lower.contains('watch')) {
      return (
        const Color(0xFFD97706),
        const Color(0xFFFEF3C7),
        Icons.visibility_rounded,
      );
    }
    return (
      const Color(0xFFFF630F),
      const Color(0xFFFFF7ED),
      Icons.category_rounded,
    );
  }

  // Step 1: Basic Info Form
  final nameCtrl = TextEditingController();
  final slugCtrl = TextEditingController(text: 'item');
  final isSlugCustomized = false.obs;
  final descCtrl = TextEditingController();

  // Fulfilment & Returns
  final handlingDaysCtrl = TextEditingController(text: '1');
  final returnType = 'Return / Replace'
      .obs; // 'Return / Replace', 'Replace only', 'No return / replace'
  final returnWindowDaysCtrl = TextEditingController(text: '7');
  final selectedCategoryId = RxnString();
  final selectedBrandId = RxnString();

  String get apiReturnPolicy {
    switch (returnType.value) {
      case 'Replace only':
        return 'replace_only';
      case 'No return / replace':
        return 'no_return';
      case 'Return / Replace':
      default:
        return 'return_replace';
    }
  }

  bool get hasReturnWindow => returnType.value != 'No return / replace';

  String get returnWindowLabel {
    if (returnType.value == 'Replace only') {
      return 'Replace window (days) *';
    }
    return 'Return / Replace window (days) *';
  }

  // Step 2: Variant Attributes
  final hasVariants = false.obs;
  final selectedAttributes = <VariantAttribute>[].obs;
  final newAttributeNameCtrl = TextEditingController();
  final newValueCtrl = TextEditingController();

  // Step 3: Combinations & Pricing
  final combinations = <ProductVariantCombination>[].obs;
  final selectedCombinationIndex = 0.obs;
  final bulkPriceCtrl = TextEditingController();
  final bulkStockCtrl = TextEditingController();

  ProductVariantCombination? get currentCombination {
    if (combinations.isEmpty) return null;
    final idx = selectedCombinationIndex.value;
    if (idx >= 0 && idx < combinations.length) {
      return combinations[idx];
    }
    return combinations.first;
  }

  // Single variant fields (when hasVariants is false)
  final priceCtrl = TextEditingController();
  final compareAtPriceCtrl = TextEditingController();
  final stockCtrl = TextEditingController(text: '10');
  final skuCtrl = TextEditingController();
  final variantLabelCtrl = TextEditingController(text: 'Standard');
  final openBoxDelivery = false.obs;

  // Product Images
  final productImages = <String>[].obs;
  final isUploadingImage = false.obs;

  @override
  void onInit() {
    super.onInit();
    nameCtrl.addListener(_onNameChanged);
    loadCatalogMetadata();
  }

  @override
  void onClose() {
    nameCtrl.removeListener(_onNameChanged);
    nameCtrl.dispose();
    slugCtrl.dispose();
    descCtrl.dispose();
    handlingDaysCtrl.dispose();
    returnWindowDaysCtrl.dispose();
    newAttributeNameCtrl.dispose();
    newValueCtrl.dispose();
    bulkPriceCtrl.dispose();
    bulkStockCtrl.dispose();
    priceCtrl.dispose();
    compareAtPriceCtrl.dispose();
    stockCtrl.dispose();
    skuCtrl.dispose();
    variantLabelCtrl.dispose();

    for (var c in combinations) {
      c.dispose();
    }
    super.onClose();
  }

  void _onNameChanged() {
    if (!isSlugCustomized.value) {
      final name = nameCtrl.text.trim();
      if (name.isEmpty) {
        slugCtrl.text = 'item';
      } else {
        slugCtrl.text = _toSlug(name);
      }
    }
    if (!hasVariants.value && combinations.isNotEmpty) {
      // Keep single product combo label updated with product name
      final label = nameCtrl.text.trim().isNotEmpty
          ? nameCtrl.text.trim()
          : 'Single product';
      if (combinations.first.label != label) {
        generateCombinations();
      }
    }
  }

  String _toSlug(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-');
  }

  Future<void> loadCatalogMetadata() async {
    isLoadingMeta.value = true;
    try {
      final cats = await _api.getCategories();
      categories.value = cats.whereType<Map<String, dynamic>>().toList();

      final List<FlatCategory> flat = [];
      for (var cat in categories) {
        final catId = cat['id']?.toString() ?? '';
        final catName = cat['name']?.toString() ?? '';
        final (color, bgColor, icon) = _getCategoryTheme(catName);

        final children = (cat['children'] as List<dynamic>?) ?? [];
        if (children.isEmpty) {
          flat.add(
            FlatCategory(
              id: catId,
              name: catName,
              parentName: null,
              path: catName,
              color: color,
              bgColor: bgColor,
              icon: icon,
            ),
          );
        } else {
          for (var child in children) {
            if (child is Map<String, dynamic>) {
              final childId = child['id']?.toString() ?? '';
              final childName = child['name']?.toString() ?? '';
              flat.add(
                FlatCategory(
                  id: childId,
                  name: childName,
                  parentName: catName,
                  path: '$catName › $childName',
                  color: color,
                  bgColor: bgColor,
                  icon: icon,
                ),
              );
            }
          }
          // Also add root category
          flat.add(
            FlatCategory(
              id: catId,
              name: catName,
              parentName: null,
              path: catName,
              color: color,
              bgColor: bgColor,
              icon: icon,
            ),
          );
        }
      }
      flatCategories.value = flat;

      final bList = await _api.getBrands();
      brands.value = bList.whereType<Map<String, dynamic>>().toList();

      // Split Catalog Attributes (§1.3)
      final aList = await _api.getAttributes();
      final List<CatalogAttribute> parsedAttrs = [];
      for (var item in aList) {
        if (item is Map<String, dynamic>) {
          parsedAttrs.add(CatalogAttribute.fromJson(item));
        }
      }
      catalogAttributes.value = parsedAttrs;

      // Fetch shop details and onboarding status for slug and status check (§0.1, §5.2)
      try {
        final statusRes = await _api.getOnboardingStatus();
        final seller = statusRes?['seller'] as Map<String, dynamic>?;
        if (seller != null) {
          final sSlug = seller['slug']?.toString();
          if (sSlug != null && sSlug.isNotEmpty) {
            shopSlug = sSlug;
          }
          final status = seller['status']?.toString();
          if (status != null && status.isNotEmpty) {
            sellerStatus.value = status;
          }
        }
      } catch (_) {}

      // Initial combination generation
      generateCombinations();
    } catch (e) {
      log('Error loading catalog metadata: $e');
    } finally {
      isLoadingMeta.value = false;
    }
  }

  // --- Handling Time Steppers ---
  void incrementHandlingDays() {
    int val = int.tryParse(handlingDaysCtrl.text.trim()) ?? 1;
    handlingDaysCtrl.text = (val + 1).toString();
  }

  void decrementHandlingDays() {
    int val = int.tryParse(handlingDaysCtrl.text.trim()) ?? 1;
    if (val > 1) {
      handlingDaysCtrl.text = (val - 1).toString();
    }
  }

  void setReturnWindow(int days) {
    returnWindowDaysCtrl.text = days.toString();
  }

  // --- Description Text Actions ---
  void formatBold() {
    _wrapSelection('**', '**');
  }

  void formatItalic() {
    _wrapSelection('*', '*');
  }

  void formatUnderline() {
    _wrapSelection('<u>', '</u>');
  }

  void insertBulletList() {
    _insertAtCursor('\n• ');
  }

  void insertNumberedList() {
    _insertAtCursor('\n1. ');
  }

  void clearDescription() {
    descCtrl.clear();
  }

  void _wrapSelection(String prefix, String suffix) {
    final text = descCtrl.text;
    final selection = descCtrl.selection;
    if (!selection.isValid || selection.isCollapsed) {
      _insertAtCursor('$prefix$suffix');
      return;
    }
    final selectedText = text.substring(selection.start, selection.end);
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$prefix$selectedText$suffix',
    );
    descCtrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.end + prefix.length + suffix.length,
      ),
    );
  }

  void _insertAtCursor(String insertion) {
    final text = descCtrl.text;
    final selection = descCtrl.selection;
    final start = selection.isValid ? selection.start : text.length;
    final newText = text.replaceRange(start, start, insertion);
    descCtrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + insertion.length),
    );
  }

  // --- Fallback Presets for Custom / Unconfigured Attributes ---
  final Map<String, List<String>> attributePresets = {
    'Size': ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL', 'Free Size'],
    'Shoe Size (UK/EU)': ['38', '39', '40', '41', '42', '43', '44', '45'],
    'Color': ['Black', 'White', 'Red', 'Blue', 'Green', 'Grey', 'Navy'],
    'Storage': ['64GB', '128GB', '256GB', '512GB', '1TB'],
    'RAM': ['4GB', '6GB', '8GB', '12GB', '16GB'],
  };

  List<String> getPresetsForAttribute(String name) {
    for (var entry in attributePresets.entries) {
      if (entry.key.toLowerCase() == name.toLowerCase()) {
        return entry.value;
      }
    }
    return [];
  }

  // --- Step 2: Variant Attributes Logic (§1.3, §3.1, §3.2) ---
  void addAttributeFromCatalog(CatalogAttribute catAttr) {
    if (selectedAttributes.any(
      (a) =>
          a.name.toLowerCase() == catAttr.name.toLowerCase() ||
          (a.id.isNotEmpty && a.id == catAttr.id),
    )) {
      Get.snackbar(
        'Already Added',
        'Attribute "${catAttr.name}" is already in your variants list.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    selectedAttributes.add(
      VariantAttribute(
        id: catAttr.id,
        name: catAttr.name,
        type: catAttr.type,
        options: catAttr.options.isNotEmpty
            ? catAttr.options
            : getPresetsForAttribute(catAttr.name),
        values: [],
      ),
    );
    generateCombinations();
  }

  void addAttribute(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return;

    if (selectedAttributes.any(
      (a) => a.name.toLowerCase() == clean.toLowerCase(),
    )) {
      Get.snackbar(
        'Already Added',
        'Attribute "$clean" already exists.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Check if matches a catalog attribute
    final match = catalogAttributes.firstWhereOrNull(
      (a) => a.name.toLowerCase() == clean.toLowerCase(),
    );

    if (match != null) {
      addAttributeFromCatalog(match);
    } else {
      final presets = getPresetsForAttribute(clean);
      selectedAttributes.add(
        VariantAttribute(
          id: '',
          name: clean,
          type: presets.isNotEmpty ? 'select' : 'text',
          options: presets,
          values: [],
        ),
      );
      generateCombinations();
    }
    newAttributeNameCtrl.clear();
  }

  void removeAttribute(int index) {
    if (index >= 0 && index < selectedAttributes.length) {
      selectedAttributes.removeAt(index);
      generateCombinations();
    }
  }

  void toggleAttributeValue(int attrIndex, String value) {
    final clean = value.trim();
    if (clean.isEmpty) return;
    final attr = selectedAttributes[attrIndex];
    if (attr.values.contains(clean)) {
      attr.values.remove(clean);
    } else {
      attr.values.add(clean);
    }
    selectedAttributes.refresh();
    generateCombinations();
  }

  void addValueToAttribute(int attrIndex, String value) {
    final clean = value.trim();
    if (clean.isEmpty) return;
    final attr = selectedAttributes[attrIndex];
    // Per Section 1.3: select attribute values must come ONLY from admin-set options
    if (attr.mustPickFromOptions) {
      return;
    }
    if (attr.values.contains(clean)) return;
    attr.values.add(clean);
    selectedAttributes.refresh();
    generateCombinations();
  }

  void removeValueFromAttribute(int attrIndex, String value) {
    final attr = selectedAttributes[attrIndex];
    attr.values.remove(value);
    selectedAttributes.refresh();
    generateCombinations();
  }

  // --- Auto SKU Generator (§5.2) ---
  String generateSku({
    required String sellerSlug,
    required String productSlug,
    required List<String> values,
  }) {
    final cleanSeller = _toSlug(sellerSlug);
    final sSlug = cleanSeller.length > 20
        ? cleanSeller.substring(0, 20)
        : (cleanSeller.isEmpty ? 'seller' : cleanSeller);

    final cleanProd = _toSlug(productSlug);
    final pSlug = cleanProd.length > 40
        ? cleanProd.substring(0, 40)
        : (cleanProd.isEmpty ? 'item' : cleanProd);

    final valParts = values
        .map((v) => _toSlug(v))
        .where((s) => s.isNotEmpty)
        .join('-');
    final vSlug = valParts.length > 30 ? valParts.substring(0, 30) : valParts;

    final parts = [sSlug, pSlug, if (vSlug.isNotEmpty) vSlug];
    var finalSku = parts.join('-');
    if (finalSku.length > 100) {
      finalSku = finalSku.substring(0, 100);
    }
    return finalSku;
  }

  // --- Combinations Generator (Cartesian Product §3.2) ---
  void generateCombinations() {
    // Preserve existing combination inputs when attributes or values change
    final Map<String, ProductVariantCombination> existingMap = {
      for (var c in combinations) c.label: c,
    };

    combinations.clear();

    final shopPrefix = shopSlug.isNotEmpty ? shopSlug : 'seller';
    final prodSlug = slugCtrl.text.isNotEmpty && slugCtrl.text != 'item'
        ? slugCtrl.text.toLowerCase()
        : (nameCtrl.text.trim().isNotEmpty ? _toSlug(nameCtrl.text) : 'item');

    if (!hasVariants.value) {
      final label = nameCtrl.text.trim().isNotEmpty
          ? nameCtrl.text.trim()
          : 'Single product';
      final sku = generateSku(
        sellerSlug: shopPrefix,
        productSlug: prodSlug,
        values: [],
      );

      final existing = existingMap[label] ?? existingMap['Single product'];
      combinations.add(
        ProductVariantCombination(
          label: label,
          attributes: {},
          mrp: existing?.mrpCtrl.text.isNotEmpty == true
              ? existing!.mrpCtrl.text
              : priceCtrl.text.trim(),
          discountType: existing?.discountType.value ?? 'none',
          discountValue: existing?.discountValueCtrl.text ?? '',
          points: existing?.pointsCtrl.text ?? '0',
          stock: existing?.stockCtrl.text.isNotEmpty == true
              ? existing!.stockCtrl.text
              : (stockCtrl.text.trim().isEmpty ? '10' : stockCtrl.text.trim()),
          lowStockThreshold: existing?.lowStockThresholdCtrl.text ?? '5',
          sku: sku,
          openBox: existing?.openBoxDelivery.value ?? false,
          initialImages: existing?.images.isNotEmpty == true
              ? existing!.images.toList()
              : productImages.toList(),
          initialCustomAttributes: existing?.customAttributes,
        ),
      );
      selectedCombinationIndex.value = 0;
      return;
    }

    final activeAttrs = selectedAttributes
        .where((a) => a.values.isNotEmpty)
        .toList();
    if (activeAttrs.isEmpty) return;

    List<Map<String, String>> cartesian = [{}];
    for (var attr in activeAttrs) {
      List<Map<String, String>> next = [];
      for (var existing in cartesian) {
        for (var val in attr.values) {
          final copy = Map<String, String>.from(existing);
          copy[attr.name] = val;
          next.add(copy);
        }
      }
      cartesian = next;
    }

    for (var item in cartesian) {
      final label = item.values.join(' / ');
      final sku = generateSku(
        sellerSlug: shopPrefix,
        productSlug: prodSlug,
        values: item.values.toList(),
      );

      final existing = existingMap[label];
      if (existing != null) {
        // Reuse existing combination to preserve seller inputs
        combinations.add(existing);
      } else {
        combinations.add(
          ProductVariantCombination(
            label: label,
            attributes: item,
            mrp: '',
            discountType: 'none',
            discountValue: '',
            points: '0',
            stock: '10',
            lowStockThreshold: '5',
            sku: sku,
            openBox: false,
            initialImages: productImages.toList(),
          ),
        );
      }
    }

    if (selectedCombinationIndex.value >= combinations.length) {
      selectedCombinationIndex.value = 0;
    }
  }

  // --- Disable Guard (§3.2) ---
  /// Returns reason string if disabling this combination is blocked, or null if allowed.
  String? getDisableGuardError(ProductVariantCombination combo) {
    if (!combo.isEnabled.value) {
      // Re-enabling is always allowed
      return null;
    }

    // Check (a): leaves fewer than 2 active combinations
    final activeCombos = combinations.where((c) => c.isEnabled.value).toList();
    if (activeCombos.length <= 2) {
      return 'At least 2 active combinations must be kept for a multi-variant product.';
    }

    // Check (b): leaves any dimension value with 0 active combinations
    final remainingActive = activeCombos.where((c) => c != combo).toList();
    for (var dim in selectedAttributes) {
      for (var val in dim.values) {
        final covered =
            remainingActive.any((c) => c.attributes[dim.name] == val);
        if (!covered) {
          return 'Disabling this leaves "${dim.name}: $val" with no active combinations.';
        }
      }
    }
    return null;
  }

  bool toggleCombination(ProductVariantCombination combo) {
    if (combo.isEnabled.value) {
      final error = getDisableGuardError(combo);
      if (error != null) {
        Get.snackbar(
          'Cannot Disable Combination',
          error,
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return false;
      }
      combo.isEnabled.value = false;
      return true;
    } else {
      combo.isEnabled.value = true;
      return true;
    }
  }

  // --- Step 3: Custom Attributes Management (§1.3, §4.6) ---
  List<CatalogAttribute> getAvailableCustomAttributes(
    ProductVariantCombination combo,
  ) {
    final dimensionNames =
        selectedAttributes.map((a) => a.name.toLowerCase()).toSet();

    return customCatalogAttributes.where((attr) {
      // Exclude if already used as a dimension
      if (dimensionNames.contains(attr.name.toLowerCase())) return false;
      // Exclude if already added to this combo
      if (combo.customAttributes.containsKey(attr.name)) return false;
      return true;
    }).toList();
  }

  void addCustomAttributeToCombo(
    ProductVariantCombination combo,
    String key,
    String value,
  ) {
    final cleanKey = key.trim();
    if (cleanKey.isEmpty) return;
    combo.customAttributes[cleanKey] = value.trim();
  }

  void removeCustomAttributeFromCombo(
    ProductVariantCombination combo,
    String key,
  ) {
    combo.customAttributes.remove(key);
  }

  void applyBulkPriceAndStock() {
    final mrp = bulkPriceCtrl.text.trim();
    final stock = bulkStockCtrl.text.trim();
    if (mrp.isEmpty && stock.isEmpty) return;

    for (var combo in combinations) {
      if (mrp.isNotEmpty) combo.mrpCtrl.text = mrp;
      if (stock.isNotEmpty) combo.stockCtrl.text = stock;
    }
    Get.snackbar(
      'Bulk Applied',
      'Applied values to all ${combinations.length} combinations.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  // --- Image Uploads (kind: "media" per §4.2) ---
  Future<void> pickAndUploadCombinationImage(
    ProductVariantCombination combo,
  ) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image == null) return;

      isUploadingImage.value = true;
      final url = await _api.uploadFile(
        filePath: image.path,
        fileName: image.name,
        kind: 'media',
      );
      isUploadingImage.value = false;

      if (url != null && url.isNotEmpty) {
        if (combo.images.length < 10) {
          combo.images.add(url);
        } else {
          Get.snackbar(
            'Limit Reached',
            'Maximum 10 images allowed per variant.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
        if (!productImages.contains(url)) {
          productImages.add(url);
        }
        Get.snackbar(
          'Image Added',
          'Photo uploaded for ${combo.label}.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isUploadingImage.value = false;
      Get.snackbar(
        'Upload Failed',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void removeCombinationImage(ProductVariantCombination combo, int index) {
    if (index >= 0 && index < combo.images.length) {
      combo.images.removeAt(index);
    }
  }

  Future<void> pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image == null) return;

      isUploadingImage.value = true;
      final url = await _api.uploadFile(
        filePath: image.path,
        fileName: image.name,
        kind: 'media',
      );
      isUploadingImage.value = false;

      if (url != null && url.isNotEmpty) {
        if (productImages.length < 20) {
          productImages.add(url);
          Get.snackbar(
            'Image Added',
            'Product image uploaded successfully.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFF10B981),
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Limit Reached',
            'Maximum 20 product gallery images allowed.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      isUploadingImage.value = false;
      Get.snackbar(
        'Upload Failed',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < productImages.length) {
      productImages.removeAt(index);
    }
  }

  // --- Step Navigation & Validations ---
  bool validateStep1() {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      Get.snackbar(
        'Product Name Required',
        'Please enter a name for your product.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (selectedCategoryId.value == null || selectedCategoryId.value!.isEmpty) {
      Get.snackbar(
        'Category Required',
        'Please select a category for your product.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (hasReturnWindow) {
      final days = int.tryParse(returnWindowDaysCtrl.text.trim());
      if (days == null || days < 0) {
        Get.snackbar(
          'Return Window Required',
          'Please enter a valid return/replace window in days.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return false;
      }
    }

    return true;
  }

  bool validateStep2() {
    if (!hasVariants.value) {
      generateCombinations();
      return true;
    }

    if (selectedAttributes.isEmpty) {
      Get.snackbar(
        'Variants Required',
        'Please add at least one variant attribute (e.g. Size or Color), or switch to Single Variant.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    // Rule: Every attribute needs at least 2 values (§3.1)
    for (var dim in selectedAttributes) {
      if (dim.values.length < 2) {
        Get.snackbar(
          'At Least 2 Values Required',
          'Attribute "${dim.name}" must have at least 2 values (currently ${dim.values.length}). A multi-variant product requires multiple options.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return false;
      }
    }

    generateCombinations();

    // Rule: At least 2 active combinations (§3.1)
    final activeCombos = combinations.where((c) => c.isEnabled.value).length;
    if (activeCombos < 2) {
      Get.snackbar(
        'At Least 2 Combinations Required',
        'A multi-variant product must have at least 2 active combinations.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    // Rule: Every dimension value must appear in at least one active combination (§3.2)
    for (var dim in selectedAttributes) {
      for (var val in dim.values) {
        final covered = combinations
            .where((c) => c.isEnabled.value)
            .any((c) => c.attributes[dim.name] == val);
        if (!covered) {
          Get.snackbar(
            'Uncovered Value',
            'Value "$val" for "${dim.name}" has no active combinations enabled.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return false;
        }
      }
    }

    return true;
  }

  bool validateStep3() {
    final enabledCombos =
        combinations.where((c) => c.isEnabled.value).toList();
    if (enabledCombos.isEmpty) {
      Get.snackbar(
        'Combinations Required',
        'Enable at least one combination to continue.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    for (int i = 0; i < combinations.length; i++) {
      final combo = combinations[i];
      if (!combo.isEnabled.value) continue;

      final mrp = double.tryParse(combo.mrpCtrl.text.trim()) ?? 0.0;
      if (mrp <= 0) {
        selectedCombinationIndex.value = i;
        Get.snackbar(
          'MRP Required',
          'Please enter a valid MRP (greater than 0) for "${combo.label}".',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return false;
      }

      final dType = combo.discountType.value;
      if (dType == 'percent') {
        final pct =
            double.tryParse(combo.discountValueCtrl.text.trim()) ?? 0.0;
        if (pct < 0 || pct > 100) {
          selectedCombinationIndex.value = i;
          Get.snackbar(
            'Invalid Discount Percent',
            'Discount percent for "${combo.label}" must be between 0 and 100%.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return false;
        }
      } else if (dType == 'flat') {
        final flat =
            double.tryParse(combo.discountValueCtrl.text.trim()) ?? 0.0;
        if (flat < 0 || flat > mrp) {
          selectedCombinationIndex.value = i;
          Get.snackbar(
            'Invalid Flat Discount',
            'Flat discount for "${combo.label}" cannot exceed MRP (৳$mrp).',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return false;
        }
      }

      final stock = int.tryParse(combo.stockCtrl.text.trim()) ?? 0;
      if (stock < 1) {
        selectedCombinationIndex.value = i;
        Get.snackbar(
          'Stock Required',
          'Initial stock for "${combo.label}" must be at least 1.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return false;
      }

      final points = int.tryParse(combo.pointsCtrl.text.trim());
      if (points == null || points < 0) {
        selectedCombinationIndex.value = i;
        Get.snackbar(
          'Reward Points Required',
          'Please enter 0 or more reward points for "${combo.label}".',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return false;
      }
    }

    return true;
  }

  void nextStep() {
    if (currentStep.value == 0) {
      if (!validateStep1()) return;
      currentStep.value = 1;
    } else if (currentStep.value == 1) {
      if (!validateStep2()) return;
      currentStep.value = 2;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    } else {
      Get.back();
    }
  }

  void setStep(int step) {
    if (step == currentStep.value) return;
    if (step > currentStep.value) {
      if (currentStep.value == 0 && !validateStep1()) return;
      if (currentStep.value == 1 && !validateStep2()) return;
    }
    currentStep.value = step;
  }

  // --- Submit / Save Product (§6, §7) ---
  Future<bool> saveProduct({bool submitForApproval = false}) async {
    if (!validateStep1()) {
      currentStep.value = 0;
      return false;
    }
    if (!validateStep2()) {
      currentStep.value = 1;
      return false;
    }
    if (!validateStep3()) {
      currentStep.value = 2;
      return false;
    }

    isSaving.value = true;
    try {
      final name = nameCtrl.text.trim();
      final slug = slugCtrl.text.trim();
      final desc = descCtrl.text.trim();
      final handlingDays = int.tryParse(handlingDaysCtrl.text.trim()) ?? 1;
      final returnWindow =
          int.tryParse(returnWindowDaysCtrl.text.trim()) ?? 7;

      // 1. Product-level attributes (§3.3)
      final List<Map<String, dynamic>> productAttributes = [];
      if (hasVariants.value) {
        for (var dim in selectedAttributes) {
          if (dim.values.isNotEmpty) {
            final catAttr = catalogAttributes.firstWhereOrNull(
              (a) => a.name.toLowerCase() == dim.name.toLowerCase(),
            );
            final attrId =
                dim.id.isNotEmpty ? dim.id : (catAttr?.id ?? '');

            if (attrId.isNotEmpty) {
              productAttributes.add({
                'attributeId': attrId,
                'value': dim.values.join(', '),
              });
            }
          }
        }
      }

      // 2. Enabled combinations only (§0.2, §6.1)
      final enabledCombos =
          combinations.where((c) => c.isEnabled.value).toList();

      // 3. Product-level images (§4.1): Deduplicated union of enabled combinations (max 20)
      final List<String> unionImages = [];
      for (var combo in enabledCombos) {
        for (var img in combo.images) {
          if (!unionImages.contains(img) && unionImages.length < 20) {
            unionImages.add(img);
          }
        }
      }
      for (var img in productImages) {
        if (!unionImages.contains(img) && unionImages.length < 20) {
          unionImages.add(img);
        }
      }

      // 4. Variants payload
      final List<Map<String, dynamic>> variantsPayload = [];
      for (var combo in enabledCombos) {
        final mrpTaka = double.tryParse(combo.mrpCtrl.text.trim()) ?? 0.0;
        final mrpMinor = (mrpTaka * 100).round();

        final dType = combo.discountType.value;
        int? discountValueWire;
        int priceMinor;

        if (dType == 'percent') {
          final pct =
              (double.tryParse(combo.discountValueCtrl.text.trim()) ?? 0.0)
                  .round();
          discountValueWire = pct;
          priceMinor = math.max(0, (mrpMinor * (1.0 - (pct / 100.0))).round());
        } else if (dType == 'flat') {
          final flatTaka =
              double.tryParse(combo.discountValueCtrl.text.trim()) ?? 0.0;
          final flatMinor = (flatTaka * 100).round();
          discountValueWire = flatMinor; // In minor units (poisha) per §4.3
          priceMinor = math.max(0, mrpMinor - flatMinor);
        } else {
          discountValueWire = null;
          priceMinor = mrpMinor;
        }

        final stock = int.tryParse(combo.stockCtrl.text.trim()) ?? 1;
        final lowStock =
            int.tryParse(combo.lowStockThresholdCtrl.text.trim()) ?? 5;
        final points = int.tryParse(combo.pointsCtrl.text.trim()) ?? 0;

        // Merged attributes: dimension values + custom attributes (§4.6)
        final Map<String, String> mergedAttributes =
            Map<String, String>.from(combo.attributes);
        combo.customAttributes.forEach((k, v) {
          if (!mergedAttributes.containsKey(k) && v.isNotEmpty) {
            mergedAttributes[k] = v;
          }
        });

        final sku = combo.skuCtrl.text.trim().isNotEmpty
            ? combo.skuCtrl.text.trim()
            : generateSku(
                sellerSlug: shopSlug,
                productSlug: slug.isNotEmpty ? slug : name,
                values: combo.attributes.values.toList(),
              );

        final label = combo.label.isNotEmpty ? combo.label : name;
        final variantImages = combo.images.isNotEmpty
            ? combo.images.toList()
            : (unionImages.isNotEmpty
                ? unionImages.take(10).toList()
                : <String>[]);

        variantsPayload.add({
          'sku': sku,
          'label': label,
          'attributes': mergedAttributes,
          'priceMinor': priceMinor,
          'compareAtPriceMinor': mrpMinor,
          if (dType != 'none') 'discountType': dType,
          if (dType != 'none' && discountValueWire != null)
            'discountValue': discountValueWire,
          'productPoints': points,
          'stockQty': stock,
          'lowStockThreshold': lowStock,
          'openBoxDelivery': combo.openBoxDelivery.value,
          if (variantImages.isNotEmpty) 'images': variantImages,
        });
      }

      final payload = <String, dynamic>{
        'name': name,
        if (slug.isNotEmpty) 'slug': slug,
        if (desc.isNotEmpty) 'description': desc,
        if (selectedCategoryId.value != null)
          'categoryId': selectedCategoryId.value,
        if (selectedBrandId.value != null) 'brandId': selectedBrandId.value,
        'handlingTimeDays': handlingDays,
        'returnPolicy': apiReturnPolicy,
        if (hasReturnWindow) 'returnWindowDays': returnWindow,
        'images': unionImages,
        'attributes': productAttributes,
        'variants': variantsPayload,
      };

      final created = await _api.createProduct(payload);

      if (created != null) {
        final productId = created['id']?.toString();
        bool isSubmitted = false;

        if (submitForApproval && productId != null && productId.isNotEmpty) {
          isSubmitted = await _api.submitProduct(productId);
        }

        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().changeNavIndex(2); // Select Catalog tab (ProductsPage)
          Get.find<HomeController>().triggerCatalogRefresh();
        }

        isSaving.value = false;
        Get.snackbar(
          submitForApproval
              ? 'Product has been submitted'
              : 'Product Saved as Draft',
          submitForApproval
              ? (isSubmitted
                  ? 'Your product has been submitted successfully.'
                  : 'Product created as draft. Could not submit for review.')
              : 'Product draft saved to your catalog.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return true;
      }
    } on DioException catch (dioErr) {
      isSaving.value = false;
      final resData = dioErr.response?.data;
      String errorMsg = 'Failed to save product.';
      if (resData is Map) {
        final errObj = resData['error'];
        if (errObj is Map) {
          final code = errObj['code']?.toString() ?? '';
          final msg = errObj['message']?.toString() ?? '';
          errorMsg = msg.isNotEmpty ? '$msg ($code)' : code;
        } else if (resData['message'] != null) {
          errorMsg = resData['message'].toString();
        }
      }
      Get.snackbar(
        'Save Failed',
        errorMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return false;
    } catch (e) {
      log('Error saving product: $e');
    }

    isSaving.value = false;
    Get.snackbar(
      'Save Failed',
      'Could not save product. Please verify fields and try again.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
    return false;
  }
}
