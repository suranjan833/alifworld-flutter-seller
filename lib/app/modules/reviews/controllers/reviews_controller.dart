import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/review_model.dart';
import '../../../data/services/api_service.dart';

class ReviewsController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final isLoading = true.obs;
  final reviews = <ReviewModel>[].obs;
  final selectedFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    isLoading.value = true;
    try {
      final statusParam = selectedFilter.value == 'all' ? null : selectedFilter.value;
      final list = await _api.getReviews(status: statusParam);
      reviews.value = list
          .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> replyToReview(String reviewId, String reply) async {
    final ok = await _api.replyReview(reviewId, reply);
    if (ok) {
      Get.snackbar(
        'Reply Sent',
        'Your response was posted.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      fetchReviews();
    }
  }
}

