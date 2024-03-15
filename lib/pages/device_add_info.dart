import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lpd/component/end_drawer.dart';
import 'package:lpd/component/error_alert.dart';
import 'package:lpd/component/success_alert.dart';
import 'package:lpd/main.dart';
import 'package:lpd/pages/device_add.dart';
import 'package:lpd/pages/device_select.dart';
import 'package:lpd/pages/home.dart';

import '../responsive/text_adapter.dart';
import '../component/navbar_desktop.dart';
import '../component/navbar_mobile.dart';
import '../component/responsive_navbar_layout.dart';
import '../pages/device_manager.dart';

class DeviceAddInfo extends StatefulWidget {
  final String deviceSerialCode;
  late String url;

  DeviceAddInfo({required this.url, required this.deviceSerialCode});

  @override
  _DeviceAddInfo createState() => _DeviceAddInfo();
}

class _DeviceAddInfo extends State<DeviceAddInfo> {
  late TextEditingController _controller;
  late TextEditingController _devicenameController;

  final ImagePicker _picker = ImagePicker();
  late Uint8List _imageBytes = Uint8List(0);

  late bool _submitable = false;
  FocusNode _focusNode = FocusNode();

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
          {"image": _imageBytes, 'device_serial_code': _controller.text}),
    );
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      print(body);
    } else {
      showAlertDialog(context, "failed to upload image");
    }
  }

  void checkDeviceSerialCode() async {
    final store = StoreProvider.of<AppState>(context);
    final accessToken = store.state.accessToken;

    var url = widget.url + "/device/pair";

    if (_devicenameController.text == null) {
      _devicenameController.text = "LPD Device";
    }

    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
      body: jsonEncode({
        'device_serial_code': _controller.text,
        'device_name': _devicenameController.text
      }),
    );
    if (response.statusCode == 200) {
      showSuccessAlertDialog(context, "Pairing device to your account..");

      if (!_imageBytes.isEmpty) {
        var res = await uploadImage();
      }

      Future.delayed(Duration(milliseconds: 1200), () {
        Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (context, animationT1, animationT2) =>
                    DevicePage(url: widget.url),
                transitionDuration: Duration(milliseconds: 500)));
      });
    } else {
      showAlertDialog(context, "Unable to pair device to your account");
    }
  }

  Future getImage(ImageSource media) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['png'],
    );

    if (result != null) {
      if (result.files.first.size! <= 100 * 1024) {
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
        _imageBytes = imgBytes;
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

  void checkValidName() {
    var isValid = _devicenameController.text.length >= 1;
    setState(() {
      print(_controller.text.length);
      print(isValid);
      _submitable = isValid;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.deviceSerialCode);
    _devicenameController = TextEditingController();

    _devicenameController.addListener(() {
      checkValidName();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _devicenameController.dispose();

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
            SizedBox(
              height: 15,
            ),
            Center(
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
                                              DeviceAdd(url: widget.url),
                                      transitionDuration:
                                          const Duration(seconds: 0)));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 20),
                              child: const Row(children: [
                                Icon(Icons.arrow_back),
                                Text(" Add Device")
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
                      height: 40,
                      child: Text(
                        " we found your device ✔️",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15),
                      ),
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
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: 200,
                      height: 1,
                      color: Colors.black,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 240),
                      child: const Text(
                        "please name this device : ",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 75,
                      width: 400,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color.fromARGB(255, 230, 230, 230)),
                      child: Container(
                          margin: EdgeInsets.only(left: 15, right: 15),
                          child: TextField(
                            controller: _devicenameController,
                            maxLength: 12,
                            decoration:
                                const InputDecoration(hintText: "device name"),
                          )),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text("upload device image : "),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: 700,
                      margin: EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 197, 197, 197),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 500 / 1080 * screenWidth >= 400
                                ? 400
                                : 500 / 1080 * screenWidth,
                            height: 250 / 1080 * screenWidth >= 200
                                ? 200
                                : 250 / 1080 * screenWidth,
                            margin: EdgeInsets.only(left: 15, right: 15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Color.fromARGB(255, 50, 50, 50)),
                            child: _imageBytes.isEmpty
                                ? SvgPicture.asset('assets/icons/account.svg')
                                : ClipRRect(
                                    child: Image.memory(_imageBytes),
                                  ),
                          ),
                          Container(
                            width: 3,
                            height: 200,
                            margin: EdgeInsets.only(top: 15, bottom: 15),
                            color: const Color.fromARGB(255, 125, 125, 125),
                          ),
                          Container(
                              width: screenWidth >= 620 ? 175 : 115,
                              height: 35,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    backgroundColor:
                                        const Color.fromARGB(255, 91, 107, 188),
                                  ),
                                  onPressed: () {
                                    myAlert();
                                  },
                                  child: const Text(
                                    "Upload image",
                                    textAlign: TextAlign.center,
                                  )))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: 120,
                      height: 40,
                      child: ElevatedButton(
                        child: Text(
                          'Confirm',
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
                                  showAlertDialog(
                                      context, 'An error occurred: $e');
                                }
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            ),
          ],
        )));
  }
}
