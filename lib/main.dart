import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resolute_project_01/call/incoming_call.dart';
import 'package:resolute_project_01/splash.dart';
import 'package:resolute_project_01/utils/my_fcm.dart';
import 'package:resolute_project_01/utils/services/call_details.dart';
import 'package:resolute_project_01/utils/services/global.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  createMessage(message.data);
}

Future<void> createMessage(Map<String, dynamic> data) async {
  if (data["type"] == "vc") {

    final body = data;
    body["type"] = "vcr";
    MyFCM.sendNotification(data["fcmFrom"], body);

    VC.data = data;
    VC.ringing = true;
    VC.pickup = false;

    Navigator.push(
      GlobalVariable.navState.currentContext!,
      MaterialPageRoute(
          builder: (context) => const IncomingCall()),
    );
  }
  else if (data["type"] == "vcr") {
    VC.data = data;
    VC.ringing = true;
    VC.pickup = false;
  }

}


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Todo: Firebase Start
  await Firebase.initializeApp();
  // Todo: Firebase End

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarColor: const Color(0xFF26063F),
      systemNavigationBarDividerColor: const Color(0xFF1A2A6C),
      systemNavigationBarContrastEnforced: true,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
      statusBarColor: const Color(0xFF26063F),
      systemStatusBarContrastEnforced: true,
    ),
  );


  // Todo: FCM Start
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // foreground work
  FirebaseMessaging.onMessage.listen((message) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    // if (!isAllowed) isAllowed = await NotificationController.displayNotificationRationale();
    if (!isAllowed) return;
    createMessage(message.data);
  });


  runApp(MaterialApp(
    navigatorKey: GlobalVariable.navState,
    debugShowCheckedModeBanner: false,
    home: const MySplash(),

  ));
}
