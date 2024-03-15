import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lpd/component/end_drawer.dart';
import 'package:lpd/pages/login.dart';

import '../component/responsive_register_layout.dart';
import '../component/register_desktop.dart';
import '../component/register_mobile.dart';
import '../component/responsive_register_layout.dart';
import '../component/navbar_desktop.dart';
import '../component/navbar_mobile.dart';
import '../component/responsive_navbar_layout.dart';

class RegisterPage extends StatefulWidget {
  late String url;
  RegisterPage({required this.url});

  @override
  _RegisterPage createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
                                          LoginPage(
                                            url: widget.url,
                                          ),
                                  transitionDuration:
                                      const Duration(seconds: 0)));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 20, top: 30),
                          child: const Row(children: [
                            Icon(Icons.arrow_back),
                            Text(" Login Page")
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
                    SizedBox(
                      height: 50,
                    ),
                    ResponsiveRegisterLayout(
                        desktopRegister: RegisterDesktop(url: widget.url),
                        mobileRegister: RegisterMobile(url: widget.url)),
                    SizedBox(
                      height: 120,
                    ),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(bottom: 30, left: 30),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: const Color.fromARGB(217, 217, 217, 217)),
                        ),
                        // spacer is for the flexible container / sizebox is for the dix size contrainer @#
                        const Spacer(),
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(bottom: 30, right: 30),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: const Color.fromARGB(217, 217, 217, 217)),
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        )));
  }
}
