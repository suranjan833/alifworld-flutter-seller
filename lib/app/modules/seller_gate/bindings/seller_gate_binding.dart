import 'package:get/get.dart';
import '../controllers/seller_gate_controller.dart';

class SellerGateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerGateController>(() => SellerGateController());
  }
}

