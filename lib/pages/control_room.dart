import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:lpd/component/control_room_desktop.dart';
import 'package:lpd/component/control_room_mobile.dart';
import 'package:lpd/component/end_drawer.dart';
import 'package:lpd/component/error_alert.dart';
import 'package:lpd/component/responsive_control_room.dart';
import 'package:lpd/main.dart';
import 'package:lpd/pages/device_select.dart';
import 'package:lpd/responsive/text_adapter.dart';
import 'package:lpd/rtc/signaling.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../component/navbar_desktop.dart';
import '../component/navbar_mobile.dart';
import '../component/responsive_navbar_layout.dart';
import 'package:http/http.dart' as http;

//  will have signaling parameter for more control / exiting and hardware controling
class ControlRoomPage extends StatefulWidget {
  late String url;
  late String deviceSerialCode;
  late String userId;
  late String accessToken;
  late Map<String, String> hardwareState;

  ControlRoomPage({
    required this.url,
    required this.deviceSerialCode,
    required this.userId,
    required this.accessToken,
  });

  @override
  State<ControlRoomPage> createState() => _ControlRoomPage();
}

class _ControlRoomPage extends State<ControlRoomPage> {
  final toggleState = ToggleState();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  Signaling signaling = new Signaling();

  getDeviceData(accessToken) async {
    var url = widget.url + '/device/state/hardware';

    print("url is " + url);

    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({"device_serial_code": widget.deviceSerialCode}),
    );

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);

      var state = body['hardwareState'];

      if (state['cameraState'] == "false") {
        toggleState.updateCameraToggle(false);
      } else {
        toggleState.updateCameraToggle(true);
      }

      if (state['laserState'] == "false") {
        toggleState.updateLaserToggle(false);
      } else {
        toggleState.updateLaserToggle(true);
      }

      print("the toggle camera state is " +
          toggleState.isCameraToggle.toString());
      print(
          "the toggle laser state is " + toggleState.isLaserToggle.toString());

      setState(() {});
    } else {
      showAlertDialog(context, " error getting device state");
    }
  }

  @override
  void initState() {
    remoteRenderer.initialize();

    signaling.joinServer();
    signaling.onAddRemoteStream = ((stream) {
      print("working on stream");
      remoteRenderer.srcObject = stream;

      print(stream.getVideoTracks());
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    print("disposting control room page...");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = StoreProvider.of<AppState>(context);
    getDeviceData(widget.accessToken);

    final accessToken = store.state.accessToken;
    print("accessToken" + accessToken!);

    signaling.joinCommunicationRoom(widget.deviceSerialCode, widget.userId);
    signaling.sendCommunicateUp(widget.deviceSerialCode);
    // Perform some initialization here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ResponsiveNavBarLayout(
          mobileNavBar: NavBarMobile(),
          desktopNavBar: NavBarDesktop(url: widget.url),
        ),
        backgroundColor: const Color.fromARGB(217, 218, 218, 218),
        endDrawer: EndDrawer(),
        body: SingleChildScrollView(
            child: ResponsiveControlRoomLayout(
                desktopControRoomLayout: ControlRoomDesktopPage(
                  deviceSerialCode: widget.deviceSerialCode,
                  url: widget.url,
                  signaling: signaling,
                  remoteRenderer: remoteRenderer,
                  toggleState: toggleState,
                  userId: widget.userId,
                ),
                mobileControRoomLayout: ControlRoomMobilePage(
                  deviceSerialCode: widget.deviceSerialCode,
                  url: widget.url,
                  signaling: signaling,
                  remoteRenderer: remoteRenderer,
                  toggleState: toggleState,
                  userId: widget.userId,
                ))));
  }
}

class ToggleState {
  late bool isCameraToggle = true;
  late bool isLaserToggle = true;

  void updateCameraToggle(bool value) {
    isCameraToggle = value;
  }

  void updateLaserToggle(bool value) {
    isLaserToggle = value;
  }
}
