import 'package:flutter/material.dart';
import 'package:lpd/pages/contact.dart';
import 'package:lpd/pages/device_select.dart';
import 'package:lpd/pages/home.dart';
import 'package:lpd/pages/login.dart';
import 'package:lpd/pages/room.dart';
import 'package:lpd/pages/user.dart';

class EndDrawer extends StatelessWidget {
  const EndDrawer({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String url = 'https://plankton-app-xmeox.ondigitalocean.app';
    double screenHeight = (MediaQuery.of(context).size.height);
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(
            height: 90,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 45, 117, 67),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          ListTile(
            title: const Text('Home'),
            onTap: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (context, animationT1, animationT2) =>
                          HomePage(url: url),
                      transitionDuration: const Duration(seconds: 0)));
            },
          ),
          // ListTile(
          //   title: const Text('Guide'),
          //   onTap: () {
          //     //  Navigator.push(
          //     //               context,
          //     //               PageRouteBuilder(
          //     //                   pageBuilder:
          //     //                       (context, animationT1, animationT2) =>
          //     //                           DevicePage(url: widget.url),
          //     //                   transitionDuration:
          //     //                       const Duration(seconds: 0)));
          //     // Update the state of the app.
          //     // ...
          //   },
          // ),
          ListTile(
            title: const Text('Device'),
            onTap: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (context, animationT1, animationT2) =>
                          DevicePage(url: url),
                      transitionDuration: const Duration(seconds: 0)));
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            title: const Text('Contact'),
            onTap: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (context, animationT1, animationT2) =>
                          ContactPage(url: url),
                      transitionDuration: const Duration(seconds: 0)));
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            title: const Text('Account'),
            onTap: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (context, animationT1, animationT2) =>
                          UserPage(url: url),
                      transitionDuration: const Duration(seconds: 0)));

              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            title: const Text('Exit'),
            onTap: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (context, animationT1, animationT2) =>
                          LoginPage(url: url),
                      transitionDuration: const Duration(seconds: 0)));
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            title: const Text('TEST'),
            onTap: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (context, animationT1, animationT2) =>
                          RoomPage(url: url),
                      transitionDuration: const Duration(seconds: 0)));

              // Update the state of the app.
              // ...
            },
          ),
        ],
      ),
    );
  }
}
