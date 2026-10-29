import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../data/theme/app_colors.dart';
import '../../../data/widgets/shimmer_widget.dart';
import '../controllers/home_controller.dart';
import '../controllers/profile_view_controller.dart';

class ProfileView extends GetView<ProfileViewController> {
  const ProfileView({super.key});

  void _showLogoutConfirmDialog(BuildContext context, HomeController homeCtrl) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.logout, color: AppColors.error, size: 20.sp),
            ),
            SizedBox(width: 10.w),
            Text(
              'Sign Out',
              style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out of your Alif Seller Portal session?',
          style: GoogleFonts.inter(fontSize: 13.5.sp, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              homeCtrl.logout();
            },
            child: Text(
              'Sign Out',
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileCtrl = Get.isRegistered<ProfileViewController>()
        ? controller
        : Get.put(ProfileViewController());
    final homeCtrl = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Iconsax.menu, color: AppColors.textPrimary, size: 24),
          onPressed: () => homeCtrl.openDrawer(),
        ),
        leadingWidth: 44.w,
        titleSpacing: 0,
        title: Text(
          'Shop Profile',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, color: AppColors.textPrimary, size: 20),
            onPressed: () {
              homeCtrl.fetchUserProfile();
              profileCtrl.loadShopProfile();
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.logout, color: AppColors.error, size: 20),
            onPressed: () => _showLogoutConfirmDialog(context, homeCtrl),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Obx(() {
        if (profileCtrl.isLoadingShop.value && profileCtrl.shopData.value == null) {
          return const ProfileScreenShimmer();
        }

        final slug = profileCtrl.slugController.text.isNotEmpty
            ? profileCtrl.slugController.text
            : (profileCtrl.shopData.value?['slug']?.toString() ?? 'shop-name');

        return RefreshIndicator(
          onRefresh: () async {
            await homeCtrl.fetchUserProfile();
            await profileCtrl.loadShopProfile();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Overview & Public Shop Page Pill
                _buildPublicShopHeader(slug),
                SizedBox(height: 16.h),

                // 2. Main Store Information Section
                _buildStoreInfoSection(profileCtrl),
                SizedBox(height: 16.h),

                // 3. Search & Social (SEO) Section
                _buildSeoSection(context, profileCtrl),
                SizedBox(height: 20.h),

                // 4. Save Button
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: profileCtrl.isSaving.value
                          ? null
                          : profileCtrl.saveShopProfile,
                      icon: profileCtrl.isSaving.value
                          ? const ShimmerBox(width: 18, height: 18, borderRadius: 4)
                          : const Icon(Iconsax.tick_circle, size: 20),
                      label: Text(
                        profileCtrl.isSaving.value
                            ? 'Saving Changes...'
                            : 'Save Changes',
                        style: GoogleFonts.inter(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // 5. Sign Out Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Iconsax.logout_1, color: AppColors.error, size: 18),
                    label: Text(
                      'Sign Out from Seller Portal',
                      style: GoogleFonts.inter(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      side: const BorderSide(color: Color(0xFFFECACA)),
                      backgroundColor: const Color(0xFFFEF2F2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    onPressed: () => _showLogoutConfirmDialog(context, homeCtrl),
                  ),
                ),
                SizedBox(height: 24.h),
                Center(
                  child: Text(
                    'Alif Seller Portal v1.0.0 (Build 1)',
                    style: GoogleFonts.inter(fontSize: 11.sp, color: AppColors.textMuted),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ==========================================
  // Header / Public Link Pill
  // ==========================================
  Widget _buildPublicShopHeader(String slug) {
    final publicUrl = 'https://dev.alifworld.com.bd/shop/$slug';
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: const Icon(Iconsax.shop, color: Color(0xFF10B981), size: 22),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shop Profile',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'How customers see your shop.',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(7.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Iconsax.link_21, size: 16.sp, color: AppColors.primary),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Public Shop Page',
                        style: GoogleFonts.inter(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '/shop/$slug',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: publicUrl));
                      Get.snackbar(
                        'Copied to Clipboard',
                        publicUrl,
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: const Color(0xFF10B981),
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.copy, size: 14.sp, color: AppColors.textPrimary),
                          SizedBox(width: 4.w),
                          Text(
                            'Copy',
                            style: GoogleFonts.inter(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Store Information Section
  // ==========================================
  Widget _buildStoreInfoSection(ProfileViewController profileCtrl) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.info_circle, size: 18.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                'Store Information',
                style: GoogleFonts.inter(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Shop Name
          _buildTextField(
            controller: profileCtrl.shopNameController,
            label: 'Shop name *',
            hint: 'Enter your shop name',
            prefixIcon: Iconsax.shop,
            isRequired: true,
          ),
          SizedBox(height: 14.h),

          // Slug
          _buildTextField(
            controller: profileCtrl.slugController,
            label: 'Slug',
            hint: 'store-slug-id',
            prefixIcon: Iconsax.link,
          ),
          SizedBox(height: 16.h),

          // Logo & Banner Pickers
          Obx(
            () => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Expanded(
                  child: _buildImageUploadCard(
                    title: 'Logo',
                    imageUrl: profileCtrl.logoUrl.value,
                    isUploading: profileCtrl.isLogoUploading.value,
                    aspectRatio: 1,
                    onChange: () => profileCtrl.pickAndUploadImage(isLogo: true),
                    onRemove: () => profileCtrl.logoUrl.value = null,
                  ),
                ),
                SizedBox(width: 12.w),
                // Banner
                Expanded(
                  child: _buildImageUploadCard(
                    title: 'Banner',
                    imageUrl: profileCtrl.bannerUrl.value,
                    isUploading: profileCtrl.isBannerUploading.value,
                    aspectRatio: 16 / 9,
                    onChange: () => profileCtrl.pickAndUploadImage(isLogo: false),
                    onRemove: () => profileCtrl.bannerUrl.value = null,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Description
          _buildTextField(
            controller: profileCtrl.descController,
            label: 'Description',
            hint:
                'Welcome to our store! We are committed to offering quality products at affordable prices...',
            maxLines: 4,
          ),
          SizedBox(height: 14.h),

          // Shop policies
          _buildTextField(
            controller: profileCtrl.policiesController,
            label: 'Shop policies',
            hint: 'Shipping Policy, Return Policy, and Terms...',
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Image Upload Card (Logo / Banner)
  // ==========================================
  Widget _buildImageUploadCard({
    required String title,
    required String? imageUrl,
    required bool isUploading,
    required double aspectRatio,
    required VoidCallback onChange,
    required VoidCallback onRemove,
  }) {
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          height: 100.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.border),
          ),
          child: isUploading
              ? const Center(
                  child: ShimmerBox(width: 40, height: 40, borderRadius: 8),
                )
              : hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(9.r),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(
                          child: Icon(Iconsax.image, color: AppColors.textMuted, size: 28.sp),
                        ),
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.image, color: AppColors.textMuted, size: 26.sp),
                          SizedBox(height: 4.h),
                          Text(
                            'No $title',
                            style: GoogleFonts.inter(fontSize: 10.5.sp, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 30.h,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                  ),
                  onPressed: isUploading ? null : onChange,
                  child: Text(
                    hasImage ? 'Change' : 'Upload',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            if (hasImage) ...[
              SizedBox(width: 6.w),
              SizedBox(
                height: 30.h,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    side: const BorderSide(color: Color(0xFFFECACA)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                  ),
                  onPressed: onRemove,
                  child: Text(
                    'Remove',
                    style: GoogleFonts.inter(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ==========================================
  // Search & Social (SEO) Section
  // ==========================================
  Widget _buildSeoSection(BuildContext context, ProfileViewController profileCtrl) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Obx(
          () => ExpansionTile(
            initiallyExpanded: profileCtrl.isSeoExpanded.value,
            onExpansionChanged: (val) => profileCtrl.isSeoExpanded.value = val,
            tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            leading: Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: const Icon(Iconsax.global_search, color: Color(0xFF3B82F6), size: 20),
            ),
            title: Text(
              'Search & social (SEO)',
              style: GoogleFonts.inter(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'How your shop page appears in search results and when shared.',
              style: GoogleFonts.inter(fontSize: 11.5.sp, color: AppColors.textSecondary),
            ),
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: AppColors.divider),
                    SizedBox(height: 8.h),

                    // Meta title & OG title
                    _buildTextField(
                      controller: profileCtrl.metaTitleController,
                      label: 'Meta title',
                      hint: 'Shop title for search engines',
                    ),
                    SizedBox(height: 12.h),

                    _buildTextField(
                      controller: profileCtrl.ogTitleController,
                      label: 'OG title',
                      hint: 'Title when shared on Facebook / WhatsApp',
                    ),
                    SizedBox(height: 12.h),

                    // Twitter title & Keywords
                    _buildTextField(
                      controller: profileCtrl.twitterTitleController,
                      label: 'Twitter title',
                      hint: 'Title when shared on Twitter / X',
                    ),
                    SizedBox(height: 12.h),

                    _buildTextField(
                      controller: profileCtrl.keywordsController,
                      label: 'Keywords',
                      hint: 'e.g. shopping, electronics, clothing (comma separated)',
                    ),
                    SizedBox(height: 12.h),

                    // Canonical URL
                    _buildTextField(
                      controller: profileCtrl.canonicalUrlController,
                      label: 'Canonical URL',
                      hint: 'https://alifworld.com.bd/shop/...',
                      prefixIcon: Iconsax.link_21,
                    ),
                    SizedBox(height: 12.h),

                    // OG image & Twitter image
                    _buildTextField(
                      controller: profileCtrl.ogImageController,
                      label: 'OG image URL',
                      hint: 'https://...',
                      prefixIcon: Iconsax.image,
                    ),
                    SizedBox(height: 12.h),

                    _buildTextField(
                      controller: profileCtrl.twitterImageController,
                      label: 'Twitter image URL',
                      hint: 'https://...',
                      prefixIcon: Iconsax.image,
                    ),
                    SizedBox(height: 12.h),

                    // Robots & OG type
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: profileCtrl.robotsController,
                            label: 'Robots',
                            hint: 'index, follow',
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _buildTextField(
                            controller: profileCtrl.ogTypeController,
                            label: 'OG type',
                            hint: 'website',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Twitter card type
                    _buildTextField(
                      controller: profileCtrl.twitterCardController,
                      label: 'Twitter card type',
                      hint: 'summary_large_image',
                    ),
                    SizedBox(height: 14.h),

                    // Meta description
                    _buildTextField(
                      controller: profileCtrl.metaDescController,
                      label: 'Meta description',
                      hint: 'Brief description for Google search snippet...',
                      maxLines: 3,
                    ),
                    SizedBox(height: 12.h),

                    // OG description
                    _buildTextField(
                      controller: profileCtrl.ogDescController,
                      label: 'OG description',
                      hint: 'Description when previewed on Facebook / LinkedIn...',
                      maxLines: 3,
                    ),
                    SizedBox(height: 12.h),

                    // Twitter description
                    _buildTextField(
                      controller: profileCtrl.twitterDescController,
                      label: 'Twitter description',
                      hint: 'Description for Twitter card preview...',
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // Reusable Text Field Builder
  // ==========================================
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? prefixIcon,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.inter(fontSize: 13.5.sp, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 12.5.sp, color: AppColors.textMuted),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18.sp, color: AppColors.textSecondary)
                : null,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: maxLines > 1 ? 12.h : 10.h),
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
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
