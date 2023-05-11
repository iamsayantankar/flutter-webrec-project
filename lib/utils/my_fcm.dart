import 'dart:convert';

import 'package:http/http.dart';

class MyFCM {
  static Future<void> sendNotification(receiver, data) async {
    String token = '/token/$receiver';

    final body = {"priority": "high", "data": data, "to": token};
    Response response =
    await post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
          'key=AAAAc1C4aXw:APA91bEGxS_u2KhYHRT4L-XzmeYSMZH-EwCjqxlT_tm9hn91q7UpMQcBaZDNHcBDRsvC_8TrL_wKt7D_wRWIIo_tTaqBm2_y6tZI_jKubgZwWfWJPYiGwxPliRgvdzAJvo4IZQdC1LOR',
        },
        body: json.encode(body));

  }

}