import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuth {
  Future<AuthCredential> signInWithGoogle() async {
    final GoogleSignInAccount? gAccount = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication gAuth = await gAccount!.authentication;

    final credential = await GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken, idToken: gAuth.idToken);

    return credential;
  }
}
