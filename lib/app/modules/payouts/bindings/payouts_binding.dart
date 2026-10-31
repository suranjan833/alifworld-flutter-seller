import 'package:get/get.dart';
import '../controllers/payouts_controller.dart';

class PayoutsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PayoutsController>(() => PayoutsController());
  }
}

