import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../controllers/orders_page_controller.dart';
import '../controllers/products_page_controller.dart';
import '../controllers/profile_view_controller.dart';
import '../controllers/seller_drawer_controller.dart';
import '../controllers/wallets_page_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut<OrdersPageController>(
      () => OrdersPageController(),
    );
    Get.lazyPut<ProductsPageController>(
      () => ProductsPageController(),
    );
    Get.lazyPut<WalletsPageController>(
      () => WalletsPageController(),
    );
    Get.lazyPut<ProfileViewController>(
      () => ProfileViewController(),
    );
    Get.lazyPut<SellerDrawerController>(
      () => SellerDrawerController(),
    );
  }
}
