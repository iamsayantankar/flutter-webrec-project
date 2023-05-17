import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:resolute_project_01/call/constants.dart';
import 'package:resolute_project_01/call/video_frame.dart';
import 'package:resolute_project_01/utils/call_signaling.dart';
import 'package:resolute_project_01/utils/my_fcm.dart';
import 'package:resolute_project_01/utils/services/call_details.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';
import 'package:uuid/uuid.dart';

class OutgoingCall extends StatefulWidget {
  const OutgoingCall({Key? key}) : super(key: key);

  @override
  State<OutgoingCall> createState() => _OutgoingCallState();
}

class _OutgoingCallState extends State<OutgoingCall>
    with TickerProviderStateMixin {
  Signaling signaling = Signaling();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String thisStatus = "";
  String callUid = const Uuid().v4().toString();

  late AnimationController controller;

  /// speed of wave. it's milliseconds
  late int speed = 1000;

  /// size of circle image
  late double imageSize = 150;

  /// color of border
  late Color boarderColor = Colors.red;

  /// color of wave color
  late Color waveColor = Colors.green;

  /// width of border. most : boarderWidth >= 0
  late double boarderWidth = 1;

  /// radius should nigger or equal [imageSize]
  late double radius = 215;

  @override
  void initState() {
    databaseReference = FirebaseDatabase.instance.reference();
    VC.callUid = callUid;



    createRoom();
    callEndController();
    callReceiveController();
    statusCheck();

    countDown();


    // TODO: implement initState
    super.initState();

    controller = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      duration: Duration(milliseconds: speed),
    )..repeat();
    controller.repeat();
  }

  bool isFinished = false;

  @override
  Widget build(BuildContext context) {

    if (!startCall) {
      return Scaffold(
        backgroundColor: callBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  VC.data["nameTo"],
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(color: Colors.white),
                ),

                Text(
                  VC.data["numberTo"],
                  maxLines: 2,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  //  VC.ringing
                  // ? "Ringing…"
                  //  :"Connecting...",
                  thisStatus,
                  style: const TextStyle(color: Colors.white60),
                ),
                // const VerticalSpacing(),
                const Spacer(),

                AnimatedBuilder(
                  animation: CurvedAnimation(
                      parent: controller, curve: Curves.fastOutSlowIn),
                  builder: (context, child) {
                    return Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Container(
                            width: radius * controller.value,
                            height: radius * controller.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  waveColor.withOpacity(1 - controller.value),
                            ),
                          ),
                          Container(
                            height: imageSize,
                            width: imageSize,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: boarderColor, width: boarderWidth),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(imageSize)),
                            ),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(imageSize)),
                              child: Image.network(
                                VC.data["imgTo"],
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(
                  height: 120,
                ),

                const Spacer(),

                SwipeableButtonView(
                  buttonText: 'HANG UP',
                  buttonWidget: const Icon(
                    Icons.call_end,
                    color: Colors.grey,
                  ),
                  activeColor: const Color(0xFFFF0000),
                  isFinished: isFinished,
                  onWaitingProcess: () {

                    VC.ringing = false;
                    VC.pickup = false;
                    databaseReference
                        .child("videoCall/${VC.data["roomKey"]}")
                        .update({
                      "end": "End by sender",
                    }).asStream();
                    signaling.hangUp(_localRenderer);

                    setState(() {
                      isFinished = true;
                    });
                  },
                  onFinish: () async {
                    setState(() {
                      isFinished = false;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: callBackgroundColor,
      body: SafeArea(
        child: MyVideoFrame.myVideoFrame(_localRenderer, _remoteRenderer, context,signaling,myStateSet,databaseReference),
      ),
    );
  }

  Future<void> createRoom() async {
    databaseReference = FirebaseDatabase.instance.reference();

    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });
    await signaling.openUserMedia(_localRenderer, _remoteRenderer);


    await signaling.createRoom(_remoteRenderer);

    setState(() {});

    MyFCM.sendNotification(VC.data["fcmTo"], VC.data);
  }

  late DatabaseReference databaseReference;
  bool startCall = false;


  void statusCheck() {
    databaseReference
        .child("videoCall/${VC.data["roomKey"]}/status")
        .onValue
        .listen((DatabaseEvent event) {
      setState(() {
        if (event.snapshot.value.toString() == "creating") {
          thisStatus = "connecting...";
        } else if (event.snapshot.value.toString() == "ringing") {
          thisStatus = "ringing...";
        }
      });
    });
  }

  Future<void> countDown() async {
    await Future.delayed(const Duration(seconds: 70));
    if(VC.ringing && (!VC.pickup) && VC.callUid == callUid){
      VC.ringing = false;
      VC.pickup = false;
      signaling.hangUp(_localRenderer);
      String thisTime = DateTime.now().millisecondsSinceEpoch.toString();
      databaseReference.child("videoCall/${VC.data["roomKey"]}").update({
        "end": "miss call",
        "ending":thisTime
      }).asStream();
    }


  }


  void callReceiveController() {
    databaseReference
        .child("videoCall/${VC.data["roomKey"]}/receive")
        .onValue
        .listen((DatabaseEvent event) {
      if (event.snapshot.value.toString() == "0") {
        startCall = false;
      } else {
        VC.ringing = true;
        VC.pickup = true;
        startCall = true;

        KeepScreenOn.turnOn();

        MyVideoFrame.myOverLy(_localRenderer,context,myStateSet);
      }
      setState(() {});
    });
  }

  void callEndController() {

    databaseReference
        .child("videoCall/${VC.data["roomKey"]}/end")
        .onValue
        .listen((DatabaseEvent event) {
      if (event.snapshot.value.toString() != "0") {
          VC.ringing = false;
          VC.pickup = false;
          VC.data = {};
          VC.callUid = "";
          signaling.hangUp(_localRenderer);
          KeepScreenOn.turnOn(false);

          _localRenderer.dispose();
          _remoteRenderer.dispose();
          controller.dispose();

          Navigator.pop(context);

      }
    });
  }


  void myStateSet(){
    setState(() {

    });
  }
}
