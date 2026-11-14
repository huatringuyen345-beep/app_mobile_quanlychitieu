import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class DichVuMang {
  static Future<bool> kiemTraCoMang() async {
    try {
      final results = await Connectivity().checkConnectivity();
      if (results.contains(ConnectivityResult.none) || results.isEmpty) {
        return false;
      }
      try {
        final lookup = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 3));
        return lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
      } catch (_) {
        // Fallback: nếu DNS google bị chặn nhưng vẫn có wifi/mobile data thì trả về true
        return !results.contains(ConnectivityResult.none);
      }
    } catch (_) {
      return false;
    }
  }
}
