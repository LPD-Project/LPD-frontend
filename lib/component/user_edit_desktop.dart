import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lpd/component/error_alert.dart';
import 'package:lpd/component/success_alert.dart';
import 'package:lpd/main.dart';
import 'package:lpd/pages/home.dart';
import 'package:lpd/pages/login.dart';
import 'package:lpd/pages/register.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_redux/flutter_redux.dart';
import 'package:lpd/pages/user.dart';

import '../auth/auth.dart';

import '../pages/device_edit.dart';

class UserEditDesktop extends StatefulWidget {
  late String url;

  UserEditDesktop({required this.url});
  @override
  _UserEditDesktop createState() => _UserEditDesktop();
}

class _UserEditDesktop extends State<UserEditDesktop> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late bool _validUsername = false;

  final ImagePicker _picker = ImagePicker();
  late Uint8List _imageBytes = Uint8List(0);

  Future<void> uploadImage(email, uid) async {
    var url = widget.url + '/auth/user/upload/image';
    final store = StoreProvider.of<AppState>(context);

    var response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"image": _imageBytes, 'email': email, 'uid': uid}),
    );
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      print(body);
      StoreProvider.of<AppState>(context).dispatch(updateImageUrlAction(
        body['url'],
      ));
    } else {
      throw Error();
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
        _imageBytes = imgBytes;
      });
      StoreProvider.of<AppState>(context).dispatch(updateImageBytesAction(
        _imageBytes,
      ));
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

  Future<void> updateUserData() async {
    final store = StoreProvider.of<AppState>(context);
    final accessToken = store.state.accessToken;
    final String newusername = _usernameController.text;

    var url = widget.url + "/user/edit";
    http.Response response = await http.post(Uri.parse(url),
        body: jsonEncode({'username': newusername}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        });

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      final store = StoreProvider.of<AppState>(context);

      if (!_imageBytes.isEmpty) {
        await uploadImage(_emailController.text, store.state.uid);
      }

      StoreProvider.of<AppState>(context).dispatch(LoginAction(
          responseBody['accesstoken'],
          store.state.uid,
          store.state.email,
          store.state.imageUrl,
          responseBody['username']));

      showSuccessAlertDialog(context, "Updating user data ..");
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animationT1, animationT2) =>
                  UserPage(url: widget.url),
              transitionDuration: const Duration(milliseconds: 500)));
    } else {
      print("error");
      throw Error();
    }
  }

  void _updateUsernameCheck() {
    bool isUsernameValid = _usernameController.text.length >= 1;
    setState(() {
      _validUsername = isUsernameValid;
    });
  }

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _usernameController = TextEditingController();

    _usernameController.addListener(() {
      _updateUsernameCheck();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);

    _emailController.text = store.state.email!;
    // _usernameController.text = store.state.username!;

    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: const Text(
                      "Profile's image",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Container(
                      width: 200,
                      height: 200,
                      margin: const EdgeInsets.only(top: 25),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color.fromARGB(255, 175, 175,
                              175), // You can change the color of the border here
                          width:
                              10, // You can adjust the width of the border here
                        ),
                      ),
                      child: (store.state.imageBytes == null)
                          ? SvgPicture.asset('assets/icons/account.svg')
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  150), // Half of width or height to make it a circle
                              child: Image.memory(store.state.imageBytes!))),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                      width: screenWidth >= 620 ? 175 : 115,
                      height: 35,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
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
              const SizedBox(width: 45),
              Container(
                height: 400,
                color: Colors.black,
                width: 1,
              ),
              const SizedBox(width: 45),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      child: const Text(
                    "Insert Information Below :",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  )),
                  SizedBox(
                    height: 10,
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
                          controller: _emailController,
                          enabled: false,
                          readOnly: true,
                          maxLength: 32,
                          decoration:
                              const InputDecoration(labelText: 'Email :'),
                        )),
                  ),
                  SizedBox(
                    height: 10,
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
                          controller: _usernameController,
                          maxLength: 16,
                          decoration:
                              const InputDecoration(labelText: 'Username :'),
                          onChanged: (value) {
                            if (_usernameController.text.isEmpty) {
                              _usernameController.text = store.state.username!;
                            }
                          },
                        )),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 150,
              height: 50,
              child: ElevatedButton(
                  child: AbsorbPointer(
                      child: Text(
                    'cancel',
                    style: TextStyle(
                        color: Color.fromARGB(255, 92, 92, 92),
                        fontWeight: FontWeight.w700,
                        fontSize: 18),
                  )),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    backgroundColor: Color.fromARGB(255, 237, 174, 174),
                  ),
                  onPressed: () {
                    try {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder:
                                  (context, animationT1, animationT2) =>
                                      UserPage(url: widget.url),
                              transitionDuration: const Duration(seconds: 0)));
                    } catch (e) {
                      showAlertDialog(context, 'An error occurred: $e');
                    }
                  }),
            ),
            const SizedBox(
              width: 20,
            ),
            Container(
              width: 150,
              height: 50,
              child: ElevatedButton(
                child: AbsorbPointer(
                    absorbing: !_validUsername,
                    child: Text(
                      'confirm',
                      style: TextStyle(
                          color: Color.fromARGB(255, 92, 92, 92),
                          fontWeight: FontWeight.w700,
                          fontSize: 18),
                    )),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  backgroundColor: Color.fromARGB(255, 189, 255, 178),
                ),
                onPressed: _validUsername
                    ? () {
                        try {
                          print("confirm");
                          updateUserData();
                        } catch (e) {
                          showAlertDialog(context, 'An error occurred: $e');
                        }
                      }
                    : null,
              ),
            ),
            const SizedBox(
              width: 20,
            )
          ],
        )
      ],
    );
  }
}
