import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkService extends GetxService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> hasConnection() async {
    try {
      final List<ConnectivityResult> result = await _connectivity
          .checkConnectivity();

      if (result.contains(ConnectivityResult.none) || result.isEmpty) {
        return false;
      }

      return true;
    } catch (e) {
      return true;
    }
  }
}
