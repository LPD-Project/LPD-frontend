import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lpd/auth/auth.dart';
import 'package:lpd/main.dart';
import 'package:lpd/pages/contact.dart';
import 'package:lpd/pages/login.dart';
import 'package:lpd/pages/user.dart';
import 'package:redux/redux.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../pages/home.dart';
import '../pages/room.dart';
import '../pages/device_select.dart';
import '../responsive/text_adapter.dart';

class _NavBarDesktopState extends State<NavBarDesktop> {
  late Uint8List imageBytes = Uint8List(0);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);

    return SafeArea(
      child: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            title: Column(
              children: [
                Container(
                  height: 25,
                ),
                Row(children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(left: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                150), // Half of width or height to make it a circle
                            child: SvgPicture.asset('assets/icons/pj-logo.svg'),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(left: 22),
                          child: const Text(
                            " L P D ",
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ]),
                  const SizedBox(width: 30),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder:
                                    (context, animationT1, animationT2) =>
                                        HomePage(url: widget.url),
                                transitionDuration:
                                    const Duration(seconds: 0)));
                      },
                      child: const Text(
                        'Home',
                        style: TextStyle(fontSize: 16),
                      )),
                  // const TextButton(
                  //     onPressed: null,
                  //     child: Text(
                  //       'Guide',
                  //       style: TextStyle(fontSize: 16),
                  //     )),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder:
                                    (context, animationT1, animationT2) =>
                                        DevicePage(url: widget.url),
                                transitionDuration:
                                    const Duration(seconds: 0)));
                      },
                      child: const Text(
                        'Device',
                        style: TextStyle(fontSize: 16),
                      )),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder:
                                    (context, animationT1, animationT2) =>
                                        ContactPage(url: widget.url),
                                transitionDuration:
                                    const Duration(seconds: 0)));
                      },
                      child: Text(
                        'Contact',
                        style: TextStyle(fontSize: 16),
                      )),
                ])
              ],
            ),
            actions: [
              Column(
                children: [
                  SizedBox(height: 15),
                  Row(children: [
                    GestureDetector(
                        onTap: (() {
                          {
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                    pageBuilder:
                                        (context, animationT1, animationT2) =>
                                            UserPage(url: widget.url),
                                    transitionDuration:
                                        const Duration(seconds: 0)));
                          }
                        }),
                        child: Container(
                            width: 30,
                            height: 30,
                            margin: EdgeInsets.only(right: 20, top: 10),
                            child: ((store.state.imageUrl == null) ||
                                    (store.state.imageBytes == null))
                                ? MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: SvgPicture.asset(
                                        'assets/icons/account.svg'),
                                  )
                                : MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            150), // Half of width or height to make it a circle
                                        child: Image.memory(
                                            store.state.imageBytes!))))),
                    GestureDetector(
                        onTap: (() async {
                          await Auth().signOut();
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                  pageBuilder:
                                      (context, animationT1, animationT2) =>
                                          LoginPage(url: widget.url),
                                  transitionDuration:
                                      const Duration(seconds: 0)));
                        }),
                        child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Container(
                              width: 30,
                              height: 30,
                              margin: EdgeInsets.only(right: 25, top: 10),
                              child: SvgPicture.asset('assets/icons/exit.svg'),
                              // color: Color.fromARGB(255, 120, 207, 82),
                            )))
                  ])
                ],
              )

              // GestureDetector(
              //     onTap: null,
              //     child: Container(

              //         margin: EdgeInsets.all(10),
              //         height: 30,
              //         child: SvgPicture.asset('assets/icons/account.svg'))),
              // Container(
              //     margin: EdgeInsets.all(10),
              //     height: 30,
              //     child: SvgPicture.asset('assets/icons/exit.svg'))
            ]),
      ),
    );
  }
}

class NavBarDesktop extends StatefulWidget {
  late String url;
  NavBarDesktop({required this.url});
  @override
  _NavBarDesktopState createState() => _NavBarDesktopState();
}
