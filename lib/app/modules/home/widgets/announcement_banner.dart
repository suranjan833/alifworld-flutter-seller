import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../data/models/announcement_model.dart';
import '../../../data/theme/app_colors.dart';
import '../controllers/home_controller.dart';
import 'announcements_sheet.dart';

class AnnouncementBanner extends GetView<HomeController> {
  const AnnouncementBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.announcements;
      if (list.isEmpty) return const SizedBox.shrink();

      final urgent = controller.urgentAnnouncements;
      final AnnouncementModel featured = urgent.isNotEmpty ? urgent.first : list.first;
      final isUrgent = featured.priority == AnnouncementPriority.urgent;

      return GestureDetector(
        onTap: () => AnnouncementsSheet.show(context),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isUrgent ? const Color(0xFFFEF2F2) : const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isUrgent ? const Color(0xFFFCA5A5) : const Color(0xFFFFEDD5),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isUrgent ? Colors.red : AppColors.primary).withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: isUrgent ? const Color(0xFFEF4444) : AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  isUrgent ? Iconsax.warning_2 : Iconsax.notification_status,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: isUrgent ? Colors.red.shade100 : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            featured.priorityLabel,
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                              color: isUrgent ? Colors.red.shade900 : Colors.orange.shade900,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            featured.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      featured.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13.sp,
                color: isUrgent ? Colors.red : AppColors.primary,
              ),
            ],
          ),
        ),
      );
    });
  }
}
