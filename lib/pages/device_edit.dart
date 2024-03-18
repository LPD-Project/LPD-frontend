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
import 'package:lpd/main.dart';

import '../responsive/text_adapter.dart';
import '../component/navbar_desktop.dart';
import '../component/navbar_mobile.dart';
import '../component/responsive_navbar_layout.dart';
import '../pages/device_manager.dart';

class DeviceEdit extends StatefulWidget {
  late String deviceName;
  late String url;
  late Uint8List imageBytes;
  late String deviceId;
  DeviceEdit(
      {required this.url,
      required this.deviceName,
      required this.imageBytes,
      required this.deviceId});
  @override
  _DeviceEdit createState() => _DeviceEdit();
}

class _DeviceEdit extends State<DeviceEdit> {
  late TextEditingController _controller;

  final ImagePicker _picker = ImagePicker();
  late Uint8List _imageBytes = Uint8List(0);

  Future<void> uploadImage() async {
    var url = widget.url + '/device/upload/image';
    final store = StoreProvider.of<AppState>(context);
    final accessToken = store.state.accessToken;
    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
      body: jsonEncode(
          {"image": widget.imageBytes, 'device_serial_code': widget.deviceId}),
    );
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      print(body);
    } else {
      showAlertDialog(context, "failed to upload image");
    }
  }

  Future getImage(ImageSource media) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['png'],
    );

    if (result != null) {
      if (result.files.first.size! <= 20 * 1024) {
        Uint8List? bytes = result.files.first.bytes;
        return bytes;
      } else {
        showAlertDialog(context, "file too large");
      }
    }
  }

  void selectedImage() async {
    var imgBytes = await getImage(ImageSource.gallery);

    print(imgBytes);
    if (imgBytes != null) {
      setState(() {
        widget.imageBytes = imgBytes;
      });
      print(_imageBytes);
    } else {
      showAlertDialog(context, "no image selected");
    }
  }

  void myAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: const Text('Please choose media to select'),
            content: Container(
              height: kIsWeb ? 50 : MediaQuery.of(context).size.height / 6,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      selectedImage();
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.image),
                        Text('From Gallery'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Conditionally show the camera button only if not running on web
                ],
              ),
            ),
          );
        });
  }

  updateDeviceData() async {
    var url = widget.url + '/device/edit';
    final store = StoreProvider.of<AppState>(context);
    final accessToken = store.state.accessToken;

    await uploadImage();

    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
      body: jsonEncode({
        'device_serial_code': widget.deviceId,
        'device_name': _controller.text
      }),
    );

    if (response.statusCode == 200) {
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animationT1, animationT2) =>
                  DeviceManager(url: widget.url),
              transitionDuration: const Duration(seconds: 0)));
    } else {
      showAlertDialog(context, "fail to update device");
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.deviceName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    setState(() {
      _imageBytes = widget.imageBytes;
    });
    // get image set to imagebytes for UI

    print("didChangeDependencies");
    // Perform some initialization here
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final store = StoreProvider.of<AppState>(context);
    final accessToken = store.state.accessToken;

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
            //  fix height

            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(217, 255, 255, 255)),
            child: Column(
              children: [
                SizedBox(
                  height: 20,
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
                                          DeviceManager(url: widget.url),
                                  transitionDuration:
                                      const Duration(seconds: 0)));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 20),
                          child: const Row(children: [
                            Icon(Icons.arrow_back),
                            Text(" Device Manager")
                          ]),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Spacer(),
                  ],
                ),
                SizedBox(
                  height: 15,
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

                // editing box

                Container(
                    height: 350,
                    width: 750,
                    margin: const EdgeInsets.only(
                      top: 25,
                      bottom: 25,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 251, 251, 251),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          width: 10,
                          color: const Color.fromARGB(255, 237, 237, 237)),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Container(
                              width: screenWidth < 500 ? 100 : 175,
                              height: screenWidth < 500 ? 100 : 175,
                              margin: const EdgeInsets.only(top: 15, left: 30),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15)),
                              child: widget.imageBytes.isEmpty
                                  ? Image.asset(
                                      'assets/icons/cam_icon.png',
                                      fit: BoxFit.fitWidth,
                                    )
                                  : Image.memory(widget.imageBytes,
                                      fit: BoxFit.fitWidth),
                            ),
                            const Spacer(),
                            Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 15),
                                  child: Text(
                                    "Device name :",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(right: (20)),
                                  width: 120,
                                  child: TextField(
                                    controller: _controller,
                                    maxLength: 12,
                                    onChanged: (value) {
                                      if (_controller.text.isEmpty) {
                                        _controller.text = widget.deviceName;
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Container(
                                width: screenWidth < 500 ? 80 : 135,
                                height: screenWidth < 500 ? 35 : 50,
                                margin: const EdgeInsets.only(left: 15),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      backgroundColor: const Color.fromARGB(
                                          255, 91, 107, 188),
                                    ),
                                    onPressed: () {
                                      myAlert();
                                    },
                                    child: screenWidth > 500
                                        ? Text(
                                            "Upload image",
                                            style: TextStyle(
                                                fontSize: screenWidth > 450
                                                    ? 12
                                                    : 10),
                                            textAlign: TextAlign.center,
                                          )
                                        : Text(
                                            "Upload",
                                            style: TextStyle(
                                                fontSize: screenWidth > 450
                                                    ? 12
                                                    : 10),
                                            textAlign: TextAlign.center,
                                          ))),
                            const Spacer(),
                            Row(
                              children: [
                                Container(
                                  width: screenWidth < 500 ? 80 : 135,
                                  height: screenWidth < 500 ? 35 : 50,
                                  child: ElevatedButton(
                                    child: Text(
                                      'cancel',
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 243, 109, 109),
                                          fontSize:
                                              screenWidth > 450 ? 12 : 10),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      backgroundColor: const Color.fromARGB(
                                          255, 236, 203, 203),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                              pageBuilder: (context,
                                                      animationT1,
                                                      animationT2) =>
                                                  DeviceManager(
                                                      url: widget.url),
                                              transitionDuration:
                                                  const Duration(seconds: 0)));
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  width: screenWidth < 500 ? 80 : 135,
                                  height: screenWidth < 500 ? 35 : 50,
                                  margin: EdgeInsets.only(right: 15),
                                  child: ElevatedButton(
                                    child: Text(
                                      'confirm',
                                      style: TextStyle(
                                          fontSize:
                                              screenWidth > 450 ? 12 : 10),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      backgroundColor: const Color.fromARGB(
                                          255, 82, 146, 71),
                                    ),
                                    onPressed: () {
                                      updateDeviceData();
                                      print('cliecked confirm');
                                    },
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        )
                      ],
                    )),
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
