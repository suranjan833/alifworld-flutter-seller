import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../data/models/coupon_model.dart';
import '../../../data/theme/app_colors.dart';
import '../../../data/widgets/shimmer_widget.dart';
import '../controllers/coupons_controller.dart';

class CouponsView extends GetView<CouponsController> {
  const CouponsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: AppColors.textPrimary, size: 22),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Coupons',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Iconsax.refresh, color: AppColors.textPrimary, size: 20),
            onPressed: controller.fetchCoupons,
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const ProductListShimmer();
        }

        return RefreshIndicator(
          onRefresh: controller.fetchCoupons,
          color: const Color(0xFFFF630F),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Section (Title + [New coupon] Button)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coupons',
                          style: GoogleFonts.inter(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Discount codes for your shop.',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    Obx(() {
                      if (controller.showNewCouponForm.value) {
                        return const SizedBox.shrink();
                      }
                      return ElevatedButton(
                        onPressed: controller.toggleNewCouponForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF630F),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        ),
                        child: Text(
                          'New coupon',
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                SizedBox(height: 16.h),

                // Card 1: New Coupon Form (When [New coupon] is active)
                Obx(() {
                  if (!controller.showNewCouponForm.value) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      _buildNewCouponCard(context),
                      SizedBox(height: 16.h),
                    ],
                  );
                }),

                // Card 2: Coupons List / Empty state
                _buildCouponsListCard(context),
              ],
            ),
          ),
        );
      }),
    );
  }

  // =========================================================================
  // CARD 1: New Coupon Form (Matches Web Screenshot Exactly)
  // =========================================================================
  Widget _buildNewCouponCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New coupon',
            style: GoogleFonts.inter(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 14.h),

          // Row 1: Coupon code * & Description
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildCouponCodeField()),
                    SizedBox(width: 14.w),
                    Expanded(child: _buildDescriptionField()),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCouponCodeField(),
                  SizedBox(height: 12.h),
                  _buildDescriptionField(),
                ],
              );
            },
          ),
          SizedBox(height: 12.h),

          // Row 2: Discount type & Discount value *
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildDiscountTypeField()),
                    SizedBox(width: 14.w),
                    Expanded(child: _buildDiscountValueField()),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDiscountTypeField(),
                  SizedBox(height: 12.h),
                  _buildDiscountValueField(),
                ],
              );
            },
          ),
          SizedBox(height: 12.h),

          // Row 3: Minimum order (minor units) & Usage limit
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildMinOrderField()),
                    SizedBox(width: 14.w),
                    Expanded(child: _buildUsageLimitField()),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMinOrderField(),
                  SizedBox(height: 12.h),
                  _buildUsageLimitField(),
                ],
              );
            },
          ),
          SizedBox(height: 12.h),

          // Row 4: Starts at & Ends at (Date Time Pickers)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildDateField(context, isStart: true)),
                    SizedBox(width: 14.w),
                    Expanded(child: _buildDateField(context, isStart: false)),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateField(context, isStart: true),
                  SizedBox(height: 12.h),
                  _buildDateField(context, isStart: false),
                ],
              );
            },
          ),
          SizedBox(height: 12.h),

          // Checkbox: [x] Active
          Obx(() {
            return Row(
              children: [
                SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: Checkbox(
                    value: controller.isActive.value,
                    activeColor: const Color(0xFFFF630F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                    onChanged: (val) => controller.isActive.value = val ?? true,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Active',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: 16.h),

          // Row 5: Action Buttons [Save] and [Cancel]
          Row(
            children: [
              Obx(() {
                final isBusy = controller.isSubmitting.value;
                return ElevatedButton(
                  onPressed: isBusy ? null : controller.submitCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF630F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: isBusy
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Save',
                          style: GoogleFonts.inter(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                );
              }),
              SizedBox(width: 10.w),
              OutlinedButton(
                onPressed: controller.toggleNewCouponForm,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Coupon code *'),
        SizedBox(height: 5.h),
        TextField(
          controller: controller.codeController,
          textCapitalization: TextCapitalization.characters,
          style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w600),
          decoration: _buildInputDecoration(hint: ''),
        ),
        SizedBox(height: 4.h),
        Text(
          'Customers enter this code at checkout.',
          style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Description'),
        SizedBox(height: 5.h),
        TextField(
          controller: controller.descriptionController,
          style: GoogleFonts.inter(fontSize: 13.sp),
          decoration: _buildInputDecoration(hint: ''),
        ),
      ],
    );
  }

  Widget _buildDiscountTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Discount type'),
        SizedBox(height: 5.h),
        Obx(() {
          return DropdownButtonFormField<String>(
            initialValue: controller.discountType.value,
            style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF1E293B)),
            decoration: _buildInputDecoration(hint: ''),
            items: controller.discountTypeList.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) controller.discountType.value = val;
            },
          );
        }),
      ],
    );
  }

  Widget _buildDiscountValueField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Discount value *'),
        SizedBox(height: 5.h),
        TextField(
          controller: controller.discountValueController,
          keyboardType: TextInputType.number,
          style: GoogleFonts.inter(fontSize: 13.sp),
          decoration: _buildInputDecoration(hint: ''),
        ),
        SizedBox(height: 4.h),
        Text(
          'For percentage: 10 means 10%. For fixed: amount in minor units.',
          style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildMinOrderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Minimum order (minor units)'),
        SizedBox(height: 5.h),
        TextField(
          controller: controller.minOrderMinorController,
          keyboardType: TextInputType.number,
          style: GoogleFonts.inter(fontSize: 13.sp),
          decoration: _buildInputDecoration(hint: ''),
        ),
      ],
    );
  }

  Widget _buildUsageLimitField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Usage limit'),
        SizedBox(height: 5.h),
        TextField(
          controller: controller.usageLimitController,
          keyboardType: TextInputType.number,
          style: GoogleFonts.inter(fontSize: 13.sp),
          decoration: _buildInputDecoration(hint: ''),
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context, {required bool isStart}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(isStart ? 'Starts at' : 'Ends at'),
        SizedBox(height: 5.h),
        Obx(() {
          final dt = isStart ? controller.startsAt.value : controller.endsAt.value;
          final displayText = dt != null
              ? '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
              : 'dd-mm-yyyy --:--';

          return InkWell(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: dt ?? DateTime.now(),
                firstDate: DateTime(2024),
                lastDate: DateTime(2035),
              );
              if (pickedDate != null && context.mounted) {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(dt ?? DateTime.now()),
                );
                final finalDt = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime?.hour ?? 0,
                  pickedTime?.minute ?? 0,
                );
                if (isStart) {
                  controller.startsAt.value = finalDt;
                } else {
                  controller.endsAt.value = finalDt;
                }
              }
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    displayText,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: dt != null ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                    ),
                  ),
                  const Icon(Iconsax.calendar_1, size: 18, color: Color(0xFF64748B)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  InputDecoration _buildInputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: Color(0xFFFF630F), width: 1.2),
      ),
    );
  }

  // =========================================================================
  // CARD 2: Coupons List / Empty state (Matches Screenshot)
  // =========================================================================
  Widget _buildCouponsListCard(BuildContext context) {
    return Obx(() {
      if (controller.coupons.isEmpty) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 48.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 36.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: const Color(0xFFCBD5E1),
                style: BorderStyle.solid,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.box,
                  size: 40.sp,
                  color: const Color(0xFF64748B),
                ),
                SizedBox(height: 12.h),
                Text(
                  'No coupons yet. Create one to offer discounts.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.coupons.length,
        separatorBuilder: (_, _) => SizedBox(height: 10.h),
        itemBuilder: (context, index) {
          final coupon = controller.coupons[index];
          return _buildCouponItem(context, coupon);
        },
      );
    });
  }

  Widget _buildCouponItem(BuildContext context, CouponModel coupon) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF630F).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: const Color(0xFFFF630F).withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      coupon.code,
                      style: GoogleFonts.inter(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFF630F),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      coupon.formattedDiscount,
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Switch.adaptive(
                    value: coupon.isActive,
                    activeTrackColor: const Color(0xFFFF630F),
                    onChanged: (_) => controller.toggleCouponActive(coupon),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.trash, size: 18, color: Color(0xFFEF4444)),
                    tooltip: 'Delete',
                    onPressed: () => _confirmDelete(coupon.id, coupon.code),
                  ),
                ],
              ),
            ],
          ),
          if (coupon.description != null && coupon.description!.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              coupon.description!,
              style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF475569)),
            ),
          ],
          SizedBox(height: 8.h),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Min order: ৳${(coupon.minOrderMinor / 100).toStringAsFixed(0)}',
                style: GoogleFonts.inter(fontSize: 11.5.sp, color: const Color(0xFF64748B)),
              ),
              Text(
                'Usage: ${coupon.usedCount} / ${coupon.usageLimit}',
                style: GoogleFonts.inter(fontSize: 11.5.sp, color: const Color(0xFF64748B)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id, String code) {
    Get.defaultDialog(
      title: 'Delete Coupon',
      titleStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16.sp),
      middleText: 'Are you sure you want to delete coupon "$code"?',
      middleTextStyle: GoogleFonts.inter(fontSize: 13.sp),
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFEF4444),
      onConfirm: () {
        Get.back();
        controller.deleteCoupon(id);
      },
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF334155),
      ),
    );
  }
}
