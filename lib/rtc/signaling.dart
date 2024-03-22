import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lpd/socket/socketManager.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'dart:convert';

typedef void StreamStateCallback(MediaStream stream);

class Signaling {
  final socket = new SocketManager('http://192.168.1.44:3000');
  // new SocketManager('https://plankton-app-xmeox.ondigitalocean.app');

  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  String? roomId;
  String? currentRoomText;
  StreamStateCallback? onAddRemoteStream;
  RTCDataChannel? dataChannel;
  bool _isPeerConnectionInitialized = false;
  bool _isSocketConnected = false;
  bool _isSdpOfferReceived = false;

  // Map<String, dynamic> configuration = {
  //   'iceServers': [
  //     {
  //       'urls': [
  //         'stun:stun1.l.google.com:19302',
  //         'stun:stun2.l.google.com:19302'
  //       ]
  //     }
  //   ]
  // };

  Map<String, dynamic> configuration = {
    'iceServers': [
      {'urls': 'stun:stun1.l.google.com:19302'},
      {
        'urls': 'turn:146.190.100.131:4443?transport=tcp',
        'username': 'lpdTurnServerUser',
        'credential': 'SAlmio5ols93AS98jdm3G3fckvBJSmi24dkL',
      },
    ]
  };

  Future<void> joinServer() async {
    socket.connectToServer();
  }

  //device is offerer
  Future<void> createCommunicationRoom() async {
    var deviceSerialCode = 'qwerasdfzxcv';

    // init signaling server connection
    socket.connectToServer();
    socket.connectToServerTypeDevice(deviceSerialCode);

    // init peer connection and add track
    peerConnection = await createPeerConnection(configuration);

    registerPeerConnectionListeners();
    var stream = await navigator.mediaDevices
        .getUserMedia({'video': true, 'audio': false});
    localStream = stream;
    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    // create offerSDP
    RTCSessionDescription offer = await peerConnection!.createOffer();
    peerConnection!.setLocalDescription(offer);
    // RTCSessionDescription parsing to String and sent to signaling server
    Map<String, dynamic> sdpData = {
      'sdp': offer.sdp.toString(),
      'type': offer.type.toString()
    };
    // String sdpMapAsString = sdpData.toString();

    // send to signaling server
    socket.sendOffer(sdpData, deviceSerialCode);

    peerConnection?.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');

      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream $track');
        remoteStream?.addTrack(track);
      });
    };

    socket.setSdpAnswerMessageCallback((message) async {
      print(message);
      print(message['sdp']);
      print(message['sdp']['sdp']);

      RTCSessionDescription description =
          new RTCSessionDescription(message['sdp']['sdp'], 'answer');
      await peerConnection!.setRemoteDescription(description);
    });

    socket.setIceCandidateMessageCallback((IceMessage) async {
      Map<String, dynamic> iceMap = IceMessage['message'];

      RTCIceCandidate rtcIceCandidate = RTCIceCandidate(
          iceMap['candidate'], iceMap['sdpMid'], iceMap['sdpMLineIndex']);

      await peerConnection!.addCandidate(rtcIceCandidate);
    });
  }

  Future<void> joinCommunicationRoom(device_serial_code, userid) async {
    try {
      // Initialize peer connection if not already initialized
      if (!_isPeerConnectionInitialized) {
        peerConnection = await createPeerConnection(configuration);
        registerPeerConnectionListeners();
        _isPeerConnectionInitialized = true;
      }

      // Connect to the server if not already connected
      if (!_isSocketConnected) {
        socket.connectToServer();
        socket.connectToServerTypeUser(userid);
        _isSocketConnected = true;
      }

      // Set up callback for receiving SDP offer if not already set
      if (!_isSdpOfferReceived) {
        socket.setSdpOfferMessageCallback((message) async {
          _isSdpOfferReceived = true;

          var sdpString = message['sdp']['sdp'];
          if (sdpString == null) {
            return;
          }
          RTCSessionDescription description =
              await RTCSessionDescription(sdpString, 'offer');
          try {
            await peerConnection!.setRemoteDescription(description);

            RTCSessionDescription answer = await peerConnection!.createAnswer();
            peerConnection!.setLocalDescription(answer);

            Map<String, dynamic> sdpData = {
              'sdp': answer.sdp.toString(),
              'type': answer.type.toString()
            };

            socket.sendAnswer(sdpData, userid, device_serial_code);

            socket.setIceCandidateMessageCallback((IceMessage) async {
              Map<String, dynamic> iceMap = IceMessage['message'];
              RTCIceCandidate rtcIceCandidate = RTCIceCandidate(
                  iceMap['candidate'],
                  iceMap['sdpMid'],
                  iceMap['sdpMLineIndex']);
              await peerConnection!.addCandidate(rtcIceCandidate);
            });
          } catch (e) {
            return;
          }
        });
      }
    } catch (e) {
      print("Failed to join communication room: $e");
      await retryJoinCommunicationRoom(device_serial_code, userid);
    }
  }

  Future<void> retryJoinCommunicationRoom(device_serial_code, userid) async {
    await Future.delayed(
        Duration(seconds: 5)); // Wait for 5 seconds before retrying
    await joinCommunicationRoom(
        device_serial_code, userid); // Retry joining the room
  }

  sendCameraControl(user_id, device_serial_code, camera_state) {
    socket.sendCamera(user_id, device_serial_code, camera_state);
  }

  sendLaserControl(user_id, device_serial_code, laser_state) {
    socket.sendLaser(user_id, device_serial_code, laser_state);
  }

  sendCommunicateUp(device_serial_code) {
    socket.sendCommunicateUp(device_serial_code);
  }

  hangUp(uid, device_serial_code) {
    peerConnection!.close();
    peerConnection = null;
    socket!.sendUserDisconnection(uid, device_serial_code);
    socket!.disconnectFromServer();
  }

  dynamic sendAnswer(sdpOffer, user_id, device_serial_code) {
    socket.sendAnswer(sdpOffer, user_id, device_serial_code);
    return;
  }

  Future<void> openUserMedia(
    RTCVideoRenderer localVideo,
    RTCVideoRenderer remoteVideo,
  ) async {
    var stream = await navigator.mediaDevices
        .getUserMedia({'video': true, 'audio': false});
    localVideo.srcObject = stream;
    localStream = stream;
    print(stream.toString());
    print(stream.toString());
    remoteVideo.srcObject = await createLocalMediaStream('key');
  }

  void registerPeerConnectionListeners() {
    peerConnection?.onDataChannel = (channel) {
      print("found data channel :" + channel.label.toString());
      channel.onMessage = (event) {
        if (!event.isBinary) {
          print("is binary");
        } else {
          event.text;
          print("text is " + event.text);
        }
      };
      channel.onDataChannelState = (state) {
        if (state == RTCDataChannelState.RTCDataChannelConnecting) {
          print("data channel RTCDataChannelConnecting");
        } else if (state == RTCDataChannelState.RTCDataChannelOpen) {
          print("data channel RTCDataChannelOpen");
        } else if (state == RTCDataChannelState.RTCDataChannelClosing) {
          print("data channel RTCDataChannelClosing");
        } else if (state == RTCDataChannelState.RTCDataChannelClosed) {
          print("data channel RTCDataChannelClosed");
        }
      };
    };

    peerConnection?.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnecting) {
        print("RTCPeerConnectionStateConnecting");
      } else if (state ==
          RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        print("RTCPeerConnectionStateConnected");
      } else if (state ==
          RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        print("RTCPeerConnectionStateDisconnected");
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        print("RTCPeerConnectionStateClosed");
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        print("RTCPeerConnectionStateFailed");
      }
    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE gathering state changed: $state');
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state change: $state');
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {
      print('Signaling state change: $state');
    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE connection state change: $state');
    };

    peerConnection?.onAddStream = (MediaStream stream) {
      print("Add remote stream");
      onAddRemoteStream?.call(stream);
      remoteStream = stream;
    };

    peerConnection?.onIceCandidate = (RTCIceCandidate e) {
      if (e.candidate != null) {
        socket.sendIceCandidate(e); // Use the appropriate device identifier
      }
    };
  }

  Map<String, dynamic> stringToMap(String input) {
    print("input inside string to Map " + input);
    Map<String, dynamic> result = {};
    print("z");

    RegExp exp = RegExp(r'(\w+): ([^,}]+)');
    print("x");

    Iterable<Match> matches = exp.allMatches(input);
    print("c");

    for (Match match in matches) {
      String key = match.group(1)!; // Adding ! to assert that key is not null
      String value =
          match.group(2)?.trim() ?? ''; // Using ?.trim() to handle null values
      // If the value is wrapped in single quotes, remove them
      if (value.startsWith("'") && value.endsWith("'")) {
        value = value.substring(1, value.length - 1);
      }
      result[key] = value;
    }

    return result;
  }
}
