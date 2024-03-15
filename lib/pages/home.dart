import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:lpd/component/end_drawer.dart';
import 'package:lpd/main.dart';
import 'package:lpd/responsive/text_adapter.dart';
import 'package:redux/redux.dart';
import '../component/navbar_desktop.dart';
import '../component/navbar_mobile.dart';
import '../component/responsive_navbar_layout.dart';

class HomePage extends StatefulWidget {
  late String url;
  HomePage({required this.url});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Store<AppState> store;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: ResponsiveNavBarLayout(
          mobileNavBar: NavBarMobile(),
          desktopNavBar: NavBarDesktop(
            url: widget.url,
          )),
      endDrawer: EndDrawer(),
      body: Row(
        children: [
          Expanded(
              child: Container(
            margin: EdgeInsets.only(bottom: 20),
            height: MediaQuery.of(context).size.height - 80,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 161, 205, 162),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/icons/model.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          )),

          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Spacer(),
              Container(
                  color: Color.fromARGB(255, 48, 110, 31),
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 15, top: 40, bottom: 20),
                    child: const Text(
                      'LASER PIGEON DETERRENT',
                      style: TextStyle(fontSize: 25, color: Colors.white),
                    ),
                  )),
              Container(
                height: 20,
                color: Color.fromARGB(255, 117, 114, 114),
              ),
              Container(
                child: Container(
                    color: Color.fromARGB(255, 255, 255, 255),
                    margin: EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          margin:
                              EdgeInsets.only(top: 10, bottom: 8, right: 10),
                          alignment: Alignment.centerRight,
                          child: Text(
                            " WELCOME BACK ! ",
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: const AdaptiveTextSize()
                                  .getadaptiveTextSize(context, 30),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 20, right: 20),
                          alignment: Alignment.centerRight,
                          child: Text(store.state.username!,
                              maxLines: 2,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  color: Color.fromARGB(255, 54, 54, 54),
                                  fontSize: const AdaptiveTextSize()
                                      .getadaptiveTextSize(context, 25),
                                  fontWeight: FontWeight.w700)),
                        )
                      ],
                    )),
              ),
              Spacer(),
              Container(
                alignment: Alignment.bottomRight,
                height: (350 / 1080) * MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage('assets/icons/lines-right.png'))),
              ),
            ],
          ))

          // Add your widgets here
        ],
      ),
    );
  }
}
