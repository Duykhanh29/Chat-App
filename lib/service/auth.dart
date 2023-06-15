import 'package:chat_app/modules/auth/views/widgets/input_verify_number.dart';
import 'package:chat_app/modules/home/views/main_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  //sign in  Anonymous
  Future signInAnonymous() async {
    try {
      var result = await _auth.signInAnonymously();
    } catch (e) {}
  }

  // sign in with email & pass
  Future signInWithEmailAndPassword(
      {required String email, required String password}) async {
    UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    if (result == null) {
      print("No of them");
    }
  }

  //sign out
  Future signOut() async {
    await _auth.signOut();
  }

  // create user == register with email & pass
  Future createUserWithEmailAndPassword(
      {required String email, required String password}) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    if (result == null) {
      print("Failed to create");
    } else {
      print(
          "Success to create with user: ${result.user!.uid} and ${result.user!.email}");
    }
  }

  // GG
  // -- sign in with GG
  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    //  await GoogleSignIn(scopes: <String>['email']).signIn();
    if (googleUser != null) {
      try {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
        UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        if (userCredential == null) {
          print("Nothing to say");
        } else {
          print("Okey name: l ");
        }
        return userCredential;
      } on FirebaseAuthException catch (e) {
        return null;
      }
    }
    // try {
    //   final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    //   final GoogleSignInAuthentication? googleAuth =
    //       await googleUser?.authentication;

    //   if (googleAuth?.accessToken != null && googleAuth?.idToken != null) {
    //     // Create a new credential
    //     final credential = GoogleAuthProvider.credential(
    //       accessToken: googleAuth?.accessToken,
    //       idToken: googleAuth?.idToken,
    //     );
    //     UserCredential userCredential =
    //         await _auth.signInWithCredential(credential);
    //     return userCredential;
    //     // if you want to do specific task like storing information in firestore
    //     // only for new users using google sign in (since there are no two options
    //     // for google sign in and google sign up, only one as of now),
    //     // do the following:

    //     // if (userCredential.user != null) {
    //     //   if (userCredential.additionalUserInfo!.isNewUser) {}
    //     // }
    //   }
    // } on FirebaseAuthException catch (e) {
    //   print("Wrong");
    // }
  }

  Future signOutWithGG() async {
    await _auth.signOut();
    _googleSignIn.signOut();
  }

  // facebook

  Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  // phone
  Future signInWithPhoneNumber(
      BuildContext buildContext, String phoneNumber) async {
    print("Start");
    await _auth.verifyPhoneNumber(
        phoneNumber: "+84 964651146",
        verificationCompleted: (PhoneAuthCredential credential) async {
          print("verificationCompleted");
          //  await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print("verificationFailed");
          if (e.code == 'invalid-phone-number') {
            print('The provided phone number is not valid. and ${e.message}');
          }
        },
        timeout: const Duration(seconds: 120),
        codeSent: (String verificationId, int? resendToken) async {
          print("codeSent");
          // Update the UI - wait for the user to enter the SMS code
          String smsCode = 'xxxx';

          // Create a PhoneAuthCredential with the code
          PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: verificationId, smsCode: smsCode);

          // Sign the user in (or link) with the credential
          //       await _auth.signInWithCredential(credential);
          // verifyId = verificationId;
          Get.snackbar(
              "OTP Sended", "Otp sended on your mobiler number +84964651146");
          Get.to(() => const VerifyPhone());
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("codeAutoRetrievalTimeout");
        });
  }

  Future verifyPhoneNumber(String text) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: "123456", smsCode: "123456");
      await _auth.signInWithCredential(credential);
      Get.offAll(MainView());
    } catch (e) {
      print(e);
    }
  }
}
