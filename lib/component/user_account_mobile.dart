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
import 'package:lpd/pages/user_edit.dart';

import '../auth/auth.dart';

import '../pages/device_edit.dart';

class UserAccountMobile extends StatefulWidget {
  late String url;
  UserAccountMobile({required this.url});

  @override
  _UserAccountMobile createState() => _UserAccountMobile();
}

class _UserAccountMobile extends State<UserAccountMobile> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late Uint8List _image = Uint8List(0);

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();

    _emailController = TextEditingController();

    // image url later
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
    _usernameController.text = store.state.username!;
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        const SizedBox(width: 20),
        Container(
          child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    child: const Text(
                      "Account's image",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  Container(
                      width: (250 / 720) * screenWidth,
                      height: (250 / 720) * screenWidth,
                      margin: const EdgeInsets.only(top: 15),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color.fromARGB(255, 175, 175,
                              175), // You can change the color of the border here
                          width:
                              10, // You can adjust the width of the border here
                        ),
                      ),
                      child: ((store.state.imageUrl == null) ||
                              (store.state.imageBytes == null))
                          ? SvgPicture.asset('assets/icons/account.svg')
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  150), // Half of width or height to make it a circle
                              child: Image.memory(store.state.imageBytes!))),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: 250,
                color: Colors.black,
                height: 1,
              ),
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      child: const Text(
                    "Insert Information Below :",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  )),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    height: 70,
                    width: (400 / 720) * screenWidth,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: const Color.fromARGB(255, 230, 230, 230)),
                    child: Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: TextField(
                          controller: _emailController,
                          enabled: false,
                          readOnly: true,
                          style: TextStyle(fontSize: 14),
                          maxLength: 32,
                          decoration:
                              const InputDecoration(labelText: 'Email :'),
                        )),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    height: 70,
                    width: (400 / 720) * screenWidth,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: const Color.fromARGB(255, 230, 230, 230)),
                    child: Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: TextField(
                          controller: _usernameController,
                          maxLength: 16,
                          enabled: false,
                          readOnly: true,
                          style: TextStyle(fontSize: 14),
                          decoration:
                              const InputDecoration(labelText: 'Username :'),
                        )),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: (270 / 720) * screenWidth,
              height: screenWidth > 600 ? 60 : 50,
              child: ElevatedButton(
                child: Text(
                  'Edit profile',
                  style: TextStyle(
                      color: Color.fromARGB(255, 92, 92, 92),
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(45)),
                  backgroundColor: Color.fromARGB(255, 189, 255, 178),
                ),
                onPressed: () async {
                  try {
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (context, animationT1, animationT2) =>
                                UserEdit(
                                  url: widget.url,
                                ),
                            transitionDuration: const Duration(seconds: 0)));
                  } catch (e) {
                    showAlertDialog(context, 'An error occurred: $e');
                  }
                },
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
