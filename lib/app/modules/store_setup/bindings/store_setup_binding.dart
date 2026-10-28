import 'package:get/get.dart';
import '../controllers/store_setup_controller.dart';
import '../steps/shop_info/shop_info_controller.dart';
import '../steps/branding/branding_controller.dart';
import '../steps/compliance/compliance_controller.dart';
import '../steps/kyc/kyc_controller.dart';
import '../steps/review/review_controller.dart';

class StoreSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StoreSetupController>(() => StoreSetupController());
    Get.lazyPut<ShopInfoController>(() => ShopInfoController());
    Get.lazyPut<BrandingController>(() => BrandingController());
    Get.lazyPut<ComplianceController>(() => ComplianceController());
    Get.lazyPut<KycController>(() => KycController());
    Get.lazyPut<ReviewController>(() => ReviewController());
  }
}

