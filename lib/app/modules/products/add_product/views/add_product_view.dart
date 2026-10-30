import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../data/widgets/shimmer_widget.dart';
import '../../../../routes/app_pages.dart';
import '../../../home/controllers/home_controller.dart';
import '../controllers/add_product_controller.dart';

class AddProductView extends GetView<AddProductController> {
  const AddProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoadingMeta.value) {
          return const ProductListShimmer();
        }

        return Column(
          children: [
            // Stepper Header
            _buildStepperHeader(),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Obx(() {
                  switch (controller.currentStep.value) {
                    case 0:
                      return _buildStep1BasicInfo(context);
                    case 1:
                      return _buildStep2VariantAttributes(context);
                    case 2:
                      return _buildStep3Combinations(context);
                    default:
                      return _buildStep1BasicInfo(context);
                  }
                }),
              ),
            ),

            // Sticky Bottom Bar
            _buildBottomBar(),
          ],
        );
      }),
    );
  }

  // --- AppBar ---
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Iconsax.arrow_left, color: Color(0xFF0F172A), size: 22),
        onPressed: () => controller.previousStep(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New product',
            style: GoogleFonts.inter(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Create and manage your catalog.',
            style: GoogleFonts.inter(
              fontSize: 11.5.sp,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // --- Stepper Tabs matching official Web Portal ---
  Widget _buildStepperHeader() {
    final stepTitles = ['1. Basic info', '2. Variant attributes', '3. Combinations'];

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.5)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Obx(() {
          final cur = controller.currentStep.value;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(stepTitles.length, (i) {
              final isActive = cur == i;

              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () => controller.setStep(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFFF630F) : Colors.white,
                      borderRadius: BorderRadius.circular(22.r),
                      border: Border.all(
                        color: isActive
                            ? const Color(0xFFFF630F)
                            : const Color(0xFFCBD5E1),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      stepTitles[i],
                      style: GoogleFonts.inter(
                        fontSize: 12.5.sp,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  // ===========================================================================
  // STEP 1: Basic Info & Fulfilment
  // ===========================================================================
  Widget _buildStep1BasicInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Basic Details Card
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Name *
              _buildFieldLabel('Product name *'),
              SizedBox(height: 6.h),
              TextField(
                controller: controller.nameCtrl,
                style: GoogleFonts.inter(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w500,
                ),
                decoration: _inputDecoration(
                  hint: 'e.g. Premium Cotton Casual Shirt',
                  prefixIcon: Iconsax.tag,
                ),
              ),
              SizedBox(height: 14.h),

              // Slug (auto)
              _buildFieldLabel('Slug (auto)'),
              SizedBox(height: 6.h),
              TextField(
                controller: controller.slugCtrl,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: const Color(0xFF475569),
                ),
                decoration: _inputDecoration(
                  hint: 'item',
                  prefixIcon: Iconsax.link_21,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isSlugCustomized.value
                          ? Iconsax.edit_2
                          : Iconsax.lock,
                      size: 16.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                    onPressed: () {
                      controller.isSlugCustomized.toggle();
                    },
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Generated automatically from the product name.',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              SizedBox(height: 16.h),

              // Description & Toolbar
              _buildFieldLabel('Description'),
              SizedBox(height: 6.h),
              _buildDescriptionEditor(),
              SizedBox(height: 4.h),
              Text(
                'Use the toolbar to format text — bold, colors, headings and lists.',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // 2. Fulfilment & Returns Card
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fulfilment & returns',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 14.h),

              // Handling Time (days) *
              _buildFieldLabel('Handling time (days) *'),
              SizedBox(height: 6.h),
              Row(
                children: [
                  _buildStepperButton(
                    icon: Icons.remove,
                    onTap: controller.decrementHandlingDays,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: controller.handlingDaysCtrl,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: _inputDecoration(hint: '1'),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _buildStepperButton(
                    icon: Icons.add,
                    onTap: controller.incrementHandlingDays,
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                'Days needed to prepare an order before handover.',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              SizedBox(height: 14.h),

              // Return type *
              _buildFieldLabel('Return type *'),
              SizedBox(height: 6.h),
              Obx(() {
                return DropdownButtonFormField<String>(
                  initialValue: controller.returnType.value,
                  decoration: _inputDecoration(),
                  items: const [
                    DropdownMenuItem(
                      value: 'Return / Replace',
                      child: Text('Return / Replace'),
                    ),
                    DropdownMenuItem(
                      value: 'Replace only',
                      child: Text('Replace only'),
                    ),
                    DropdownMenuItem(
                      value: 'No return / replace',
                      child: Text('No return / replace'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) controller.returnType.value = val;
                  },
                );
              }),

              // Return / Replace window (days) * (Conditionally shown & dynamic label)
              Obx(() {
                if (!controller.hasReturnWindow) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 14.h),
                    _buildFieldLabel(controller.returnWindowLabel),
                    SizedBox(height: 6.h),
                    TextField(
                      controller: controller.returnWindowDaysCtrl,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.inter(fontSize: 13.5.sp),
                      decoration: _inputDecoration(
                        hint: 'e.g. 7',
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 12.w),
                          child: Center(
                            widthFactor: 1,
                            child: Text(
                              'days',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    // Preset chips for days
                    Row(
                      children: [3, 7, 14, 30].map((days) {
                        return Padding(
                          padding: EdgeInsets.only(right: 6.w),
                          child: ActionChip(
                            label: Text('$days days'),
                            labelStyle: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF475569),
                            ),
                            backgroundColor: const Color(0xFFF1F5F9),
                            side: BorderSide.none,
                            padding: EdgeInsets.zero,
                            onPressed: () => controller.setReturnWindow(days),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Days after delivery the buyer can request a return.',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                );
              }),
              SizedBox(height: 14.h),

              // Category *
              _buildFieldLabel('Category *'),
              SizedBox(height: 6.h),
              Obx(() {
                final selectedCat = controller.selectedCategory;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => _showCategorySearchSheet(context),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: selectedCat != null
                                ? const Color(0xFFFF630F).withValues(alpha: 0.6)
                                : const Color(0xFFE2E8F0),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                selectedCat != null ? selectedCat.name : 'Select a category...',
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: selectedCat != null ? FontWeight.w500 : FontWeight.w400,
                                  color: selectedCat != null
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF94A3B8),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              color: const Color(0xFF64748B),
                              size: 24.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (selectedCat != null)
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 8.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 9.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED), // Peach background
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFFFFEDD5)), // Soft peach border
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Selected category path:  ',
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF475569),
                                      ),
                                    ),
                                    TextSpan(
                                      text: selectedCat.path,
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                controller.selectedCategoryId.value = null;
                              },
                              borderRadius: BorderRadius.circular(12.r),
                              child: Padding(
                                padding: EdgeInsets.all(2.w),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16.sp,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              }),
              SizedBox(height: 14.h),

              // Brand (Optional)
              _buildFieldLabel('Brand (Optional)'),
              SizedBox(height: 6.h),
              Obx(() {
                final brands = controller.brands;
                return DropdownButtonFormField<String>(
                  initialValue: controller.selectedBrandId.value,
                  decoration: _inputDecoration(hint: 'Select a brand...'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('No Brand (Unbranded)'),
                    ),
                    ...brands.map((b) {
                      return DropdownMenuItem(
                        value: b['id']?.toString(),
                        child: Text(
                          b['name']?.toString() ?? 'Brand',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                  onChanged: (val) => controller.selectedBrandId.value = val,
                );
              }),
            ],
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  // --- Rich Description Editor ---
  Widget _buildDescriptionEditor() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Toolbar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildToolbarButton(
                    label: 'B',
                    isBold: true,
                    onTap: controller.formatBold,
                  ),
                  _buildToolbarButton(
                    label: 'I',
                    isItalic: true,
                    onTap: controller.formatItalic,
                  ),
                  _buildToolbarButton(
                    label: 'U',
                    isUnderline: true,
                    onTap: controller.formatUnderline,
                  ),
                  const VerticalDivider(width: 12),
                  _buildToolbarIconButton(
                    icon: Icons.format_list_bulleted,
                    onTap: controller.insertBulletList,
                  ),
                  _buildToolbarIconButton(
                    icon: Icons.format_list_numbered,
                    onTap: controller.insertNumberedList,
                  ),
                  const VerticalDivider(width: 12),
                  _buildToolbarIconButton(
                    icon: Icons.cleaning_services_outlined,
                    onTap: controller.clearDescription,
                  ),
                ],
              ),
            ),
          ),
          // Text input
          TextField(
            controller: controller.descCtrl,
            maxLines: 5,
            style: GoogleFonts.inter(fontSize: 13.sp),
            decoration: InputDecoration(
              hintText: 'Write a rich product description...',
              hintStyle: GoogleFonts.inter(
                fontSize: 12.sp,
                color: const Color(0xFF94A3B8),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12.w),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required String label,
    bool isBold = false,
    bool isItalic = false,
    bool isUnderline = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            decoration: isUnderline ? TextDecoration.underline : null,
            fontSize: 14.sp,
            color: const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Icon(icon, size: 18.sp, color: const Color(0xFF334155)),
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Icon(icon, size: 18.sp, color: const Color(0xFF0F172A)),
      ),
    );
  }

  // ===========================================================================
  // STEP 2: Variant Attributes (Single vs Multi-Variant & Presets)
  // ===========================================================================
  Widget _buildStep2VariantAttributes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. "What type of product is this?"
        Text(
          'What type of product is this?',
          style: GoogleFonts.inter(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          'Choose how you want to manage your product options.',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: const Color(0xFF64748B),
          ),
        ),
        SizedBox(height: 14.h),

        // Two Selectable Option Cards (Side by side matching Web Portal)
        Obx(() {
          final isMulti = controller.hasVariants.value;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Single Variant Card
              Expanded(
                child: _buildProductTypeCard(
                  title: 'Single variant product',
                  description:
                      'This product has no variants. Examples: a single item with one price and one stock.',
                  isSelected: !isMulti,
                  onTap: () {
                    controller.hasVariants.value = false;
                    controller.generateCombinations();
                  },
                ),
              ),
              SizedBox(width: 10.w),

              // Multi Variant Card
              Expanded(
                child: _buildProductTypeCard(
                  title: 'Multi variant product',
                  description:
                      'This product has multiple variants such as size, color, etc. You can add attributes and values below.',
                  isSelected: isMulti,
                  onTap: () {
                    controller.hasVariants.value = true;
                    if (controller.selectedAttributes.isEmpty) {
                      controller.addAttribute('Size');
                      controller.addValueToAttribute(0, 'M');
                      controller.addValueToAttribute(0, 'L');
                    }
                    controller.generateCombinations();
                  },
                ),
              ),
            ],
          );
        }),
        SizedBox(height: 18.h),

        // Body according to product type
        Obx(() {
          if (!controller.hasVariants.value) {
            // Single variant product view
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Single variant product: one combination with one price and one stock. Add its details in the next step.',
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 18.h),

                // Combinations Preview
                Text(
                  'Combinations preview',
                  style: GoogleFonts.inter(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  '1 combinations will be created',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 10.h),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    'Single product',
                    style: GoogleFonts.inter(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            );
          }

          // Multi-variant product view
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Variant attributes',
                style: GoogleFonts.inter(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Which attributes vary between your product options? Add values for each — every combination is generated automatically.',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
              SizedBox(height: 12.h),

              // Attributes List
              ...List.generate(controller.selectedAttributes.length, (attrIndex) {
                final attr = controller.selectedAttributes[attrIndex];
                final options = attr.options.isNotEmpty
                    ? attr.options
                    : controller.getPresetsForAttribute(attr.name);
                final isUnderMinimum = attr.values.length < 2;

                return Container(
                  margin: EdgeInsets.only(bottom: 14.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isUnderMinimum
                          ? const Color(0xFFFDBA74)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Dropdown with attribute name & Remove button
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    attr.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    color: Color(0xFF64748B),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 10.h,
                              ),
                            ),
                            onPressed: () =>
                                controller.removeAttribute(attrIndex),
                            child: Text(
                              'Remove',
                              style: GoogleFonts.inter(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFF630F),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),

                      // Warning badge if less than 2 values selected (§3.1)
                      if (isUnderMinimum) ...[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(color: const Color(0xFFFFEDD5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, size: 14, color: Color(0xFFEA580C)),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  'Select at least 2 values for "${attr.name}" (currently ${attr.values.length}).',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFC2410C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),
                      ],

                      // Selected Chips (e.g. [ M × ] [ L × ])
                      if (attr.values.isNotEmpty) ...[
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: attr.values.map((v) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED), // Peach pill
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: const Color(0xFFFFD8A8),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    v,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  InkWell(
                                    onTap: () => controller
                                        .removeValueFromAttribute(attrIndex, v),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 12.h),
                      ],

                      // Admin-set Options Helper (§1.3)
                      if (options.isNotEmpty) ...[
                        Text(
                          'Choose from the admin-set options for this attribute:',
                          style: GoogleFonts.inter(
                            fontSize: 11.5.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        SizedBox(height: 8.h),

                        // Options Toggle Chips
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 6.h,
                          children: options.map((opt) {
                            final isSelected = attr.values.contains(opt);

                            return InkWell(
                              onTap: () => controller.toggleAttributeValue(
                                attrIndex,
                                opt,
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFFF630F)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFFF630F)
                                        : const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: Text(
                                  opt,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 12.h),
                      ],

                      // Free text input is ONLY shown if NOT restricted to select options (§1.3)
                      if (!attr.mustPickFromOptions) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller.newValueCtrl,
                                style: GoogleFonts.inter(fontSize: 13.sp),
                                decoration: _inputDecoration(
                                  hint: 'Enter custom value...',
                                ),
                                onSubmitted: (val) {
                                  controller.addValueToAttribute(attrIndex, val);
                                  controller.newValueCtrl.clear();
                                },
                              ),
                            ),
                            SizedBox(width: 8.w),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F172A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 14.w),
                              ),
                              onPressed: () {
                                controller.addValueToAttribute(
                                  attrIndex,
                                  controller.newValueCtrl.text,
                                );
                                controller.newValueCtrl.clear();
                              },
                              child: const Text(
                                'Add',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              }),

              // "Add Variants" Button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 44.h),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  backgroundColor: Colors.white,
                ),
                onPressed: () => _promptAddAttribute(context),
                child: Text(
                  'Add Variant Attribute',
                  style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Combinations Preview Section
              Text(
                'Combinations preview',
                style: GoogleFonts.inter(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                '${controller.combinations.length} combinations will be created (${controller.combinations.where((c) => c.isEnabled.value).length} active)',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Enable or disable combinations here. At least 2 combinations must stay active, and every value must stay in at least one active combination.',
                style: GoogleFonts.inter(
                  fontSize: 11.5.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
              SizedBox(height: 12.h),

              // Combination Checkbox List with Disable Guard (§3.2)
              ...List.generate(controller.combinations.length, (idx) {
                final combo = controller.combinations[idx];

                return Obx(() {
                  final isChecked = combo.isEnabled.value;

                  return InkWell(
                    onTap: () {
                      controller.toggleCombination(combo);
                    },
                    borderRadius: BorderRadius.circular(6.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 2.w),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 22.w,
                            height: 22.w,
                            child: Checkbox(
                              value: isChecked,
                              activeColor: const Color(0xFFFF630F),
                              checkColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                              onChanged: (_) {
                                controller.toggleCombination(combo);
                              },
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  combo.label,
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5.sp,
                                    fontWeight: isChecked ? FontWeight.w600 : FontWeight.w400,
                                    color: isChecked
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'SKU: ${combo.skuCtrl.text}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.sp,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
              }),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildProductTypeCard({
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        constraints: BoxConstraints(minHeight: 120.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF7ED) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF630F)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Container(
                  width: 18.w,
                  height: 18.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF630F)
                          : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF630F),
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: const Color(0xFF64748B),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _promptAddAttribute(BuildContext context) {
    controller.newAttributeNameCtrl.clear();
    final availableCatalogAttrs = controller.variantCatalogAttributes.where((cat) {
      return !controller.selectedAttributes.any(
        (a) =>
            a.name.toLowerCase() == cat.name.toLowerCase() ||
            (a.id.isNotEmpty && a.id == cat.id),
      );
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 12.h,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Drag Handle
                Center(
                  child: Container(
                    width: 44.w,
                    height: 4.5.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                ),
                SizedBox(height: 18.h),

                // Title & Subtitle
                Text(
                  'Add Variant Attribute',
                  style: GoogleFonts.inter(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Select an attribute from the catalog or type a custom one:',
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    color: const Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 18.h),

                // 1. Catalog Dimensions
                if (availableCatalogAttrs.isNotEmpty) ...[
                  Text(
                    'Catalog Dimensions',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: availableCatalogAttrs.map((catAttr) {
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        child: InkWell(
                          onTap: () {
                            controller.addAttributeFromCatalog(catAttr);
                            Navigator.pop(ctx);
                          },
                          borderRadius: BorderRadius.circular(10.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add_rounded,
                                  size: 16,
                                  color: Color(0xFFFF630F),
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  catAttr.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16.h),
                  const Divider(color: Color(0xFFF1F5F9), thickness: 1.2),
                  SizedBox(height: 14.h),
                ],

                // 2. Custom Attribute Input
                Text(
                  'Custom Attribute Name',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: controller.newAttributeNameCtrl,
                  autofocus: availableCatalogAttrs.isEmpty,
                  style: GoogleFonts.inter(fontSize: 13.5.sp, color: const Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: 'e.g. Size, Color, Storage',
                    hintStyle: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: Color(0xFFFF630F), width: 1.6),
                    ),
                  ),
                  onSubmitted: (val) {
                    final text = val.trim();
                    if (text.isNotEmpty) {
                      controller.addAttribute(text);
                      Navigator.pop(ctx);
                    }
                  },
                ),
                SizedBox(height: 22.h),

                // Bottom Buttons (Right-aligned Cancel & Add Attribute)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF630F),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF630F),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 11.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () {
                        final text = controller.newAttributeNameCtrl.text.trim();
                        if (text.isNotEmpty) {
                          controller.addAttribute(text);
                          Navigator.pop(ctx);
                        }
                      },
                      child: Text(
                        'Add Attribute',
                        style: GoogleFonts.inter(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // STEP 3: Combinations, Media & Pricing (Exact Web Admin Flow)
  // ===========================================================================
  Widget _buildStep3Combinations(BuildContext context) {
    return Obx(() {
      final combos = controller.combinations;
      if (combos.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Text(
              'No combinations generated yet.',
              style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF64748B)),
            ),
          ),
        );
      }

      final isMulti = controller.hasVariants.value && combos.length > 1;
      final selectedIdx = controller.selectedCombinationIndex.value;
      final combo = controller.currentCombination ?? combos.first;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // If multi-variant, show combination tabs or switcher
          if (isMulti) ...[
            Text(
              'Combinations (${combos.length})',
              style: GoogleFonts.inter(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 8.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(combos.length, (i) {
                  final c = combos[i];
                  final isSelected = selectedIdx == i;
                  final isEnabled = c.isEnabled.value;

                  return GestureDetector(
                    onTap: () => controller.selectedCombinationIndex.value = i,
                    child: Container(
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFF630F)
                            : (isEnabled ? Colors.white : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFF630F)
                              : const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            c.label,
                            style: GoogleFonts.inter(
                              fontSize: 12.5.sp,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (isEnabled ? const Color(0xFF334155) : const Color(0xFF94A3B8)),
                            ),
                          ),
                          if (!isEnabled) ...[
                            SizedBox(width: 4.w),
                            Text(
                              '(Disabled)',
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                color: isSelected ? Colors.white70 : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 14.h),
          ],

          // Active Combination Title matching Web portal
          Row(
            children: [
              Expanded(
                child: Text(
                  combo.label,
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              if (!combo.isEnabled.value)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Text(
                    'Disabled in Step 2',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),

          if (!combo.isEnabled.value) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Color(0xFFDC2626)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'This combination is disabled in Step 2. It will not be created or published. Return to Step 2 if you wish to enable it.',
                      style: GoogleFonts.inter(fontSize: 11.5.sp, color: const Color(0xFFDC2626)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 1. Photos Card
          _buildPhotosCard(combo),
          SizedBox(height: 16.h),

          // 2. Pricing Card
          _buildPricingCard(combo),
          SizedBox(height: 16.h),

          // 3. Inventory Card
          _buildInventoryCard(combo),
          SizedBox(height: 16.h),

          // 4. Delivery Card
          _buildDeliveryCard(combo),
          SizedBox(height: 16.h),

          // 5. Details Card
          _buildDetailsCard(combo),
          SizedBox(height: 16.h),

          // 6. Custom attributes Card
          _buildCustomAttributesCard(combo, context),
          SizedBox(height: 24.h),
        ],
      );
    });
  }

  // --- 1. Photos Card ---
  Widget _buildPhotosCard(ProductVariantCombination combo) {
    return _buildCardWrapper(
      title: 'Photos',
      icon: Icons.image_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Photos'),
          SizedBox(height: 8.h),

          // Dashed Upload Box
          InkWell(
            onTap: controller.isUploadingImage.value
                ? null
                : () => controller.pickAndUploadCombinationImage(combo),
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: const Color(0xFFFF8A4C),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: controller.isUploadingImage.value
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF630F),
                        strokeWidth: 2,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Choose images to upload',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFF630F),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Pick images from your device. The first image is used as the cover.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11.5.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          // Thumbnails
          Obx(() {
            if (combo.images.isEmpty) return const SizedBox.shrink();

            return Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: List.generate(combo.images.length, (i) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.network(
                          combo.images[i],
                          width: 76.w,
                          height: 76.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (i == 0)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF630F),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'Cover',
                              style: GoogleFonts.inter(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () =>
                              controller.removeCombinationImage(combo, i),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- 2. Pricing Card ---
  Widget _buildPricingCard(ProductVariantCombination combo) {
    return _buildCardWrapper(
      title: 'Pricing',
      icon: Iconsax.tag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // MRP & Discount Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MRP *
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Iconsax.tag, size: 14.sp, color: const Color(0xFF64748B)),
                        SizedBox(width: 4.w),
                        _buildFieldLabel('MRP *'),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    TextField(
                      controller: combo.mrpCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.inter(fontSize: 13.5.sp, fontWeight: FontWeight.bold),
                      decoration: _inputDecoration(hint: 'e.g. 1000'),
                      onChanged: (_) {
                        combo.priceUpdateTrigger.value++;
                        controller.combinations.refresh();
                      },
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'The original / maximum retail price in taka (e.g. 1000 or 1000.50). The selling price is calculated from this.',
                      style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),

              // Discount (Optional)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4.w,
                      children: [
                        Text('% ', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.sp, color: const Color(0xFF64748B))),
                        _buildFieldLabel('Discount'),
                        _buildOptionalBadge(),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Obx(() {
                      return DropdownButtonFormField<String>(
                        key: ValueKey(combo.discountType.value),
                        initialValue: combo.discountType.value,
                        decoration: _inputDecoration(),
                        items: const [
                          DropdownMenuItem(value: 'none', child: Text('None')),
                          DropdownMenuItem(value: 'percent', child: Text('Percent (%)')),
                          DropdownMenuItem(value: 'flat', child: Text('Flat (৳)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            combo.discountType.value = val;
                            combo.priceUpdateTrigger.value++;
                            controller.combinations.refresh();
                          }
                        },
                      );
                    }),
                    Obx(() {
                      if (combo.discountType.value == 'none') {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: TextField(
                          controller: combo.discountValueCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: GoogleFonts.inter(fontSize: 13.5.sp),
                          decoration: _inputDecoration(
                            hint: combo.discountType.value == 'percent' ? 'e.g. 15%' : 'e.g. 100৳',
                          ),
                          onChanged: (_) {
                            combo.priceUpdateTrigger.value++;
                            controller.combinations.refresh();
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Selling Price Banner
          Row(
            children: [
              Icon(Iconsax.tag, size: 14.sp, color: const Color(0xFF64748B)),
              SizedBox(width: 4.w),
              _buildFieldLabel('Selling price'),
            ],
          ),
          SizedBox(height: 6.h),
          Obx(() {
            combo.priceUpdateTrigger.value;
            combo.discountType.value;
            final sellingPrice = combo.calculatedSellingPrice;
            final hasMrp = (double.tryParse(combo.mrpCtrl.text.trim()) ?? 0.0) > 0;

            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED), // Peach background
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFFFEDD5)),
              ),
              child: Text(
                hasMrp
                    ? '৳${sellingPrice.toStringAsFixed(2)}'
                    : 'Enter the MRP above to see the selling price.',
                style: GoogleFonts.inter(
                  fontSize: hasMrp ? 18.sp : 13.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF630F),
                ),
              ),
            );
          }),
          SizedBox(height: 4.h),
          Text(
            'Auto-calculated: MRP minus discount. You don\'t need to type it.',
            style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFF94A3B8)),
          ),
          SizedBox(height: 14.h),

          // Points *
          Row(
            children: [
              const Icon(Icons.stars_rounded, size: 16, color: Color(0xFFD97706)),
              SizedBox(width: 4.w),
              _buildFieldLabel('Points *'),
            ],
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: combo.pointsCtrl,
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(fontSize: 13.5.sp),
            decoration: _inputDecoration(hint: '0'),
          ),
          SizedBox(height: 4.h),
          Text(
            'Mandatory. Reward points a customer earns per unit. Enter 0 for no points.',
            style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  // --- 3. Inventory Card ---
  Widget _buildInventoryCard(ProductVariantCombination combo) {
    return _buildCardWrapper(
      title: 'Inventory',
      icon: Iconsax.box,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stock *
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 34.h,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: _buildFieldLabel('Stock *'),
                  ),
                ),
                SizedBox(height: 6.h),
                TextField(
                  controller: combo.stockCtrl,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(fontSize: 13.5.sp),
                  decoration: _inputDecoration(hint: '10'),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),

          // Low stock alert (Optional)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 34.h,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4.w,
                      children: [
                        _buildFieldLabel('Low stock alert'),
                        _buildOptionalBadge(),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                TextField(
                  controller: combo.lowStockThresholdCtrl,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(fontSize: 13.5.sp),
                  decoration: _inputDecoration(hint: '5'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. Delivery Card ---
  Widget _buildDeliveryCard(ProductVariantCombination combo) {
    return _buildCardWrapper(
      title: 'Delivery',
      icon: Icons.local_shipping_outlined,
      child: Obx(() {
        final isChecked = combo.openBoxDelivery.value;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: isChecked,
              activeColor: const Color(0xFFFF630F),
              onChanged: (val) {
                combo.openBoxDelivery.value = val ?? true;
              },
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  Text(
                    'Open Box Delivery item',
                    style: GoogleFonts.inter(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'The customer can open and check this item on delivery before sharing the OTP.',
                    style: GoogleFonts.inter(
                      fontSize: 11.5.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // --- 5. Details Card ---
  Widget _buildDetailsCard(ProductVariantCombination combo) {
    return _buildCardWrapper(
      title: 'Details',
      icon: Iconsax.document_text,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Label'),
                SizedBox(height: 6.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    combo.label,
                    style: GoogleFonts.inter(fontSize: 13.5.sp, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Generated automatically from the variant values above.',
                  style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),

          // SKU
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('SKU'),
                SizedBox(height: 6.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    combo.skuCtrl.text,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Generated automatically — includes your shop code so it can never clash with another seller\'s SKU.',
                  style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 6. Custom attributes Card (§1.3, §4.6) ---
  Widget _buildCustomAttributesCard(
    ProductVariantCombination combo,
    BuildContext context,
  ) {
    return _buildCardWrapper(
      title: 'Custom attributes',
      icon: Iconsax.menu_1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Extra details for this combination only — they don\'t create new combinations.',
                  style: GoogleFonts.inter(fontSize: 11.5.sp, color: const Color(0xFF64748B)),
                ),
              ),
              SizedBox(width: 6.w),
              _buildOptionalBadge(),
            ],
          ),
          SizedBox(height: 12.h),

          // Render existing custom attributes
          Obx(() {
            final customEntries = combo.customAttributes.entries.toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (customEntries.isNotEmpty) ...[
                  ...customEntries.map((entry) {
                    final key = entry.key;
                    final val = entry.value;

                    // Match catalog attribute for options dropdown
                    final catAttr = controller.catalogAttributes.firstWhereOrNull(
                      (a) => a.name.toLowerCase() == key.toLowerCase(),
                    );
                    final hasOptions = catAttr != null && catAttr.options.isNotEmpty;

                    return Container(
                      margin: EdgeInsets.only(bottom: 10.h),
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 85.w,
                            child: Text(
                              key,
                              style: GoogleFonts.inter(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: hasOptions
                                ? DropdownButtonFormField<String>(
                                    initialValue: catAttr.options.contains(val) ? val : null,
                                    isExpanded: true,
                                    decoration: _inputDecoration(hint: 'Select ${catAttr.name}'),
                                    items: catAttr.options.map((opt) {
                                      return DropdownMenuItem<String>(
                                        value: opt,
                                        child: Text(opt, style: GoogleFonts.inter(fontSize: 12.5.sp)),
                                      );
                                    }).toList(),
                                    onChanged: (newVal) {
                                      if (newVal != null) {
                                        controller.addCustomAttributeToCombo(combo, key, newVal);
                                      }
                                    },
                                  )
                                : TextFormField(
                                    initialValue: val,
                                    style: GoogleFonts.inter(fontSize: 12.5.sp),
                                    decoration: _inputDecoration(hint: 'Enter value...'),
                                    onChanged: (newVal) {
                                      controller.addCustomAttributeToCombo(combo, key, newVal);
                                    },
                                  ),
                          ),
                          SizedBox(width: 4.w),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                            onPressed: () => controller.removeCustomAttributeFromCombo(combo, key),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: 6.h),
                ],

                // "Add custom attribute" button
                InkWell(
                  onTap: () => _showAddCustomAttributeDialog(context, combo),
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, size: 16, color: Color(0xFFFF630F)),
                        SizedBox(width: 6.w),
                        Text(
                          'Add custom attribute',
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFF630F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _showAddCustomAttributeDialog(
    BuildContext context,
    ProductVariantCombination combo,
  ) {
    final availableAttrs = controller.getAvailableCustomAttributes(combo);
    final customKeyCtrl = TextEditingController();
    final customValCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 20.h,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Custom Attribute',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Add extra information for this combination (e.g. Material, Pattern, Care).',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
              SizedBox(height: 14.h),

              if (availableAttrs.isNotEmpty) ...[
                Text(
                  'From Catalog (Non-variant)',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: availableAttrs.map((attr) {
                    return ActionChip(
                      label: Text(attr.name),
                      avatar: const Icon(Icons.add, size: 14),
                      onPressed: () {
                        Navigator.pop(ctx);
                        final defaultVal =
                            attr.options.isNotEmpty ? attr.options.first : '';
                        controller.addCustomAttributeToCombo(
                          combo,
                          attr.name,
                          defaultVal,
                        );
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 14.h),
                const Divider(),
                SizedBox(height: 10.h),
              ],

              Text(
                'Custom Attribute',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: customKeyCtrl,
                decoration: _inputDecoration(hint: 'Attribute name (e.g. Material)'),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: customValCtrl,
                decoration: _inputDecoration(hint: 'Value (e.g. 100% Cotton)'),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF630F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onPressed: () {
                    final key = customKeyCtrl.text.trim();
                    final val = customValCtrl.text.trim();
                    if (key.isNotEmpty) {
                      controller.addCustomAttributeToCombo(combo, key, val);
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Add Attribute', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Helpers for Card Wrappers ---
  Widget _buildCardWrapper({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: const Color(0xFFFF630F)),
              SizedBox(width: 8.w),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }

  Widget _buildOptionalBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        'Optional',
        style: GoogleFonts.inter(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }

  // --- Sticky Bottom Bar ---
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final cur = controller.currentStep.value;
          final isLastStep = cur == 2;

          return Row(
            children: [
              if (cur > 0) ...[
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 48.h,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: () => controller.previousStep(),
                      child: Text(
                        'Back',
                        style: GoogleFonts.inter(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              if (isLastStep) ...[
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 48.h,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF630F)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: controller.isSaving.value
                          ? null
                          : () async {
                              final ok = await controller.saveProduct(
                                submitForApproval: false,
                              );
                              if (ok) {
                                if (Get.isRegistered<HomeController>()) {
                                  Get.find<HomeController>().changeNavIndex(2);
                                  Get.find<HomeController>().triggerCatalogRefresh();
                                }
                                Get.until((route) =>
                                    route.settings.name == Routes.HOME ||
                                    route.isFirst);
                              }
                            },
                      child: Text(
                        'Save Draft',
                        style: GoogleFonts.inter(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF630F),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              Expanded(
                flex: isLastStep ? 2 : 2,
                child: SizedBox(
                  height: 48.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF630F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    onPressed: controller.isSaving.value
                        ? null
                        : () async {
                            if (!isLastStep) {
                              controller.nextStep();
                            } else {
                              final ok = await controller.saveProduct(
                                submitForApproval: true,
                              );
                              if (ok) {
                                if (Get.isRegistered<HomeController>()) {
                                  Get.find<HomeController>().changeNavIndex(2);
                                  Get.find<HomeController>().triggerCatalogRefresh();
                                }
                                Get.until((route) =>
                                    route.settings.name == Routes.HOME ||
                                    route.isFirst);
                              }
                            }
                          },
                    child: controller.isSaving.value
                        ? Text(
                            isLastStep ? 'Submitting...' : 'Saving...',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isLastStep
                                ? 'Create and submit'
                                : 'Continue',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // --- Helpers ---
  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1E293B),
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 12.5.sp,
        color: const Color(0xFF94A3B8),
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 18.sp, color: const Color(0xFF94A3B8))
          : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Color(0xFFFF630F), width: 1.5),
      ),
    );
  }

  void _showCategorySearchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _CategorySearchSheet(),
    );
  }
}

class _CategorySearchSheet extends GetView<AddProductController> {
  const _CategorySearchSheet();

  @override
  Widget build(BuildContext context) {
    final searchCtrl = TextEditingController();
    final searchQuery = ''.obs;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final allCats = controller.flatCategories;
    final selectedId = controller.selectedCategoryId.value;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 16.h + bottomInset),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Header
          Row(
            children: [
              Text(
                'Select Category',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                color: const Color(0xFF64748B),
                onPressed: () => Navigator.of(context).pop(),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Search Field
          Obx(
            () => Container(
              height: 42.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: searchQuery.value.isNotEmpty
                      ? const Color(0xFFFF630F)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: searchCtrl,
                autofocus: false,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  hintText: 'Search category or department...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                  prefixIcon: Icon(
                    Iconsax.search_normal_1,
                    size: 16.sp,
                    color: searchQuery.value.isNotEmpty
                        ? const Color(0xFFFF630F)
                        : const Color(0xFF94A3B8),
                  ),
                  suffixIcon: searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16),
                          color: const Color(0xFF64748B),
                          onPressed: () {
                            searchCtrl.clear();
                            searchQuery.value = '';
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                ),
                onChanged: (val) => searchQuery.value = val,
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // Filtered list
          Expanded(
            child: Obx(() {
              final query = searchQuery.value.toLowerCase().trim();
              final filtered = query.isEmpty
                  ? allCats.toList()
                  : allCats.where((c) {
                      final nameMatch = c.name.toLowerCase().contains(query);
                      final parentMatch = c.parentName?.toLowerCase().contains(query) ?? false;
                      final pathMatch = c.path.toLowerCase().contains(query);
                      return nameMatch || parentMatch || pathMatch;
                    }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 28.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.search_status,
                          size: 34.sp,
                          color: const Color(0xFFCBD5E1),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'No categories matching "${searchQuery.value}"',
                          style: GoogleFonts.inter(
                            fontSize: 12.5.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (ctx, i) => const Divider(
                  height: 1,
                  thickness: 0.6,
                  color: Color(0xFFF1F5F9),
                ),
                itemBuilder: (ctx, index) {
                  final cat = filtered[index];
                  final isSelected = cat.id == selectedId;

                  return InkWell(
                    onTap: () {
                      controller.selectedCategoryId.value = cat.id;
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 11.h,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? const Color(0xFFFF630F)
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                                if (cat.parentName != null) ...[
                                  SizedBox(height: 2.h),
                                  Text(
                                    'in ${cat.parentName}',
                                    style: GoogleFonts.inter(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFFFF630F),
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
