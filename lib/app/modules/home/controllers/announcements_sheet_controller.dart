import 'package:get/get.dart';
import 'home_controller.dart';

class AnnouncementsSheetController extends GetxController {
  final HomeController homeController = Get.find<HomeController>();
  final RxBool showOnlyUnread = false.obs;

  void toggleUnreadFilter(bool unreadOnly) {
    showOnlyUnread.value = unreadOnly;
  }
}

