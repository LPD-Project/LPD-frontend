import 'dart:convert';
import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:http/http.dart' as http;

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> resendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user!.sendEmailVerification();
  }

  Future<void> sendEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user!.sendEmailVerification();
  }

  Future<String?> forgotPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    print('Password reset email sent to $email');
  }

  Future<void> changePassword(String newPassword) async {
    try {
      // Get the current user
      User? user = currentUser;

      // Update the password
      await user!.updatePassword(newPassword);

      print('Password changed successfully');
    } catch (error) {
      print('Error changing password: $error');
      throw error; // You may choose to handle the error differently
    }
  }

  Future<http.Response> loginWithEmailAndPassword(
      {required String urlServer,
      required String email,
      required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found after sign-in.',
      );
    }

    String? idToken = await currentUser.getIdToken();
    // print("id token is " + idToken!);

    try {
      var url = urlServer + '/auth/login';

      http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Error();
      }
    } on Exception catch (_) {
      throw Error();
      // print(e);
    }
  }

  Future<String> RegisterWithEmailAndPassword(
      {required String urlServer,
      required String email,
      required String password,
      required String username}) async {
    try {
      UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? currentUser = _firebaseAuth.currentUser;

      // username email uid imageUrl (frontend upload)
      var url = urlServer + '/auth/createUser';

      // backend search user by email return uid
      http.Response response = await http.post(Uri.parse(url),
          body: jsonEncode(
              {'email': email, 'username': username, 'uid': currentUser!.uid}),
          headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        // send verification email
        await user.user!.sendEmailVerification();

        var body = jsonDecode(response.body);
        print(body);

        var uid = body['uid'];
        print(uid);
        return uid;
      }
    } catch (e) {
      return "error" + e.toString();
    }
    return "error";
  }

  Future<http.Response> signInWithGoogleAccount(
      {required String urlServer,
      required AuthCredential userCredential}) async {
    UserCredential userCred =
        await _firebaseAuth.signInWithCredential(userCredential);
    User? currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found after sign-in.',
      );
    } else {
      String? idToken = await currentUser.getIdToken();

      try {
        var url = urlServer + '/auth/login/google';

        var response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $idToken',
          },
        );

        if (response.statusCode == 200) {
          return response;
        } else {
          throw Error();
        }
      } on Exception catch (_) {
        throw Error();
        // print(e);
      }
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
