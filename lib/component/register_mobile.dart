import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lpd/component/error_alert.dart';
import 'package:lpd/pages/login.dart';
import 'package:lpd/pages/register.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import '../auth/auth.dart';

import '../pages/device_edit.dart';

class RegisterMobile extends StatefulWidget {
  late String url;
  RegisterMobile({required this.url});

  @override
  _RegisterMobile createState() => _RegisterMobile();
}

class _RegisterMobile extends State<RegisterMobile> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _reTypePasswordController;

  final ImagePicker _picker = ImagePicker();

  late Uint8List _imageBytes = Uint8List(0);
  late bool _passwordVisible = false;
  late bool _reTypePasswordVisible = false;
  late bool _passwordsMatch = false;

  Future<void> uploadImage(email, uid) async {
    var url = widget.url + '/auth/user/upload/image';

    var response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"image": _imageBytes, 'email': email, 'uid': uid}),
    );
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      print(body);
    } else {
      throw Error();
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    var userId = await Auth().RegisterWithEmailAndPassword(
        urlServer: widget.url,
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text);

    print("userId");
    print(userId);

    if (userId.isEmpty) {
      showAlertDialog(context, userId);
    } else {
      if (!_imageBytes.isEmpty) {
        await uploadImage(_emailController.text, userId);
      }

      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animationT1, animationT2) =>
                  LoginPage(url: widget.url),
              transitionDuration: const Duration(seconds: 0)));
    }

    // print(userId);
  }

  void _updatePasswordsMatch() {
    bool passwordsMatch =
        _passwordController.text == _reTypePasswordController.text;

    bool isPasswordValid = _passwordController.text.length >= 8;

    setState(() {
      _passwordsMatch = passwordsMatch & isPasswordValid;
    });
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
      print(_imageBytes);
    } else {
      showAlertDialog(context, "no image selected");
    }
  }

  void captureImage() async {
    var imgBytes = await getImage(ImageSource.camera);
    if (imgBytes != null) {
      setState(() {
        _imageBytes = imgBytes;
      });
    } else {
      print("no image selected");
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animationT1, animationT2) =>
                  RegisterPage(url: widget.url),
              transitionDuration: const Duration(seconds: 0)));
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

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _reTypePasswordController = TextEditingController();
    _passwordVisible = false;
    _reTypePasswordVisible = false;
    _passwordsMatch = false;

    _passwordController.addListener(() {
      _updatePasswordsMatch();
    });

    _reTypePasswordController.addListener(() {
      _updatePasswordsMatch();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _reTypePasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Container(
          child: Column(
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
                    width: 150,
                    height: 150,
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
                    child: _imageBytes.isEmpty
                        ? SvgPicture.asset('assets/icons/account.svg')
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(
                                150), // Half of width or height to make it a circle
                            child: Image.memory(_imageBytes),
                          ),
                  ),
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
              const SizedBox(height: 20),
              Container(
                height: 1,
                color: Colors.black,
                width: 400,
              ),
              const SizedBox(height: 20),
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
                    margin: const EdgeInsets.only(left: 15, right: 15),
                    height: 75,
                    width: 400,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: const Color.fromARGB(255, 230, 230, 230)),
                    child: Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: TextField(
                          controller: _emailController,
                          maxLength: 32,
                          decoration:
                              const InputDecoration(labelText: 'Email :'),
                        )),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 15, right: 15),
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
                        )),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 15, right: 15),
                    height: 75,
                    width: 400,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: const Color.fromARGB(255, 230, 230, 230)),
                    child: Container(
                      margin: EdgeInsets.only(left: 15, right: 15),
                      child: TextField(
                          controller: _passwordController,
                          maxLength: 16,
                          decoration: InputDecoration(
                            labelText: 'Password :',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible =
                                      !_passwordVisible; // Toggle password visibility
                                });
                              },
                            ),
                          ),
                          obscureText: !_passwordVisible),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 15, right: 15),
                    height: 75,
                    width: 400,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: const Color.fromARGB(255, 230, 230, 230)),
                    child: Container(
                      margin: const EdgeInsets.only(left: 15, right: 15),
                      child: TextField(
                          controller: _reTypePasswordController,
                          maxLength: 16,
                          decoration: InputDecoration(
                            labelText: 'Confirm password again :',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _reTypePasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _reTypePasswordVisible =
                                      !_reTypePasswordVisible; // Toggle password visibility
                                });
                              },
                            ),
                          ),
                          obscureText: !_reTypePasswordVisible),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        Container(
          width: 350,
          height: 70,
          child: ElevatedButton(
            child: AbsorbPointer(
                absorbing: !_passwordsMatch,
                child: Text(
                  'Confirm Registration',
                  style: TextStyle(
                      color: Color.fromARGB(255, 92, 92, 92),
                      fontWeight: FontWeight.w700,
                      fontSize: 18),
                )),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              backgroundColor: const Color.fromARGB(255, 189, 255, 178),
            ),
            onPressed: _passwordsMatch
                ? () {
                    print("Register");
                    try {
                      createUserWithEmailAndPassword();
                    } catch (e) {
                      showAlertDialog(context, e.toString());
                    }
                  }
                : null,
          ),
        )
      ],
    );
  }
}
