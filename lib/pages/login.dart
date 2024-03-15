import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lpd/component/error_alert.dart';
import 'package:lpd/main.dart';
import 'package:lpd/pages/forgot_password.dart';
import 'package:lpd/pages/home.dart';
import 'package:lpd/pages/register.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:lpd/pages/user_edit.dart';

import '../component/responsive_register_layout.dart';
import '../component/register_desktop.dart';
import '../component/register_mobile.dart';
import '../component/responsive_register_layout.dart';
import '../component/navbar_desktop.dart';
import '../component/navbar_mobile.dart';
import '../component/responsive_navbar_layout.dart';
import '../auth/auth.dart';
import '../auth/googleAuth.dart';

class LoginPage extends StatefulWidget {
  late String url;
  LoginPage({required this.url});
  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  late bool _canLogin = false;
  String? _errorMessage;
  String? _errorCode;
  late bool _submitable = false;
  late bool _passwordVisible = false;

  Future<Uint8List> getUserImage(acccestoken) async {
    var url = widget.url + '/auth/user/image';
    Uint8List? bytes = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $acccestoken',
    }).then((res) async {
      if (res.statusCode == 200) {
        final String dataString =
            utf8.decode(res.bodyBytes); // Convert bytes to string
        final map = jsonDecode(dataString) as Map<String, dynamic>;

        print(" map bytes decode :" + map.toString());
        if (map['message'] == "no image uploaded") {
          return Uint8List(0);
        }

        final imageBytesData =
            map['imageBytes']['data'] as List<dynamic>; // Use List<dynamic>
        final imageBytes = imageBytesData.cast<int>(); // Cast elements to int

        final uint8list = Uint8List.fromList(imageBytes);

        return uint8list;
      } else {
        return Uint8List(0);
      }
    });

    return bytes!;
  }

  void checkLogin() {
    if (_canLogin) {
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animationT1, animationT2) => HomePage(
                    url: widget.url,
                  ),
              transitionDuration: const Duration(seconds: 0)));
    } else {
      // raise error
      print(_errorCode! + _errorMessage!);
    }
  }

  Future<void> loginWithEmailAndPassword() async {
    try {
      http.Response res = await Auth().loginWithEmailAndPassword(
          urlServer: widget.url,
          email: _emailController.text,
          password: _passwordController.text);

      if (res.statusCode == 200) {
        var responseBody = jsonDecode(res.body);
        var resImageUrl = responseBody['imageUrl'];
        print("resImageUrl " + responseBody['imageUrl'].toString());
        print("runtime type ");
        print(responseBody['imageUrl'].runtimeType);

        if (responseBody['imageUrl'] != null) {
          await getUserImage(responseBody['accesstoken']).then((bytes) {
            print("bytes is not empty");

            print(" responseBody['accesstoken']" + responseBody['accesstoken']);

            StoreProvider.of<AppState>(context).dispatch(LoginAction(
                responseBody['accesstoken'],
                responseBody['uid'],
                responseBody['email'],
                responseBody['imageUrl'],
                responseBody['username']));

            StoreProvider.of<AppState>(context).dispatch(updateImageBytesAction(
              bytes,
            ));

            // update username load from firestore instead!!

            setState(() {
              _canLogin = true;
            });
          });
        } else {
          StoreProvider.of<AppState>(context).dispatch(LoginAction(
              responseBody['accesstoken'],
              responseBody['uid'],
              responseBody['email'],
              null,
              responseBody['username']));

          StoreProvider.of<AppState>(context).dispatch(updateImageBytesAction(
            null,
          ));
          setState(() {
            _canLogin = true;
          });
        }
      } else {
        setState(() {
          _canLogin = false;
        });
        throw Error();
      }
    } catch (e) {
      setState(() {
        _canLogin = false;
      });
      showAlertDialog(context, "wrong user email or password");
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final credentail = await GoogleAuth().signInWithGoogle();

      var res = await Auth().signInWithGoogleAccount(
          urlServer: widget.url, userCredential: credentail);

      if (res.statusCode == 200) {
        // save state to store
        var responseBody = jsonDecode(res.body);
        print(responseBody);
        print("google access token");
        print(responseBody['accesstoken']!);

        await getUserImage(responseBody['accesstoken']).then((bytes) {
          print(
            "bytes is ",
          );
          print(bytes);
          if (bytes.isNotEmpty) {
            StoreProvider.of<AppState>(context).dispatch(updateImageBytesAction(
              bytes,
            ));
          }

          StoreProvider.of<AppState>(context).dispatch(LoginAction(
              responseBody['accesstoken'],
              responseBody['uid'],
              responseBody['email'],
              responseBody['imageUrl'],
              responseBody['username']));

          // update username load from firestore instead!!

          setState(() {
            _canLogin = true;
          });
        });
      } else {
        setState(() {
          _canLogin = false;
        });
        showAlertDialog(context, "unable to login with google");
      }
    } catch (e) {
      setState(() {
        _canLogin = false;
      });
    }
  }

  void _updatePasswordsMatch() {
    bool isPasswordValid = _passwordController.text.length >= 1;
    bool isEmailValid = _emailController.text.length >= 1;

    setState(() {
      _submitable = isEmailValid & isPasswordValid;
    });
  }

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    _passwordVisible = false;

    _passwordController.addListener(() {
      _updatePasswordsMatch();
    });

    _emailController.addListener(() {
      _updatePasswordsMatch();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: const Color.fromARGB(217, 218, 218, 218),
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
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(top: 30, left: 30),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: const Color.fromARGB(217, 217, 217, 217)),
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
                    Column(
                      children: [
                        Container(
                          child: Text(
                            "Insert Information Below : ",
                            style: TextStyle(
                                fontSize: screenWidth >= 610 ? 18 : 14),
                          ),
                        ),
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
                                decoration: InputDecoration(
                                    labelText: 'Email :',
                                    labelStyle: TextStyle(
                                        fontSize:
                                            screenWidth >= 610 ? 16 : 14)),
                              )),
                        ),
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
                                controller: _passwordController,
                                obscureText: !_passwordVisible,
                                decoration: InputDecoration(
                                    labelText: 'Password :',
                                    labelStyle: TextStyle(
                                        fontSize: screenWidth >= 610 ? 16 : 14),
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
                                    )),
                              )),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: screenWidth >= 610 ? 300 : 230,
                          height: 1,
                          color: const Color.fromARGB(255, 102, 102, 102),
                          margin: const EdgeInsets.only(top: 15, bottom: 15),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: 150,
                          height: 60,
                          child: ElevatedButton(
                            child: Text(
                              'Login',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 92, 92, 92),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(45)),
                              backgroundColor:
                                  Color.fromARGB(255, 189, 255, 178),
                            ),
                            onPressed: _submitable
                                ? () async {
                                    try {
                                      print("click login");
                                      await loginWithEmailAndPassword();
                                      checkLogin();
                                    } catch (e) {
                                      showAlertDialog(
                                          context, 'An error occurred: $e');
                                    }
                                  }
                                : null,
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                            child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                    pageBuilder:
                                        (context, animationT1, animationT2) =>
                                            ForgotPasswordPage(url: widget.url),
                                    transitionDuration:
                                        const Duration(seconds: 0)));
                          },
                          child: const MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 92, 92, 92),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12),
                              )),
                        )),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: screenWidth >= 610 ? 150 : 50,
                              height: 1,
                              color: const Color.fromARGB(255, 102, 102, 102),
                              margin:
                                  const EdgeInsets.only(top: 15, bottom: 15),
                            ),
                            const Text(
                              " or ",
                              style: TextStyle(fontSize: 14),
                            ),
                            Container(
                              width: screenWidth >= 610 ? 150 : 50,
                              height: 1,
                              color: const Color.fromARGB(255, 102, 102, 102),
                              margin:
                                  const EdgeInsets.only(top: 15, bottom: 15),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color.fromARGB(255, 240, 240, 240)),
                          child: GestureDetector(
                            onTap: () async {
                              try {
                                await signInWithGoogle();
                                print("done google login");
                                checkLogin();
                              } catch (e) {
                                showAlertDialog(context, e.toString());
                              }
                            },
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(
                                margin: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  image: const DecorationImage(
                                      fit: BoxFit.contain,
                                      image: AssetImage(
                                          'assets/icons/google_icon.png')),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        Container(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              child: const Text(
                                'Dont have an account?',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 92, 92, 92),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12),
                              ),
                            ),
                            GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                          pageBuilder: (context, animationT1,
                                                  animationT2) =>
                                              RegisterPage(url: widget.url),
                                          transitionDuration:
                                              const Duration(seconds: 0)));
                                },
                                child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Container(
                                      child: const Text(
                                        "Register",
                                        style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 6, 96, 1),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13),
                                      ),
                                    ))),
                          ],
                        )),
                        Row(
                          children: [
                            Container(
                              width: (400 / 1080) *
                                          MediaQuery.of(context).size.width >=
                                      400
                                  ? 400
                                  : (400 / 1080) *
                                      MediaQuery.of(context).size.width,
                              height: (350 / 1080) *
                                          MediaQuery.of(context).size.width >=
                                      350
                                  ? 350
                                  : (350 / 1080) *
                                      MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: AssetImage(
                                          'assets/icons/lines-left.png'))),
                            ),
                            const Spacer(),
                            Container(
                              width: (400 / 1080) *
                                          MediaQuery.of(context).size.width >=
                                      400
                                  ? 400
                                  : (400 / 1080) *
                                      MediaQuery.of(context).size.width,
                              height: (350 / 1080) *
                                          MediaQuery.of(context).size.width >=
                                      350
                                  ? 350
                                  : (350 / 1080) *
                                      MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: AssetImage(
                                          'assets/icons/lines-right.png'))),
                            )
                          ],
                        )
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        )));
  }
}
