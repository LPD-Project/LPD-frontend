import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:lpd/component/end_drawer.dart';
import 'package:lpd/component/error_alert.dart';
import 'package:lpd/main.dart';
import '../component/navbar_desktop.dart';
import '../component/navbar_mobile.dart';
import '../component/responsive_navbar_layout.dart';
import '../responsive/text_adapter.dart';
import '../component/device_card.dart';
import '../component/edit_device_card.dart';
import '../pages/device_select.dart';
import 'package:http/http.dart' as http;

class DeviceManager extends StatefulWidget {
  DeviceManager({required this.url});
  late String url;
  @override
  _DeviceManagerState createState() => _DeviceManagerState();
}

class _DeviceManagerState extends State<DeviceManager> {
  late Future<List<dynamic>> deviceList;

  Future<String> getDeviceImageUrl(acccestoken, deviceId) async {
    var url = widget.url + '/device/image/url';

    var res = await http.post(Uri.parse(url),
        body: jsonEncode({"device_serial_code": deviceId}),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $acccestoken',
        });

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      print("i got image body" + body.toString());
      var url = body["url"];
      return url;
    } else {
      return "no image";
    }
  }

  Future<Uint8List> getDeviceImage(acccestoken, deviceId) async {
    var url = widget.url + '/device/image';

    var bytes = await http.post(Uri.parse(url),
        body: jsonEncode({"device_serial_code": deviceId}),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $acccestoken',
        }).then((res) async {
      if (res.statusCode == 200) {
        var url = await getDeviceImageUrl(acccestoken, deviceId);
        print(url);
        if (url! != "no image") {
          final String dataString =
              utf8.decode(res.bodyBytes); // Convert bytes to string
          final map = jsonDecode(dataString) as Map<String, dynamic>;

          final imageBytesData =
              map['imageBytes']['data'] as List<dynamic>; // Use List<dynamic>

          final imageBytes = imageBytesData.cast<int>(); // Cast elements to int

          final uint8list = Uint8List.fromList(imageBytes);

          print("success get byte");
          return uint8list;
        } else {
          print("make u8 0");
          return Uint8List(0);
        }
      } else {
        print(" i got error null url xx");
        return Uint8List(0);
      }
    });

    if (bytes == Uint8List(0)) {
      return bytes;
    } else {
      return bytes;
    }
  }

  Future<List<dynamic>> getAvailableDevice() async {
    print("i work");
    final store = StoreProvider.of<AppState>(context);
    final accessToken = store.state.accessToken;

    var url = widget.url + '/device/availableDevices';

    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      var deviceList = body['availableDevice'];

      for (var i = 0; i < deviceList.length; i++) {
        var imageBytes =
            await getDeviceImage(accessToken, deviceList[i]['deviceId']);
        print("imageBytes.runtimeType");

        print(imageBytes.runtimeType);

        deviceList[i]['imageBytes'] = imageBytes;
      }

      return deviceList;
    } else {
      showAlertDialog(context, "error getting Online devices");
      return [{}];
    }
  }

  @override
  void initState() {
    // _remoteRenderer.initialize();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    deviceList = getAvailableDevice();
    print("didChangeDependencies");
    // Perform some initialization here
  }

  unPairDevice(device_serial_code) async {
    // user device_serial_code
    final store = StoreProvider.of<AppState>(context);
    final accessToken = store.state.accessToken;

    var url = widget.url + '/device/unpair';

    var res = await http.post(Uri.parse(url),
        body: jsonEncode({"device_serial_code": device_serial_code}),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken',
        });
    if (res.statusCode == 200) {
      setState(() {
        deviceList = getAvailableDevice();
      });
    } else {
      showAlertDialog(context, "fail unpair device");
    }
  }

  void _showDeleteConfirmationDialog(device_serial_code) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to unpair this device?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                unPairDevice(device_serial_code);
                Navigator.of(context).pop();
                // Remove the device from the list
                // setState(() {
                //   deviceList.removeAt(index);
                // });
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: ResponsiveNavBarLayout(
          mobileNavBar: NavBarMobile(),
          desktopNavBar: NavBarDesktop(url: widget.url),
        ),
        endDrawer: EndDrawer(),
        backgroundColor: const Color.fromARGB(217, 218, 218, 218),
        body: SingleChildScrollView(
            child: Center(
          child: Container(
            margin: const EdgeInsets.all(30),
            width: screenWidth - 30,
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
                          margin: const EdgeInsets.only(left: 20),
                          child: const Row(children: [
                            Icon(Icons.arrow_back),
                            Text(" Devices")
                          ]),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      margin: const EdgeInsets.only(right: 25, top: 15),
                      child: const Column(children: [
                        Text(
                          "setting",
                          style: TextStyle(
                              color: Color.fromARGB(217, 198, 198, 198)),
                        ),
                        Icon(Icons.settings,
                            color: Color.fromARGB(217, 227, 227, 227), size: 30)
                      ]),
                    )
                  ],
                ),
                Text(
                  "Device Manager",
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
                      color: const Color.fromARGB(255, 255, 173, 8),
                      borderRadius: BorderRadius.circular(5)),
                ),
                FutureBuilder<List<dynamic>>(
                  future: deviceList,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<dynamic>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Wrap(
                        spacing: 35,
                        runSpacing: 35,
                        alignment: WrapAlignment.center,
                        direction: Axis.horizontal,
                        children: [
                          ...snapshot.data!.mapIndexed((index, device) {
                            return Stack(
                              children: [
                                EditDeviceCard(
                                  url: widget.url,
                                  imageBytes: device['imageBytes'],
                                  deviceSerialCode: device['deviceId'],
                                  deviceName:
                                      device['deviceName'] ?? 'devicename',
                                  status: device['status'] ?? 'try restart',
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.only(left: 45, top: 220),
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        backgroundColor: const Color.fromARGB(
                                            255, 208, 106, 106),
                                      ),
                                      onPressed: () {
                                        print("text button pressed");
                                        _showDeleteConfirmationDialog(
                                            device['deviceId']);
                                      },
                                      child: const Text(
                                        "Unpair this device",
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      )),
                                )
                              ],
                            );

                            // GestureDetector(
                            //   onTap: () async {
                            //     try {
                            //       final store =
                            //           StoreProvider.of<AppState>(context);
                            //       final deviceSerialCode = device['deviceId']!;

                            //       print(deviceSerialCode);
                            //       _showDeleteConfirmationDialog(index);
                            //       // onAnswerClick("qwerasdfzxcv", "user1");
                            //     } catch (e) {
                            //       showAlertDialog(context, e.toString());
                            //     }
                            //   },
                            //   child: DeviceCard(
                            //     imageBytes: device['imageBytes'],
                            //     deviceSerialCode: device['deviceId'],
                            //     deviceName:
                            //         device['deviceName'] ?? 'devicename',
                            //     status: device['status'] ?? '...',
                            //   ),
                            // );
                          }),
                        ],
                      );
                    }
                  },
                ),

                // Wrap(
                //     direction: Axis.horizontal,
                //     alignment: WrapAlignment.center,
                //     spacing: 40,
                //     runSpacing: 40,
                //     children: [
                //       ...deviceList.mapIndexed((index, device) {
                //         return Stack(
                //           children: [
                //             EditDeviceCard(
                //                 deviceName: device['name'] ?? 'devicename',
                //                 status: device['status'] ?? '...'),
                //             Container(
                //               margin: const EdgeInsets.only(left: 45, top: 220),
                //               child: ElevatedButton(
                //                   style: ElevatedButton.styleFrom(
                //                     shape: RoundedRectangleBorder(
                //                         borderRadius:
                //                             BorderRadius.circular(15)),
                //                     backgroundColor: const Color.fromARGB(
                //                         255, 208, 106, 106),
                //                   ),
                //                   onPressed: () {
                //                     _showDeleteConfirmationDialog(index);
                //                   },
                //                   child: const Text(
                //                     "Unpair this device",
                //                     style: TextStyle(
                //                       color: Color.fromARGB(255, 255, 255, 255),
                //                       fontWeight: FontWeight.w700,
                //                       fontSize: 12,
                //                     ),
                //                   )),
                //             )
                //           ],
                //         );
                //       }).toList()
                //     ]

                //     ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: (400 / 1080) * MediaQuery.of(context).size.width >=
                              400
                          ? 400
                          : (400 / 1080) * MediaQuery.of(context).size.width,
                      height: (350 / 1080) *
                                  MediaQuery.of(context).size.width >=
                              350
                          ? 350
                          : (350 / 1080) * MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image:
                                  AssetImage('assets/icons/lines-left.png'))),
                    ),
                    const Spacer(),
                    Container(
                      width: (400 / 1080) * MediaQuery.of(context).size.width >=
                              400
                          ? 400
                          : (400 / 1080) * MediaQuery.of(context).size.width,
                      height: (350 / 1080) *
                                  MediaQuery.of(context).size.width >=
                              350
                          ? 350
                          : (350 / 1080) * MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image:
                                  AssetImage('assets/icons/lines-right.png'))),
                    )
                  ],
                )
              ],
            ),
          ),
        )));
  }
}

//  margin: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10), color: Colors.amber),
//         child: Column(children: []),
