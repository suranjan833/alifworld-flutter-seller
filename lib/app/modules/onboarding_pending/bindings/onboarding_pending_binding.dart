import 'package:get/get.dart';
import '../controllers/onboarding_pending_controller.dart';

class OnboardingPendingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingPendingController>(() => OnboardingPendingController());
  }
}

