import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../data/models/announcement_model.dart';
import '../../../data/theme/app_colors.dart';
import '../../../data/widgets/shimmer_widget.dart';
import '../controllers/announcements_sheet_controller.dart';

class AnnouncementsSheet extends GetView<AnnouncementsSheetController> {
  const AnnouncementsSheet({super.key});

  static Future<void> show(BuildContext context) {
    if (!Get.isRegistered<AnnouncementsSheetController>()) {
      Get.put(AnnouncementsSheetController());
    }
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AnnouncementsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sheetCtrl = Get.isRegistered<AnnouncementsSheetController>()
        ? controller
        : Get.put(AnnouncementsSheetController());
    final homeCtrl = sheetCtrl.homeController;

    return Container(
      height: 0.85.sh,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // Drag handle
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 12.h),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.notification_bing,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seller Announcements',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Obx(() => Text(
                            homeCtrl.unreadCount > 0
                                ? '${homeCtrl.unreadCount} unread update${homeCtrl.unreadCount > 1 ? 's' : ''}'
                                : 'All updates are caught up',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: homeCtrl.unreadCount > 0 ? AppColors.primary : AppColors.textMuted,
                              fontWeight: homeCtrl.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                            ),
                          )),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(height: 20.h, color: AppColors.divider),

          // Action & Filter row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Obx(
              () => Row(
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: !sheetCtrl.showOnlyUnread.value,
                    selectedColor: AppColors.primaryLight,
                    labelStyle: TextStyle(
                      color: !sheetCtrl.showOnlyUnread.value ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: !sheetCtrl.showOnlyUnread.value ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12.sp,
                    ),
                    onSelected: (selected) {
                      if (selected) sheetCtrl.toggleUnreadFilter(false);
                    },
                  ),
                  SizedBox(width: 8.w),
                  ChoiceChip(
                    label: Text('Unread (${homeCtrl.unreadCount})'),
                    selected: sheetCtrl.showOnlyUnread.value,
                    selectedColor: AppColors.primaryLight,
                    labelStyle: TextStyle(
                      color: sheetCtrl.showOnlyUnread.value ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: sheetCtrl.showOnlyUnread.value ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12.sp,
                    ),
                    onSelected: (selected) {
                      if (selected) sheetCtrl.toggleUnreadFilter(true);
                    },
                  ),
                  const Spacer(),
                  if (homeCtrl.unreadCount > 0)
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: Icon(Icons.done_all, size: 16.sp, color: AppColors.primary),
                      label: Text(
                        'Mark all read',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      onPressed: () => homeCtrl.markAllAsRead(),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),

          // Announcements list
          Expanded(
            child: Obx(() {
              if (homeCtrl.isAnnouncementsLoading.value) {
                return const AnnouncementListShimmer();
              }

              final all = homeCtrl.announcements;
              final list = sheetCtrl.showOnlyUnread.value ? homeCtrl.unreadAnnouncements : all;

              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.note_remove, size: 48.sp, color: Colors.grey.shade400),
                      SizedBox(height: 12.h),
                      Text(
                        sheetCtrl.showOnlyUnread.value ? 'No unread announcements' : 'No announcements found',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Important seller broadcasts will show up here',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: homeCtrl.fetchAnnouncements,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return _AnnouncementCard(
                      item: item,
                      onMarkAsRead: () => homeCtrl.markAnnouncementAsRead(item),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final AnnouncementModel item;
  final VoidCallback onMarkAsRead;

  const _AnnouncementCard({
    required this.item,
    required this.onMarkAsRead,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day} ${months[local.month - 1]} ${local.year}, $hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(item.createdAt);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: item.isRead ? Colors.white : item.priorityBgColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: item.isRead ? AppColors.border : item.priorityColor.withValues(alpha: 0.5),
          width: item.isRead ? 1 : 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: item.priorityBgColor,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: item.priorityColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  item.priorityLabel,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: item.priorityColor,
                  ),
                ),
              ),
              const Spacer(),
              if (!item.isRead)
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              if (formattedDate.isNotEmpty) ...[
                SizedBox(width: 6.w),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            item.title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            item.content,
            style: TextStyle(
              fontSize: 12.5.sp,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (!item.isRead) ...[
            SizedBox(height: 10.h),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: onMarkAsRead,
                borderRadius: BorderRadius.circular(6.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 14.sp, color: AppColors.primary),
                      SizedBox(width: 4.w),
                      Text(
                        'Mark as read',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
