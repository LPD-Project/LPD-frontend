import 'package:flutter/material.dart';
import 'package:lpd/component/end_drawer.dart';
import 'package:lpd/rtc/signaling.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../component/navbar_desktop.dart';
import '../component/navbar_mobile.dart';
import '../component/responsive_navbar_layout.dart';

class RoomPage extends StatefulWidget {
  late String url;
  RoomPage({required this.url});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  Signaling signaling = Signaling();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  // String? _dataChannelMessage = "";

  void onAnswerClick(device_serial_code, userId) async {
    await signaling.joinCommunicationRoom(device_serial_code, userId);
  }

  void onOfferClick() async {
    await signaling.createCommunicationRoom();
  }

  @override
  void initState() {
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    signaling.dataChannel?.onDataChannelState = (state) {
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        print("Data channel opened");
      }
    };

    // signaling.dataChannel!.onDataChannelState = ((message) {
    //   print(message);
    // });

    super.initState();
  }

  @override
  void dispose() {
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _textEditingController = TextEditingController();
    return Scaffold(
      appBar: ResponsiveNavBarLayout(
          mobileNavBar: NavBarMobile(),
          desktopNavBar: NavBarDesktop(
            url: widget.url,
          )),
      endDrawer: EndDrawer(),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: RTCVideoView(_remoteRenderer)),
                  ],
                ),
              ),
            ),
            TextField(
              controller: _textEditingController,
              decoration: const InputDecoration(
                labelText: 'Enter your text',
                border: OutlineInputBorder(),
              ),
            ),
            TextButton(
              child: const Text("answer button"),
              onPressed: () {
                String enteredText = _textEditingController.text;
                print("enteredText" + enteredText);

                // change parameters
                onAnswerClick("qwerasdfzxcv", "user1");
              },
            ),
            TextButton(
              child: const Text("offer button"),
              onPressed: () {
                onOfferClick();
              },
            ),
          ],
        ),
      ),
    );
  }
}
