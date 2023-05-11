import 'package:resolute_project_01/utils/internet_conn.dart';

Future<bool> checkInternet()  async {
    // check internet connection...
    int internetState = await ConnectivityCheck().connectionType();
    // call app check
    if ((internetState == 1) || (internetState == 2) || (internetState == 3)) {
      return true;
    }
    return false;
  }