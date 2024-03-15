import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lpd/component/end_drawer.dart';
import 'package:lpd/component/error_alert.dart';
import 'package:lpd/main.dart';
import 'package:lpd/pages/home.dart';
import 'package:lpd/pages/login.dart';
import 'package:lpd/pages/register.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../component/responsive_register_layout.dart';
import '../component/register_desktop.dart';
import '../component/register_mobile.dart';
import '../component/responsive_register_layout.dart';
import '../component/navbar_desktop.dart';
import '../component/navbar_mobile.dart';
import '../component/responsive_navbar_layout.dart';
import '../auth/auth.dart';
import '../auth/googleAuth.dart';

class ContactPage extends StatefulWidget {
  late String url;
  ContactPage({required this.url});
  @override
  _ContactPage createState() => _ContactPage();
}

class _ContactPage extends State<ContactPage> {
  late TextEditingController _emailController;
  late bool _submitable = false;
  late int _clicked = 0;

  void _updateEmailCheck() {
    bool isEmailValid = _emailController.text.length >= 1;
    if (isEmailValid && (_clicked == 0)) {
      setState(() {
        _submitable = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _emailController.addListener(() {
      _updateEmailCheck();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    _emailController.text = "peerapat.sta@gmail.com";
    return Scaffold(
        appBar: ResponsiveNavBarLayout(
          mobileNavBar: NavBarMobile(),
          desktopNavBar: NavBarDesktop(url: widget.url),
        ),
        backgroundColor: const Color.fromARGB(217, 218, 218, 218),
        endDrawer: EndDrawer(),
        body: SingleChildScrollView(
            child: Center(
          child: Container(
            margin: const EdgeInsets.all(30),
            width: screenWidth >= 600 ? 800 : screenWidth - 30,
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
                                          HomePage(
                                            url: widget.url,
                                          ),
                                  transitionDuration:
                                      const Duration(seconds: 0)));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 20),
                          child: const Row(children: [
                            Icon(Icons.arrow_back),
                            Text(" Home Page")
                          ]),
                        ),
                      ),
                    ),
                    // spacer is for the flexible container / sizebox is for the dix size contrainer @#
                    const Spacer(),
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(top: 30, right: 30),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: const Color.fromARGB(217, 217, 217, 217)),
                    )
                  ],
                ),
                Column(
                  children: [
                    Container(
                      width: screenWidth >= 610 ? 80 : 60,
                      height: screenWidth >= 610 ? 60 : 40,
                      margin: const EdgeInsets.only(right: 20, top: 10),
                      child: SvgPicture.asset('assets/icons/pj-logo.svg'),
                      // margin: EdgeInsets.all(10),
                      // color: Colors.amber,
                    ),
                    Container(
                        child: Text(
                      "Laser Pigeon Deterrent",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: screenWidth >= 610 ? 22 : 18),
                    )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 1,
                          width: screenWidth >= 610 ? 100 : screenWidth * 0.2,
                          color: Colors.black,
                        ),
                        Container(
                          child: Text(" laser it away ",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: screenWidth >= 610 ? 16 : 12)),
                        ),
                        Container(
                          height: 1,
                          width: screenWidth >= 610 ? 100 : screenWidth * 0.2,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 50, right: 50),
                        child: const Text(
                            "Send a message to our email address below , We will respond shortly !")),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: screenWidth >= 610 ? 15 : 25,
                          right: screenWidth >= 610 ? 15 : 25),
                      height: 85,
                      width: 400,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color.fromARGB(255, 230, 230, 230)),
                      child: Container(
                          margin: EdgeInsets.only(left: 15, right: 15),
                          child: TextField(
                            controller: _emailController,
                            readOnly: true,
                            decoration: InputDecoration(
                                labelText: 'Email :',
                                labelStyle: TextStyle(
                                    fontSize: screenWidth >= 610 ? 16 : 14)),
                          )),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                )
              ],
            ),
          ),
        )));
  }
}
