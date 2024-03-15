import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavBarMobile extends StatelessWidget implements PreferredSizeWidget {
  const NavBarMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String url = "192.168.1.123:3000";
    return SafeArea(
      child: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          iconTheme:
              IconThemeData(color: const Color.fromARGB(255, 10, 96, 13)),

          automaticallyImplyLeading: false,
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          // actions: [
          //   Column(
          //     children: [
          //       SizedBox(height: 16),
          //       GestureDetector(
          //         onTap: null,
          //         child: Container(
          //             // alignment: Alignment.center,
          //             margin: const EdgeInsets.only(right: 20),
          //             decoration: BoxDecoration(
          //                 color: const Color.fromARGB(255, 213, 213, 213),
          //                 borderRadius: BorderRadius.circular(10)),
          //             child: SvgPicture.asset(
          //               'assets/icons/hamburger-menu.svg',
          //               height: 40,
          //             )),
          //       )
          //     ],
          //   )
          // ],
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 20,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: SvgPicture.asset('assets/icons/pj-logo.svg'),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Laser Pigeon Deterrent",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'lexend',
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
