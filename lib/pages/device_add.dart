import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lpd/component/end_drawer.dart';
import 'package:lpd/component/error_alert.dart';
import 'package:lpd/component/success_alert.dart';
import 'package:lpd/main.dart';
import 'package:lpd/pages/device_add_info.dart';
import 'package:lpd/pages/device_select.dart';

import '../responsive/text_adapter.dart';
import '../component/navbar_desktop.dart';
import '../component/navbar_mobile.dart';
import '../component/responsive_navbar_layout.dart';
import '../pages/device_manager.dart';

class DeviceAdd extends StatefulWidget {
  late String url;
  DeviceAdd({required this.url});

  @override
  _DeviceAdd createState() => _DeviceAdd();
}

class _DeviceAdd extends State<DeviceAdd> {
  late TextEditingController _controller;
  late bool _submitable = false;
  FocusNode _focusNode = FocusNode();

  void checkDeviceSerialCode() async {
    final store = StoreProvider.of<AppState>(context);
    final accessToken = store.state.accessToken;

    var url = widget.url + '/device/check';
    print("device_serial_code: " + _controller.text);

    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'device_serial_code': _controller.text}),
    );

    if (response.statusCode == 200) {
      showSuccessAlertDialog(context, "found the device!");
      Future.delayed(Duration(milliseconds: 1200), () {
        Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (context, animationT1, animationT2) =>
                    DeviceAddInfo(
                        url: widget.url, deviceSerialCode: _controller.text),
                transitionDuration: Duration(milliseconds: 500)));
      });
    } else {
      showAlertDialog(context, "Device is paired / no device found");
    }
  }

  void checkValidSerial() {
    var isValid = _controller.text.length == 12;
    setState(() {
      _submitable = isValid;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    _controller.addListener(() {
      checkValidSerial();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: ResponsiveNavBarLayout(
          mobileNavBar: NavBarMobile(),
          desktopNavBar: NavBarDesktop(url: widget.url),
        ),
        backgroundColor: const Color.fromARGB(217, 218, 218, 218),
        endDrawer: EndDrawer(),
        body: SingleChildScrollView(
            child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.all(30),
                width: screenWidth - 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(217, 255, 255, 255)),
                child: Column(
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                      pageBuilder:
                                          (context, animationT1, animationT2) =>
                                              DevicePage(
                                                url: widget.url,
                                              ),
                                      transitionDuration:
                                          const Duration(seconds: 0)));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 20),
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
                    Text(
                      "Device Registeration",
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
                          left: (screenWidth - 30) * 0.1, // 10% from the left,
                          right: (screenWidth - 30) * 0.1),
                      // 10% from the right
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 35, 133, 74),
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    Container(
                      width: 450,
                      height: 50,
                      child: Text(
                        "Enter device’s 12 digit serial code that come with your device.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      height: 110,
                      width: 500,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color.fromARGB(255, 230, 230, 230)),
                      child: Container(
                          margin: EdgeInsets.only(left: 25, right: 25),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                "device serial code",
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                  height: 50,
                                  color: Color.fromARGB(255, 243, 243, 243),
                                  child: Stack(
                                    children: [
                                      TextField(
                                        focusNode: _focusNode,
                                        controller: _controller,
                                        showCursor: false,
                                        style: TextStyle(
                                            color: Colors.transparent),
                                        maxLength: 12,
                                        decoration: const InputDecoration(
                                            border: InputBorder.none),
                                      ),
                                      Positioned.fill(
                                          child: GestureDetector(
                                              onTap: () {
                                                FocusScope.of(context)
                                                    .requestFocus(_focusNode);
                                              },
                                              child: ValueListenableBuilder<
                                                      TextEditingValue>(
                                                  valueListenable: _controller,
                                                  builder: (BuildContext
                                                          context,
                                                      TextEditingValue value,
                                                      Widget? child) {
                                                    return Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: List.generate(
                                                            12, (index) {
                                                          return Container(
                                                            width: screenWidth <
                                                                    420
                                                                ? screenWidth <
                                                                        350
                                                                    ? 18
                                                                    : 20
                                                                : 25,
                                                            height: screenWidth <
                                                                    420
                                                                ? screenWidth <
                                                                        350
                                                                    ? 18
                                                                    : 20
                                                                : 25,
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  width: 2,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          214,
                                                                          214,
                                                                          214)),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                value.text.length >
                                                                        index
                                                                    ? value.text[
                                                                        index]
                                                                    : '',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        screenWidth <
                                                                                350
                                                                            ? 11
                                                                            : 13),
                                                              ),
                                                            ),
                                                          );
                                                        }));
                                                  })))
                                    ],
                                  ))
                            ],
                          )),
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            ),
            Center(
                child: Container(
              width: 120,
              height: 40,
              child: ElevatedButton(
                child: Text(
                  'Enter',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(45)),
                  backgroundColor: Color.fromARGB(255, 82, 146, 71),
                ),
                onPressed: _submitable
                    ? () async {
                        try {
                          checkDeviceSerialCode();
                        } catch (e) {
                          showAlertDialog(context, 'An error occurred: $e');
                        }
                      }
                    : null,
              ),
            ))
          ],
        )));
  }
}
