import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:lpd/component/control_room_desktop.dart';
import 'package:lpd/pages/control_room.dart';
import 'package:lpd/pages/device_add.dart';
import 'package:lpd/pages/device_add_info.dart';
import 'package:lpd/pages/device_edit.dart';
import 'package:lpd/pages/device_manager.dart';
import 'package:lpd/pages/forgot_password.dart';
import 'package:lpd/pages/user.dart';
import 'package:lpd/pages/user_edit.dart';
import 'package:redux/redux.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import './pages/home.dart';
import './pages/room.dart';
import './pages/device_select.dart';
import './pages/register.dart';
import './pages/login.dart';

// flutter run -d chrome --web-port 5000 --web-hostname 0.0.0.0 --release

// Define Redux state
class AppState {
  final String? accessToken;
  final String? uid;
  final String? email;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final String? username;

  AppState({
    this.accessToken,
    this.uid,
    this.email,
    this.imageUrl,
    this.imageBytes,
    this.username,
  });

  // Add any other methods you need here
}

class UpdateAccountAction {
  final String? accessToken;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final String? username;

  UpdateAccountAction(
      this.accessToken, this.imageUrl, this.imageBytes, this.username);
}

// Define Redux actions
class LoginAction {
  final String? accessToken;
  final String? uid;
  final String? email;
  final String? imageUrl;
  final String? username;

  LoginAction(
      this.accessToken, this.uid, this.email, this.imageUrl, this.username);
}

class updateImageBytesAction {
  final Uint8List? imageBytes;

  updateImageBytesAction(this.imageBytes);
}

class updateImageUrlAction {
  final String? imageUrl;

  updateImageUrlAction(this.imageUrl);
}

// Define reducer
AppState reducer(AppState state, dynamic action) {
  if (action is LoginAction) {
    return AppState(
      accessToken: action.accessToken,
      uid: action.uid,
      email: action.email,
      imageUrl: action.imageUrl ??
          state.imageUrl, // Use the existing imageUrl if null
      imageBytes: state.imageBytes,
      username: action.username,
    );
  } else if (action is UpdateAccountAction) {
    return AppState(
      accessToken: state.accessToken,
      uid: state.uid,
      email: state.email,
      imageUrl: action.imageUrl,
      imageBytes: action.imageBytes,
      username: action.username,
    );
  } else if (action is updateImageBytesAction) {
    return AppState(
      accessToken: state.accessToken,
      uid: state.uid,
      email: state.email,
      imageUrl: state.imageUrl,
      imageBytes: action.imageBytes,
      username: state.username,
    );
  } else if (action is updateImageUrlAction) {
    return AppState(
      accessToken: state.accessToken,
      uid: state.uid,
      email: state.email,
      imageUrl: action.imageUrl,
      imageBytes: state.imageBytes,
      username: state.username,
    );
  }

  return state;
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final store = Store<AppState>(reducer, initialState: AppState());

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY']!,
      appId: dotenv.env['FIREBASE_APP_ID']!,
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
      projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
    ));
  }

  await Firebase.initializeApp();
  runApp(MyApp(store: store));
}
// void main() {
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  final Store<AppState> store;

  MyApp({required this.store});

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
        store: store,
        child: MaterialApp(
          title: 'LaserPigeonDeterrent',

          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'lexend',
            pageTransitionsTheme: PageTransitionsTheme(
              builders: kIsWeb
                  ? {
                      // No animations for every OS if the app running on the web
                      for (final platform in TargetPlatform.values)
                        platform: const NoTransitionsBuilder(),
                    }
                  : {
                      TargetPlatform.android:
                          const FadeUpwardsPageTransitionsBuilder(),
                      TargetPlatform.iOS:
                          const FadeUpwardsPageTransitionsBuilder(),
                      TargetPlatform.linux:
                          const FadeUpwardsPageTransitionsBuilder(),
                      TargetPlatform.macOS:
                          const FadeUpwardsPageTransitionsBuilder(),
                      TargetPlatform.windows:
                          const FadeUpwardsPageTransitionsBuilder(),
                    },
            ),
          ),
          home: LoginPage(
            url: "http://192.168.1.44:3000",
          ),
          // home: DeviceAddInfo(deviceSerialCode: "qwerasdfzxcv"),
        ));
  }
}

class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget? child,
  ) {
    // only return the child without warping it with animations
    return child!;
  }
}
