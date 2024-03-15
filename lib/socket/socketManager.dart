import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:convert';

class SocketManager {
  late IO.Socket socket;
  Function(dynamic) onSdpOfferMessage = (data) {};
  Function(dynamic) onSdpAnswerMessage = (data) {};
  Function(dynamic) onIceCandidateMessage = (data) {};

  // init class methods
  SocketManager(String serverUrl) {
    socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.on('connect', (_) {
      print('Connected to server');
    });

    socket.on('disconnect', (_) {
      print('Disconnected from server');
    });

    socket.on('onSdpOfferMessage', (message) {
      print("onSdpOfferMessage" + message.toString());
      onSdpOfferMessage(message);
    });

    socket.on('onSdpAnswerMessage', (message) {
      onSdpAnswerMessage(message);
    });

    socket.on('onIceCandidateMessage', (message) {
      onIceCandidateMessage(message);
    });
  }

  void connectToServer() {
    socket.connect();
  }

  sendLaserControl(device_serial_code, laserState) {
    print("hello laser ");
    socket.emit('LaserControl',
        {'device_serial_code': device_serial_code, "laserState": laserState});
  }

  sendCameraControl(device_serial_code, cameraState) {
    print("hello camera ");

    socket.emit('CameraControl',
        {'device_serial_code': device_serial_code, "cameraState": cameraState});
  }

  void connectToServerTypeDevice(device_serial_code) {
    socket.emit('DeviceConnection', {'device_serial_code': device_serial_code});
  }

  void connectToServerTypeUser(user_id) {
    socket.emit('UserConnection', {'user_id': user_id});
  }

  void setSdpOfferMessageCallback(Function(dynamic) callback) {
    onSdpOfferMessage = callback;
  }

  void setSdpAnswerMessageCallback(Function(dynamic) callback) {
    onSdpAnswerMessage = callback;
  }

  void setIceCandidateMessageCallback(Function(dynamic) callback) {
    onIceCandidateMessage = callback;
  }

  void sendUserDisconnection(user_id, device_serial_code) {
    socket.emit('UserDisconnection',
        {'user_id': user_id, 'device_serial_code': device_serial_code});
  }

  void sendLaser(user_id, device_serial_code, laser_state) {
    socket.emit('laserControl', {
      "user_id": user_id,
      "device_serial_code": device_serial_code,
      "laser": laser_state
    });
  }

  void sendCamera(user_id, device_serial_code, camera_state) {
    socket.connect();

    socket.emit('cameraControl', {
      "user_id": user_id,
      "device_serial_code": device_serial_code,
      "camera": camera_state
    });
  }

  void sendCommunicateUp(device_serial_code) {
    socket.emit('CommunicateUp', {"device_serial_code": device_serial_code});
  }

  void sendAnswer(
      Map<String, dynamic> sdp, String user_id, String device_serial_code) {
    socket.emit('AnswerSdpMessage', {
      "sdp": sdp,
      "type": "answer",
      "user_id": user_id,
      "device_serial_code": device_serial_code
    });
  }

  // device is offerer
  void sendOffer(Map<String, dynamic> sdp, String device_serial_code) {
    print("sdp");
    socket.emit('OfferSdpMessage', {
      "sdp": sdp,
      "type": "offer",
      "device_serial_code": device_serial_code,
    });
  }

  void sendIceCandidate(RTCIceCandidate candidate) {
    Map<String, dynamic> iceCandidateMap = {
      'candidate': candidate.candidate,
      'sdpMid': candidate.sdpMid,
      'sdpMLineIndex': candidate.sdpMLineIndex,
    };
    socket.emit('IceCandidateMessage', {
      'message': iceCandidateMap,
    });
  }

  void disconnectFromServer() {
    socket.disconnect();
  }

  void dispose() {
    socket.dispose();
  }
}
