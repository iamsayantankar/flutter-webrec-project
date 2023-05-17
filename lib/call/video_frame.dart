import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:resolute_project_01/utils/call_signaling.dart';
import 'package:resolute_project_01/utils/services/call_details.dart';

class MyVideoFrame {

  static OverlayEntry? entry;
  static Offset offset = const Offset(20, 40);

  static myOverLy(RTCVideoRenderer localRenderer, BuildContext context, Function myStateSet) {
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy,
        left: offset.dx,
        child: GestureDetector(
          onPanUpdate: (details) {
              offset = details.delta;
              myStateSet();
              },
          child: SizedBox(
            height: 100,
            width: 100,
            child: RTCVideoView(localRenderer, mirror: true),
          ),
        ),
      ),
    );
    final overly = Overlay.of(context);
    overly.insert(entry!);
  }



  static myVideoFrame(RTCVideoRenderer localRenderer, RTCVideoRenderer remoteRenderer,
      BuildContext context, Signaling signaling, Function myStateSet, DatabaseReference databaseReference) {
    double widthThis = MediaQuery.of(context).size.width;
    double heightThis = MediaQuery.of(context).size.height;

    double heightTopThis = MediaQuery.of(context).padding.top;
    double heightBottomThis = MediaQuery.of(context).padding.bottom;

    // myOverLy();

    return Column(
      children: [
        Center(
          child: SizedBox(
            height: heightThis - heightTopThis - heightBottomThis - 100,
            width: widthThis,
            child: RTCVideoView(remoteRenderer),
            // child: RTCVideoView(_localRenderer, mirror: true),
          ),
        ),
        SizedBox(
          height: 100,
          width: double.infinity,
          child: Row(
            // alignment: WrapAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () {
                    signaling.micEnabled
                        ? signaling.micEnabled = false
                        : signaling.micEnabled = true;
                    print("textt Sayantan");
                    myStateSet();
                    print("textt Sayantan");

                    signaling.muteMic();
                  },
                  child: Column(
                    children: [
                      Icon(
                        signaling.micEnabled ? Icons.mic : Icons.mic_off,
                        color: Colors.white,
                        size: 36,
                      ),
                      const Text(
                        "Audio",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () {
                    VC.ringing = false;
                    VC.pickup = false;

                    String thisTime =
                    DateTime.now().millisecondsSinceEpoch.toString();
                    databaseReference
                        .child("videoCall/${VC.data["roomKey"]}")
                        .update({
                      "end": "End by receiver",
                      "ending": thisTime
                    }).asStream();

                    signaling.hangUp(localRenderer);

                  },
                  child: Column(
                    children: const [
                      Icon(
                        Icons.call_end,
                        color: Colors.red,
                        size: 36,
                      ),

                      // const VerticalSpacing(of: 5),
                      Text(
                        "Microphone",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () {
                    signaling.videoEnabled
                        ? signaling.videoEnabled = false
                        : signaling.videoEnabled = true;
                    signaling.muteVideo();
                    myStateSet();
                  },
                  child: Column(
                    children: [
                      Icon(
                        signaling.videoEnabled
                            ? Icons.videocam
                            : Icons.videocam_off,
                        color: Colors.white,
                        size: 36,
                      ),

                      // const VerticalSpacing(of: 5),
                      const Text(
                        "Video",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


}
