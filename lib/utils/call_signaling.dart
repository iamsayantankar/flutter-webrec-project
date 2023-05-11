import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:resolute_project_01/utils/services/call_details.dart';

typedef void StreamStateCallback(MediaStream stream);

class Signaling {
  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      }
    ]
  };

  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  String? roomId;
  String? currentRoomText;
  StreamStateCallback? onAddRemoteStream;

  Future<void> createRoom(RTCVideoRenderer remoteRenderer) async {
    // FirebaseFirestore db = FirebaseFirestore.instance;
    // DocumentReference roomRef = db.collection('rooms').doc();
    late DatabaseReference databaseReference;
    databaseReference = FirebaseDatabase.instance.reference();


    peerConnection = await createPeerConnection(configuration);

    registerPeerConnectionListeners();

    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    // Code for collecting ICE candidates below
    // var callerCandidatesCollection = roomRef.collection('callerCandidates');

    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {

      // callerCandidatesCollection.add(candidate.toMap());
      databaseReference.child("videoCall/${VC.data["roomKey"]}/offerCandidates")
          .push()
          .update(candidate.toMap())
          .asStream();
    };
    // Finish Code for collecting ICE candidate

    // Add code for creating a room
    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);

    String thisTime = DateTime.now().millisecondsSinceEpoch.toString();

    databaseReference.child("videoCall/${VC.data["roomKey"]}").update({
      'offer': offer.toMap(),
      "roomCreate": thisTime,
      "roomId": "create",
    }).asStream();

    // await roomRef.set(roomWithOffer);
    // var roomId = roomRef.id;
    currentRoomText = 'Current room is $roomId - You are the caller!';
    // Created a Room

    peerConnection?.onTrack = (RTCTrackEvent event) {


      event.streams[0].getTracks().forEach((track) {

        remoteStream?.addTrack(track);
      });
    };


    databaseReference
        .child("videoCall/${VC.data["roomKey"]}/answer")
        .onValue
        .listen((DatabaseEvent event) async {
      var roomSnapshot = event.snapshot;
      if (roomSnapshot.exists) {

        Map data = roomSnapshot.value as Map;

        if (peerConnection?.getRemoteDescription() != null) {
          var answer = RTCSessionDescription(
            data['sdp'],
            data['type'],
          );

          await peerConnection?.setRemoteDescription(answer);
        }

      }
    });


    databaseReference
        .child("videoCall/${VC.data["roomKey"]}/offerCandidates")
        .onValue
        .listen((DatabaseEvent event) async {
      var roomSnapshot = event.snapshot;
      if (roomSnapshot.exists) {

        final data1 = jsonEncode(roomSnapshot.value);
        Map data2 = jsonDecode(data1);

        for (dynamic document in data2.values) {
          var data = document as Map<String, dynamic>;
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }


      }
    });
  }

  Future<void> joinRoom(RTCVideoRenderer remoteVideo) async {
    late DatabaseReference databaseReference;
    databaseReference = FirebaseDatabase.instance.reference();

    databaseReference
        .child("videoCall/${VC.data["roomKey"]}/offer")
        .onValue
        .listen((DatabaseEvent event) async {
      var roomSnapshot = event.snapshot;
      if (roomSnapshot.exists) {
        peerConnection = await createPeerConnection(configuration);

        registerPeerConnectionListeners();

        localStream?.getTracks().forEach((track) {

          peerConnection?.addTrack(track, localStream!);
        });


        // Code for collecting ICE candidates below
        peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {

          databaseReference.child("videoCall/${VC.data["roomKey"]}/answerCandidates")
              .push()
              .update(candidate.toMap())
              .asStream();
        };
        // Code for collecting ICE candidate above

        peerConnection?.onTrack = (RTCTrackEvent event) {

          event.streams[0].getTracks().forEach((track) {

            remoteStream?.addTrack(track);
          });
        };


        // Code for creating SDP answer below
        // var data = roomSnapshot.value as Map<String, dynamic>;
        Map data = roomSnapshot.value as Map;
        var offer = data;


        await peerConnection?.setRemoteDescription(
            RTCSessionDescription(offer['sdp'], offer['type']),
        );

        var answer = await peerConnection!.createAnswer();

        await peerConnection!.setLocalDescription(answer);

        databaseReference.child("videoCall/${VC.data["roomKey"]}").update({
          'answer': {'type': answer.type, 'sdp': answer.sdp},
        }).asStream();


        databaseReference
            .child("videoCall/${VC.data["roomKey"]}/answerCandidates")
            .onValue
            .listen((DatabaseEvent event) async {
          var roomSnapshot = event.snapshot;
          if (roomSnapshot.exists) {

            final data1 = jsonEncode(roomSnapshot.value);
            Map data2 = jsonDecode(data1);

            for (dynamic document in data2.values) {
              var data = document as Map<String, dynamic>;
              peerConnection!.addCandidate(
                RTCIceCandidate(
                  data['candidate'],
                  data['sdpMid'],
                  data['sdpMLineIndex'],
                ),
              );
            }

          }
        });



      }
    });
  }

  Future<void> openUserMedia(
    RTCVideoRenderer localVideo,
    RTCVideoRenderer remoteVideo,
  ) async {
    var stream = await navigator.mediaDevices
        .getUserMedia({'video': true, 'audio': true});

    localVideo.srcObject = stream;
    localStream = stream;

    remoteVideo.srcObject = await createLocalMediaStream('key');

  }

  Future<void> hangUp(RTCVideoRenderer localVideo) async {
    List<MediaStreamTrack> tracks = localVideo.srcObject!.getTracks();
    for (var track in tracks) {
      track.stop();
    }

    if (remoteStream != null) {
      remoteStream!.getTracks().forEach((track) => track.stop());
    }
    if (peerConnection != null) peerConnection!.close();

    if (roomId != null) {
      var db = FirebaseFirestore.instance;
      var roomRef = db.collection('rooms').doc(roomId);
      var calleeCandidates = await roomRef.collection('calleeCandidates').get();
      for (var document in calleeCandidates.docs) {
        document.reference.delete();
      }

      var callerCandidates = await roomRef.collection('callerCandidates').get();
      for (var document in callerCandidates.docs) {
        document.reference.delete();
      }

      await roomRef.delete();
    }

    localStream!.dispose();
    remoteStream?.dispose();
  }

  void registerPeerConnectionListeners() {

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {

    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {

    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {

    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {

    };

    peerConnection?.onAddStream = (MediaStream stream) {

      // onAddRemoteStream?.call(stream);
      remoteStream = stream;
    };

  }
  bool micEnabled = true;

  void muteMic() {
    if (localStream != null) {
      if(micEnabled){
        localStream!.getAudioTracks()[0].enabled = false;
      }else{
        localStream!.getAudioTracks()[0].enabled = true;
      }
      // bool enabled = localStream!.getAudioTracks()[0].enabled;
      // // localStream!.getAudioTracks()[0].enabled = !enabled;
      // // localStream!.getAudioTracks()[0].enableSpeakerphone(true);
      // // localStream!.getAudioTracks()[0].enableSpeakerphone(true);
      // localStream!.getVideoTracks()[0].switchCamera();
    }
  }

  bool videoEnabled = true;

  void muteVideo() {
    if (localStream != null) {
      if(videoEnabled){
        localStream!.getVideoTracks()[0].enabled = false;
      }else{
        localStream!.getVideoTracks()[0].enabled = true;
      }
      // bool enabled = localStream!.getAudioTracks()[0].enabled;
      // // localStream!.getAudioTracks()[0].enabled = !enabled;
      // // localStream!.getAudioTracks()[0].enableSpeakerphone(true);
      // // localStream!.getAudioTracks()[0].enableSpeakerphone(true);
      // localStream!.getVideoTracks()[0].switchCamera();
    }
  }

}
