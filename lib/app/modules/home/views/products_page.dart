import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../data/theme/app_colors.dart';
import '../../../data/widgets/shimmer_widget.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';
import '../controllers/products_page_controller.dart';

class ProductsPage extends GetView<ProductsPageController> {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productsCtrl = Get.isRegistered<ProductsPageController>()
        ? controller
        : Get.put(ProductsPageController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Iconsax.menu, color: AppColors.textPrimary, size: 24),
          onPressed: () => Get.find<HomeController>().openDrawer(),
        ),
        leadingWidth: 44.w,
        titleSpacing: 0,
        title: Text(
          'Product Catalog',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Iconsax.refresh, color: AppColors.textSecondary, size: 20),
            onPressed: productsCtrl.fetchProducts,
          ),
          IconButton(
            tooltip: 'Add new Product',
            icon: Container(
              padding: EdgeInsets.all(5.w),
              decoration: const BoxDecoration(
                color: Color(0xFFFF630F),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.add, color: Colors.white, size: 18),
            ),
            onPressed: () async {
              await Get.toNamed(Routes.ADD_PRODUCT);
              productsCtrl.fetchProducts();
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Get.toNamed(Routes.ADD_PRODUCT);
          productsCtrl.fetchProducts();
        },
        backgroundColor: const Color(0xFFFF630F),
        elevation: 3,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        label: Text(
          'Add Product',
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Tab Bar
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Obx(
              () => Row(
                children: productsCtrl.statusTabs.map((tab) {
                  final isSelected = productsCtrl.selectedFilter.value == tab['value'];
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: FilterChip(
                      label: Text(tab['label']!),
                      selected: isSelected,
                      onSelected: (_) => productsCtrl.changeFilter(tab['value']!),
                      selectedColor: const Color(0xFF10B981),
                      labelStyle: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF10B981) : AppColors.border,
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // Products List
          Expanded(
            child: Obx(() {
              if (productsCtrl.isLoading.value) {
                return const ProductListShimmer();
              }
              if (productsCtrl.products.isEmpty) {
                return _buildEmptyState();
              }
              return RefreshIndicator(
                onRefresh: productsCtrl.fetchProducts,
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 20.h),
                  itemCount: productsCtrl.products.length,
                  separatorBuilder: (_, _) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    final product = productsCtrl.products[index] as Map<String, dynamic>;
                    return _buildProductCard(product, productsCtrl);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.box, size: 48.sp, color: AppColors.textMuted),
          SizedBox(height: 12.h),
          Text(
            'No products found',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Products matching this status will appear here.',
            style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, ProductsPageController productsCtrl) {
    final productId = product['id']?.toString() ?? '';
    final name = product['name']?.toString() ?? 'Unnamed Product';
    final status = product['status']?.toString() ?? 'draft';
    final statusColor = productsCtrl.getStatusColor(status);
    final isVisible = product['isVisible'] as bool? ?? true;
    final images = product['images'] as List<dynamic>?;
    final firstImg = (images != null && images.isNotEmpty)
        ? (images[0] is Map ? images[0]['fileUrl']?.toString() : images[0]?.toString())
        : null;

    final variants = product['variants'] as List<dynamic>? ?? [];
    double lowestPriceMinor = 0;
    int totalStock = 0;
    if (variants.isNotEmpty) {
      lowestPriceMinor = (variants[0]['priceMinor'] as num?)?.toDouble() ?? 0;
      for (var v in variants) {
        totalStock += (v['stockQty'] as num?)?.toInt() ?? 0;
      }
    }
    final priceTaka = (lowestPriceMinor / 100).toStringAsFixed(2);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: firstImg != null && firstImg.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.network(
                      firstImg,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(Iconsax.box, color: AppColors.textMuted, size: 24.sp),
                    ),
                  )
                : Icon(Iconsax.box, color: AppColors.textMuted, size: 24.sp),
          ),
          SizedBox(width: 12.w),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      '৳$priceTaka',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '• ${variants.length} variant(s)',
                      style: GoogleFonts.inter(fontSize: 11.sp, color: AppColors.textMuted),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '• Stock: $totalStock',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: totalStock <= 5 ? AppColors.warning : AppColors.textMuted,
                        fontWeight: totalStock <= 5 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Visibility toggle
                    Row(
                      children: [
                        Text(
                          isVisible ? 'Visible' : 'Hidden',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: isVisible ? AppColors.success : AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Transform.scale(
                          scale: 0.7,
                          child: Switch(
                            value: isVisible,
                            activeThumbColor: AppColors.primary,
                            onChanged: (_) => productsCtrl.toggleVisibility(productId, isVisible),
                          ),
                        ),
                      ],
                    ),

                    // Submit for approval if draft
                    if (status.toLowerCase() == 'draft')
                      TextButton.icon(
                        icon: Icon(Iconsax.send_2, size: 13.sp),
                        label: Text(
                          'Submit',
                          style: GoogleFonts.inter(fontSize: 11.5.sp, fontWeight: FontWeight.w600),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          foregroundColor: AppColors.primary,
                        ),
                        onPressed: () => productsCtrl.submitProduct(productId),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
