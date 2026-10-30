import 'package:get/get.dart';
import '../../../data/models/return_model.dart';
import '../../../data/services/api_service.dart';

class ReturnsController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final isLoading = true.obs;
  final returns = <ReturnModel>[].obs;
  final selectedStatus = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReturns();
  }

  Future<void> fetchReturns() async {
    isLoading.value = true;
    try {
      final status = selectedStatus.value == 'all' ? null : selectedStatus.value;
      final list = await _api.getReturns(status: status);
      returns.value = list
          .map((item) => ReturnModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {}
    isLoading.value = false;
  }
}

