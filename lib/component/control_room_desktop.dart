import 'package:flutter/material.dart';
import 'package:lpd/pages/control_room.dart';
import 'package:lpd/pages/device_select.dart';
import 'package:lpd/responsive/text_adapter.dart';
import 'package:lpd/rtc/signaling.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../component/navbar_desktop.dart';
import '../component/navbar_mobile.dart';
import '../component/responsive_navbar_layout.dart';

class ControlRoomDesktopPage extends StatefulWidget {
  late String deviceSerialCode;
  late String url;
  late Signaling signaling;
  late RTCVideoRenderer remoteRenderer;
  late ToggleState toggleState;
  late String userId;

  ControlRoomDesktopPage({
    required this.deviceSerialCode,
    required this.url,
    required this.signaling,
    required this.remoteRenderer,
    required this.toggleState,
    required this.userId,
  });

  @override
  State<ControlRoomDesktopPage> createState() => _ControlRoomDesktopPage();
}

class _ControlRoomDesktopPage extends State<ControlRoomDesktopPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    RTCVideoRenderer remoteRenderer = widget.remoteRenderer;
    ToggleState buildToggleState = widget.toggleState;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isToggleCamera = widget.toggleState.isCameraToggle;
    bool isToggleLaser = widget.toggleState.isLaserToggle;

    TextEditingController _textEditingController = TextEditingController();
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: const EdgeInsets.only(left: 30, top: 30, bottom: 30),
              width: screenWidth >= 1020 ? screenWidth / 1.5 : 700,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(217, 255, 255, 255)),
              child: Column(
                children: [
                  Row(
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            widget.signaling
                                .hangUp(widget.userId, widget.deviceSerialCode);

                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                    pageBuilder:
                                        (context, animationT1, animationT2) =>
                                            DevicePage(url: widget.url),
                                    transitionDuration:
                                        const Duration(seconds: 0)));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 20, top: 15),
                            child: const Row(children: [
                              Icon(Icons.arrow_back),
                              Text(" Devices")
                            ]),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Spacer(),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "Device Camera",
                        style: TextStyle(
                          fontSize: const AdaptiveTextSize()
                              .getadaptiveTextSize(context, 25),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        height: 10,
                        margin: EdgeInsets.only(
                            top: 25,
                            bottom: 25,
                            left:
                                (screenWidth - 30) * 0.1, // 10% from the left,
                            right: (screenWidth - 30) * 0.1),

                        // 10% from the right

                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 11, 163, 67),
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      // image stream
                      Container(
                          color: Colors.black87,
                          width: screenWidth / 1.75,
                          height: screenWidth / 1.75 * 9 / 16,
                          child: Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  isToggleCamera
                                      ? Expanded(
                                          child: RTCVideoView(remoteRenderer))
                                      : Container()
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(
                        height: 55,
                      )
                    ],
                  )
                ],
              )),
          Container(
              width: 300,
              height: 300,
              margin: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), color: Colors.white),
              child: Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Device Control",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: const AdaptiveTextSize()
                          .getadaptiveTextSize(context, 17),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    height: 5,
                    width: 200,
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    // 10% from the right
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 114, 114, 114),
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 40, right: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Camera : ",
                              style: TextStyle(fontSize: 16),
                            ),
                            GestureDetector(
                              onTap: () {
                                widget.toggleState.updateCameraToggle(
                                    !widget.toggleState.isCameraToggle);
                                setState(() {
                                  isToggleCamera =
                                      widget.toggleState.isCameraToggle;
                                });
                                print(widget.toggleState.isCameraToggle);

                                // send camera control command

                                widget.signaling.sendCameraControl(
                                    widget.userId,
                                    widget.deviceSerialCode,
                                    isToggleCamera.toString());
                              },
                              child: Container(
                                width: 100,
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: isToggleCamera
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                child: Text(
                                  isToggleCamera ? 'ON' : 'OFF',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 40, right: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Laser : ",
                                style: TextStyle(fontSize: 16),
                              ),
                              GestureDetector(
                                onTap: () {
                                  widget.toggleState.updateLaserToggle(
                                      !widget.toggleState.isLaserToggle);
                                  setState(() {
                                    isToggleLaser =
                                        widget.toggleState.isLaserToggle;
                                  });
                                  print(widget.toggleState.isLaserToggle);

                                  // send laser control command

                                  widget.signaling.sendLaserControl(
                                      widget.userId,
                                      widget.deviceSerialCode,
                                      isToggleLaser.toString());
                                },
                                child: Container(
                                  width: 100,
                                  height: 50,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: isToggleLaser
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  child: Text(
                                    isToggleLaser ? 'ON' : 'OFF',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ))
                    ],
                  )
                ],
              )),
        ]);
  }
}
