import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../data/theme/app_colors.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';
import '../controllers/seller_drawer_controller.dart';
import 'announcements_sheet.dart';

class DrawerMenuItem {
  final String id;
  final String title;
  final IconData icon;
  final int? navIndex;
  final String? badge;

  const DrawerMenuItem({
    required this.id,
    required this.title,
    required this.icon,
    this.navIndex,
    this.badge,
  });
}

class SellerDrawer extends GetView<SellerDrawerController> {
  const SellerDrawer({super.key});

  static const List<DrawerMenuItem> _menuItems = [
    DrawerMenuItem(
      id: 'dashboard',
      title: 'Dashboard',
      icon: Iconsax.element_4,
      navIndex: 0,
    ),
    DrawerMenuItem(
      id: 'products',
      title: 'Products',
      icon: Iconsax.box,
      navIndex: 2,
    ),
    DrawerMenuItem(
      id: 'orders',
      title: 'Orders',
      icon: Iconsax.clipboard_text,
      navIndex: 1,
    ),
    DrawerMenuItem(id: 'inventory', title: 'Inventory', icon: Iconsax.tag),
    DrawerMenuItem(
      id: 'shop_profile',
      title: 'Shop profile',
      icon: Iconsax.shop,
      navIndex: 4,
    ),
    DrawerMenuItem(
      id: 'my_wallets',
      title: 'My wallets',
      icon: Iconsax.wallet_3,
      navIndex: 3,
    ),
  ];

  bool _isItemActive(DrawerMenuItem item, HomeController homeCtrl) {
    final nav = homeCtrl.currentNavIndex.value;
    if (item.id == 'dashboard' && nav == 0) return true;
    if (item.id == 'orders' && nav == 1) return true;
    if (item.id == 'products' && nav == 2) return true;
    if ((item.id == 'my_wallets' || item.id == 'payouts') && nav == 3) {
      return true;
    }
    if (item.id == 'shop_profile' && nav == 4) return true;
    return false;
  }

  void _onItemTapped(
      BuildContext context,
      DrawerMenuItem item,
      SellerDrawerController drawerCtrl,
      HomeController homeCtrl) {
    if (item.id == 'products') {
      drawerCtrl.toggleProductsExpanded();
      return;
    }

    Navigator.of(context).pop(); // Close drawer first

    if (item.navIndex != null) {
      homeCtrl.changeNavIndex(item.navIndex!);
      return;
    }

    // Dedicated GetX Modules & Routes
    switch (item.id) {
      case 'announcements':
        AnnouncementsSheet.show(context);
        break;
      case 'leaderboard':
        Get.toNamed(Routes.LEADERBOARD);
        break;
      case 'returns':
        Get.toNamed(Routes.RETURNS);
        break;
      case 'inventory':
        Get.toNamed(Routes.INVENTORY);
        break;
      case 'coupons':
        Get.toNamed(Routes.COUPONS);
        break;
      case 'reviews':
        Get.toNamed(Routes.REVIEWS);
        break;
      case 'payouts':
        Get.toNamed(Routes.PAYOUTS);
        break;
      case 'analytics':
        Get.back();
        homeCtrl.changeNavIndex(0);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final drawerCtrl = Get.isRegistered<SellerDrawerController>()
        ? controller
        : Get.put(SellerDrawerController());
    final homeCtrl = Get.find<HomeController>();

    return Drawer(
      backgroundColor: Colors.white,
      elevation: 16,
      child: SafeArea(
        child: Column(
          children: [
            // 1. Top Brand & Seller Panel Header
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 24.h,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ALIF',
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        Container(
                          width: 6.w,
                          height: 6.w,
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF630F),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'Seller panel',
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Search Menu Box
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 8.h),
              child: Obx(
                () => TextField(
                  controller: drawerCtrl.searchController,
                  style: GoogleFonts.inter(fontSize: 13.sp),
                  decoration: InputDecoration(
                    hintText: 'Search menu...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 12.5.sp,
                      color: AppColors.textMuted,
                    ),
                    prefixIcon: const Icon(
                      Iconsax.search_normal,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    suffixIcon: drawerCtrl.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Iconsax.close_circle, size: 16),
                            onPressed: () {
                              drawerCtrl.searchController.clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: const BorderSide(
                        color: Color(0xFFFF630F),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 3. Menu Items List
            Expanded(
              child: Obx(() {
                final query = drawerCtrl.searchQuery.value.toLowerCase().trim();
                final filteredItems = query.isEmpty
                    ? _menuItems
                    : _menuItems.where((item) {
                        if (item.title.toLowerCase().contains(query)) return true;
                        if (item.id == 'products' &&
                            ('all products'.contains(query) ||
                                'all product page'.contains(query) ||
                                'add new product'.contains(query) ||
                                'add product'.contains(query))) {
                          return true;
                        }
                        return false;
                      }).toList();

                final isProductsExpanded =
                    query.isNotEmpty &&
                        (query.contains('prod') ||
                            query.contains('add') ||
                            query.contains('all'))
                    ? true
                    : drawerCtrl.isProductsExpanded.value;

                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  itemCount: filteredItems.length,
                  separatorBuilder: (_, _) => SizedBox(height: 3.h),
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];

                    if (item.id == 'products') {
                      return _buildProductsAccordion(
                        context,
                        item,
                        isProductsExpanded,
                        drawerCtrl,
                        homeCtrl,
                      );
                    }

                    final isActive = _isItemActive(item, homeCtrl);

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _onItemTapped(context, item, drawerCtrl, homeCtrl),
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 10.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFFF630F)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                size: 19.sp,
                                color: isActive
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5.sp,
                                    fontWeight: isActive
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isActive
                                        ? Colors.white
                                        : const Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            // 4. Bottom Footer (User & Logout)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Obx(() {
                    final name = homeCtrl.sellerName;
                    final initial = name.isNotEmpty
                        ? name[0].toUpperCase()
                        : 'S';
                    return Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Obx(() {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            homeCtrl.sellerName,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: GoogleFonts.inter(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            homeCtrl.sellerStatus,
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  IconButton(
                    icon: const Icon(
                      Iconsax.logout,
                      color: AppColors.error,
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      homeCtrl.logout();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsAccordion(
    BuildContext context,
    DrawerMenuItem item,
    bool isExpanded,
    SellerDrawerController drawerCtrl,
    HomeController homeCtrl,
  ) {
    final isProductsNavActive = homeCtrl.currentNavIndex.value == 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Parent Accordion Tile
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: drawerCtrl.toggleProductsExpanded,
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.5.h),
              decoration: BoxDecoration(
                color: (!isExpanded && isProductsNavActive)
                    ? const Color(0xFFFF630F)
                    : (isExpanded && isProductsNavActive)
                    ? const Color(0xFFFFF4EE)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 19.sp,
                    color: (!isExpanded && isProductsNavActive)
                        ? Colors.white
                        : (isExpanded && isProductsNavActive)
                        ? const Color(0xFFFF630F)
                        : const Color(0xFF64748B),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Text(
                      item.title,
                      style: GoogleFonts.inter(
                        fontSize: 13.5.sp,
                        fontWeight: isProductsNavActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: (!isExpanded && isProductsNavActive)
                            ? Colors.white
                            : (isExpanded && isProductsNavActive)
                            ? const Color(0xFFFF630F)
                            : const Color(0xFF334155),
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1,
                    size: 18.sp,
                    color: (!isExpanded && isProductsNavActive)
                        ? Colors.white
                        : (isExpanded && isProductsNavActive)
                        ? const Color(0xFFFF630F)
                        : const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Expandable Sub-items
        if (isExpanded) ...[
          SizedBox(height: 4.h),
          _buildSubMenuItem(
            context: context,
            title: 'All Products',
            subtitle: 'Catalog & listings',
            icon: Iconsax.box_1,
            isActive: isProductsNavActive,
            onTap: () {
              Navigator.of(context).pop();
              homeCtrl.changeNavIndex(2);
            },
          ),
          SizedBox(height: 4.h),
          _buildSubMenuItem(
            context: context,
            title: 'Add new Product',
            subtitle: 'Create draft or submit',
            icon: Iconsax.add_circle,
            isActive: false,
            badge: 'New',
            onTap: () {
              Navigator.of(context).pop();
              Get.toNamed(Routes.ADD_PRODUCT);
            },
          ),
          SizedBox(height: 2.h),
        ],
      ],
    );
  }

  Widget _buildSubMenuItem({
    required BuildContext context,
    required String title,
    String? subtitle,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Container(
      margin: EdgeInsets.only(left: 20.w, right: 4.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFFF630F)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isActive
                    ? const Color(0xFFFF630F)
                    : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 16.sp,
                  color: isActive ? Colors.white : const Color(0xFF64748B),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 12.5.sp,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isActive
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 1.h),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: isActive
                                ? Colors.white.withValues(alpha: 0.85)
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.25)
                          : const Color(0xFFFF630F).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.inter(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFFFF630F),
                      ),
                    ),
                  )
                else if (isActive)
                  Icon(Iconsax.tick_circle, size: 15.sp, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
