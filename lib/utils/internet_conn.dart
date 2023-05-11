import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityCheck {
  Future<int> connectionType() async {
    bool result = await InternetConnectionChecker().hasConnection;
    if(result == true) {
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile) {
        return 1;
      } else if (connectivityResult == ConnectivityResult.wifi) {
        return 2;
      }else if (connectivityResult == ConnectivityResult.vpn) {
        return 3;
      }else if (connectivityResult == ConnectivityResult.ethernet) {
        return 4;
      }else if (connectivityResult == ConnectivityResult.bluetooth) {
        return 5;
      }else if (connectivityResult == ConnectivityResult.none) {
        return 6;
      }
    } else {
      return 0;
    }
    return -1;
  }
}