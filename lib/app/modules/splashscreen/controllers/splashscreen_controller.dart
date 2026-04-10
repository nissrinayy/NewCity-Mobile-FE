import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

const bool USE_MOCK = true;

class SplashscreenController extends GetxController {
  final count = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    _autoNavigate();
  }
  
  Future<void> _autoNavigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (USE_MOCK) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userRole', 'pemerintah');
      Get.offAllNamed("/dashboard");
    } else {
      Get.offAllNamed("/welcomepage");
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
