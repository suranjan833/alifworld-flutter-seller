import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/widgets/step_indicator_widget.dart';
import '../../controllers/store_setup_controller.dart';
import 'compliance_controller.dart';

class ComplianceView extends GetView<ComplianceController> {
  const ComplianceView({super.key});

  @override
  Widget build(BuildContext context) {
    final setupController = Get.find<StoreSetupController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 28.h,
            ),
            child: IntrinsicHeight(
              child: Form(
                key: controller.formKey,
                child: Obx(() {
                  final fields = controller.dynamicFields;
                  final loaded = controller.fieldsLoaded.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Top Mobile Step Indicator
                      StepIndicatorWidget(
                        currentStep: setupController.currentStep.value,
                        onStepTapped: (step) => setupController.goToStep(step),
                      ),
                      SizedBox(height: 16.h),

                      // 2. Compliance Card smoothly stretching to fill available height
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(18.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Compliance',
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                'Fields required by the platform. Marked fields are required.',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              SizedBox(height: 20.h),

                              if (!loaded)
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24.h),
                                    child: Column(
                                      children: [
                                        const CircularProgressIndicator(
                                          color: Color(0xFFFF630F),
                                          strokeWidth: 2,
                                        ),
                                        SizedBox(height: 12.h),
                                        Text(
                                          'Loading compliance fields…',
                                          style: GoogleFonts.inter(
                                            fontSize: 12.sp,
                                            color: const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else if (fields.isEmpty)
                                Container(
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                      color: const Color(0xFFBBF7D0),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFF16A34A),
                                        size: 20,
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Text(
                                          'No compliance fields required for your account.',
                                          style: GoogleFonts.inter(
                                            fontSize: 13.sp,
                                            color: const Color(0xFF16A34A),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ...List.generate(fields.length, (i) {
                                  final field = fields[i];
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: i < fields.length - 1 ? 18.h : 0,
                                    ),
                                    child: _buildDynamicField(field),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDynamicField(ComplianceFieldState field) {
    final isNumeric = field.fieldType == 'numeric';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field Label
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              field.label,
              style: GoogleFonts.inter(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
            if (field.required)
              Text(
                ' *',
                style: GoogleFonts.inter(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF630F),
                ),
              )
            else
              Text(
                ' (Optional)',
                style: GoogleFonts.inter(
                  fontSize: 12.5.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),

        // Input Field
        TextFormField(
          controller: field.controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          inputFormatters:
              isNumeric ? [FilteringTextInputFormatter.digitsOnly] : null,
          style: GoogleFonts.inter(
            fontSize: 13.5.sp,
            color: const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: '',
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 12.h,
            ),
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
              borderSide: const BorderSide(color: Color(0xFFFF630F), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
          validator: (val) {
            final v = val?.trim() ?? '';
            if (field.required && v.isEmpty) {
              return '${field.label} is required';
            }
            if (v.isNotEmpty && field.regex != null && field.regex!.isNotEmpty) {
              if (!RegExp(field.regex!).hasMatch(v)) {
                return field.helpHint ?? 'Invalid format for ${field.label}';
              }
            }
            return null;
          },
        ),
        if (field.helpHint != null && field.helpHint!.isNotEmpty) ...[
          SizedBox(height: 6.h),
          Text(
            field.helpHint!,
            style: GoogleFonts.inter(
              fontSize: 11.5.sp,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ],
    );
  }
}
