import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../data/theme/app_colors.dart';
import '../../../data/widgets/shimmer_widget.dart';
import '../controllers/reviews_controller.dart';

class ReviewsView extends GetView<ReviewsController> {
  const ReviewsView({super.key});

  void _showReplyDialog(BuildContext context, String reviewId, String customerName) {
    final replyCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Reply to $customerName',
          style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: replyCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Thank you for your feedback...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () {
              final text = replyCtrl.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(ctx);
                controller.replyToReview(reviewId, text);
              }
            },
            child: const Text('Send Reply', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: AppColors.textPrimary, size: 22),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Customer Reviews',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, color: AppColors.textPrimary, size: 20),
            onPressed: controller.fetchReviews,
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const ProductListShimmer();
        }
        if (controller.reviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.star_1, size: 54.sp, color: AppColors.textMuted),
                SizedBox(height: 12.h),
                Text(
                  'No reviews found',
                  style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Verified customer ratings will appear here.',
                  style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchReviews,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            itemCount: controller.reviews.length,
            separatorBuilder: (_, _) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final r = controller.reviews[index];
              return Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          r.customerName,
                          style: GoogleFonts.inter(fontSize: 13.5.sp, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                            SizedBox(width: 3.w),
                            Text(
                              r.rating.toStringAsFixed(1),
                              style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      r.productName,
                      style: GoogleFonts.inter(fontSize: 11.sp, color: AppColors.primary, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      r.comment,
                      style: GoogleFonts.inter(fontSize: 12.5.sp, color: AppColors.textPrimary),
                    ),
                    if (r.reply != null) ...[
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'Your Reply: ${r.reply}',
                          style: GoogleFonts.inter(fontSize: 11.5.sp, color: AppColors.textSecondary),
                        ),
                      ),
                    ] else ...[
                      SizedBox(height: 8.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Iconsax.message_text, size: 14),
                          label: const Text('Reply'),
                          onPressed: () => _showReplyDialog(context, r.id, r.customerName),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

