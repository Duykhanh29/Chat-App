import 'package:chat_app/modules/auth/views/startPage.dart';
import 'package:chat_app/modules/auth/views/widgets/input_verify_number.dart';
import 'package:chat_app/modules/home/views/main_view.dart';
import 'package:chat_app/modules/profile/views/widgets/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/data/models/user.dart' as userModel;
import 'package:chat_app/utils/constants/constants.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<User?> user = Rx<User?>(null);
  //late final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  late Rx<TextEditingController> emailController;
  late Rx<TextEditingController> passwordControllerRegister;
  late Rx<TextEditingController> phoneController;
  late Rx<TextEditingController> nameController;
  RxBool isVisiblePasswordRegister = false.obs;
  RxBool isLogin = false.obs;
  Rx<userModel.User?> currentUser = Rx<userModel.User?>(null);
  RxBool isGGLogin = false.obs;
  @override
  void onInit() {
    // TODO: implement onInit
    print("Go ahead");
    emailController = TextEditingController().obs;
    passwordControllerRegister = TextEditingController().obs;
    phoneController = TextEditingController().obs;
    nameController = TextEditingController().obs;
    super.onInit();
    if (firebaseAuth.currentUser == null) {
      user.bindStream(firebaseAuth.userChanges());
    } else {
      print("WTF");
      user = Rx<User?>(firebaseAuth.currentUser);
      user.bindStream(firebaseAuth
          .userChanges()); // our user can be changed by logout login ,... It listen the change of user
      //print("Name nha: ${user.value!.displayName}");
      updateUser(user.value!);

      // ever function used for observe changes of user and perform a certain activity whenever user changes
    }
    ever(user, initialScreen); // every times user changes, initialScreen notify
    updateTextController(currentUser);
  }

  void updateUserInAuth(
      {String? name, String? email, String? photoUrl, String? phone}) async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      var displayName = name != null ? name : user.displayName;
      var photoURL = photoUrl != null ? photoUrl : user.photoURL;
      var phoneNumber = phone != null ? phone : user.phoneNumber;
      var newEmail = email != null ? email : user.email;
      await user.updateDisplayName(displayName);
      await user.updateEmail(newEmail!);
      await user.updatePhotoURL(photoURL);
      // await user.updatePhoneNumber(phoneNumber);
      print(
          "received value 2: displayName: $displayName, photoURL: $photoURL, phoneNumber:$phoneNumber, newEmail: $newEmail ");
      // updateUser(user);
    }
  }

  void updateUser(User user) {
    currentUser.value = userModel.User(
        email: user.email,
        name: user.displayName ?? "No name",
        id: user.uid,
        phoneNumber: user.phoneNumber,
        urlImage: user.photoURL ??
            "https://t4.ftcdn.net/jpg/03/59/58/91/360_F_359589186_JDLl8dIWoBNf1iqEkHxhUeeOulx0wOC5.jpg",
        userStatus: userModel.UserStatus.OFFLINE);
    currentUser.value!.showALlAttribute();
    updateTextController(currentUser);
  }

  void updateTextController(Rx<userModel.User?> currentUser) {
    if (currentUser.value != null) {
      if (currentUser.value!.phoneNumber == null) {
        phoneController.value.text = "";
      } else {
        phoneController.value.text = currentUser.value!.phoneNumber!;
      }
      if (currentUser.value!.email == null) {
        emailController.value.text = "";
      } else {
        emailController.value.text = currentUser.value!.email!;
      }
      if (currentUser.value!.name == null) {
        nameController.value.text = "";
      } else {
        nameController.value.text = currentUser.value!.name!;
      }
    } else {
      print("currentUser.value == null");
    }
  }

  // I still don't understand when this function is called in some cases
  initialScreen(User? user) {
    // updateUser(user!);
    if (user == null) {
      Get.offAll(() => const StartPage());
    } else {
      Get.offAll(() => MainView());
    }
  }

  // sign in with email & pass
  Future signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      UserCredential result = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      if (result == null) {
        Get.snackbar("About User", "User message",
            snackPosition: SnackPosition.BOTTOM,
            titleText: const Text("failed"),
            messageText: const Text(
              "Failed to sign in",
            ),
            backgroundColor: Colors.redAccent);
      } else {
        updateUser(result.user!);

        isLogin.value = true;
        //  update();
      }
    } catch (e) {
      Get.snackbar("About User", "User message",
          snackPosition: SnackPosition.BOTTOM,
          titleText: const Text("failed"),
          messageText: const Text(
            'User not found',
          ),
          backgroundColor: Colors.redAccent);
    }
  }

//   ever(user, initialScreen);
  // create user == register with email & pass
  Future createUserWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      UserCredential result = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (result == null) {
        Get.snackbar("About User", "User message",
            snackPosition: SnackPosition.BOTTOM,
            titleText: const Text("Account create failed"),
            messageText: const Text(
              "Failed to create an account",
            ),
            backgroundColor: Colors.redAccent);
      } else {
        if (existedUserCheckWithPhoneOrEmail(
                phone: result.user!.phoneNumber, email: result.user!.email) ==
            true) {
          Get.snackbar("About User", "User message",
              snackPosition: SnackPosition.BOTTOM,
              titleText: const Text("Notice"),
              messageText: const Text(
                "User already exists",
              ),
              backgroundColor: Colors.redAccent);
        } else {
          updateUser(result.user!);
          await FirebaseFirestore.instance
              .collection("users")
              .doc(currentUser.value!.id)
              .set(currentUser.toJson());
          isLogin.value = true;
          Get.snackbar("About User", "User message",
              snackPosition: SnackPosition.BOTTOM,
              titleText: const Text("Account create successfully"),
              backgroundColor: Colors.redAccent);
        }
      }
    } catch (e) {
      Get.snackbar("About User", "User message",
          snackPosition: SnackPosition.BOTTOM,
          titleText: const Text("Account create failed"),
          messageText: Text(
            e.toString(),
          ),
          backgroundColor: Colors.redAccent);
    }
  }

  Future sendPasswordReset(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      Get.defaultDialog(title: "Notice", content: Text(e.toString()), actions: [
        TextButton(
            onPressed: () {
              Get.back(); // close dialog
            },
            child: const Text('Close'))
      ]);
    }
  }

  //sign out
  Future signOut() async {
    await firebaseAuth.signOut();
    currentUser.value = null;
    user.value = null;
    await _googleSignIn.signOut();
    isGGLogin.value = false;
    // update();
  }

  Future signOutWithGG() async {
    await firebaseAuth.signOut();
    _googleSignIn.signOut();
    isGGLogin.value = false;
  }

  // GG
  // -- sign in with GG
  Future signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        try {
          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          final AuthCredential credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
          UserCredential userCredential =
              await firebaseAuth.signInWithCredential(credential);

          if (userCredential == null) {
            Get.snackbar(
              "Notice",
              "User is null",
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.grey[800],
            );
          } else {
            updateUser(userCredential.user!);
            var result = await existedUserCheckWithPhoneOrEmail(
                email: userCredential.user!.email);
            if (result == false) {
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(currentUser.value!.id)
                  .set(currentUser.toJson());
            }
            Get.snackbar(
              "Notice",
              "Sign in successful",
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.grey[800],
            );

            // before add user to database, we need to check whether this user already in the database to avoid create many records with the same user

            isGGLogin.value = true;
            //Get.to(() => MainView());
          }
          return userCredential;
        } on FirebaseAuthException catch (e) {
          Get.snackbar(
            "Notice",
            "Some thing went wrong",
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.redAccent[800],
          );
        }
      } else {
        Get.snackbar(
          "Notice",
          "You cancel login with GG",
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.redAccent[800],
        );
      }
    } catch (e) {
      print("An error: $e");
    }
  }

  // facebook
  Future<void> signInWithFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);

      await firebaseAuth.signInWithCredential(facebookAuthCredential);
    } on FirebaseAuthException catch (e) {
      Get.snackbar("title", "message");
    }
  }

  // phone
  Future signInWithPhoneNumber(
      BuildContext buildContext, String phoneNumber) async {
    print("Start");
    await firebaseAuth.verifyPhoneNumber(
        phoneNumber: "+84 964651146",
        verificationCompleted: (PhoneAuthCredential credential) async {
          print("verificationCompleted");
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
          Get.snackbar("title", "message",
              titleText: const Text("Time out"),
              snackPosition: SnackPosition.BOTTOM);
        });
  }

  Future verifyPhoneNumber(String text) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: "123456", smsCode: "123456");
      await firebaseAuth.signInWithCredential(credential);
      Get.offAll(MainView());
    } catch (e) {
      print(e);
    }
  }

  // ANONYMOUS SIGN IN
  Future<void> signInAnonymously() async {
    try {
      await firebaseAuth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      Get.snackbar("title", "message");
    }
  }

  // DELETE ACCOUNT
  Future<void> deleteAccount() async {
    try {
      await firebaseAuth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      Get.snackbar("title", "message");
    }
  }

// read all user
  // the first way of reading all users
  Stream<List<userModel.User>> getListUserInDB() {
    return FirebaseFirestore.instance.collection('users').snapshots().map(
        (event) =>
            event.docs.map((e) => userModel.User.fromJson(e.data())).toList());
  }

  // the second way of reading all users
  Future<List<userModel.User>> getAllUserFromDB() async {
    List<userModel.User> list = [];
    final snapsort = await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((value) => value.docs.forEach((element) {
              userModel.User user = userModel.User(
                id: element.data()['id'],
                name: element.data()['name'],
                email: element.data()['email'],
                phoneNumber: element.data()['phoneNumber'],
                story: element.data()['story'],
                urlImage: element.data()['urlImage'],
                userStatus:
                    userModel.getUserStatus(element.data()['userStatus']),
              );
              list.add(user);
            }));
    return list;
  }

  Future existedUserCheckWithPhoneOrEmail(
      {String? phone, String? email}) async {
    final firebaseFirestore =
        await FirebaseFirestore.instance.collection("users").get();
    int size = firebaseFirestore.size;
    if (size != 0) {
      List<userModel.User> list = [];
      firebaseFirestore.docs.forEach((element) {
        userModel.User modelUser = userModel.User(
          id: element.data()['id'],
          name: element.data()['name'],
          email: element.data()['email'],
          phoneNumber: element.data()['phoneNumber'],
          story: element.data()['story'],
          urlImage: element.data()['urlImage'],
          userStatus: userModel.getUserStatus(element.data()['userStatus']),
        );
        list.add(modelUser);
      });
      for (var data in list) {
        if (data.email == email && data.email != null ||
            data.phoneNumber == phone && data.phoneNumber != null) {
          return true;
        }
      }
    }
    return false;
  }

  // edit current user
  Future editUser(
      {String? email, String? phone, String? name, String? urlImage}) async {
    var displayName = name!.isNotEmpty ? name : currentUser.value!.name;
    var photoURL = urlImage != null ? urlImage : currentUser.value!.urlImage;
    var phoneNumber = phone! != null ? phone : currentUser.value!.phoneNumber;
    var newEmail = email! != null ? email : currentUser.value!.email;
    print(
        "received value: displayName: $displayName, photoURL: $photoURL, phoneNumber:$phoneNumber, newEmail: $newEmail ");
    userModel.User newUser = userModel.User(
        userStatus: currentUser.value!.userStatus,
        email: newEmail,
        id: currentUser.value!.id,
        name: displayName,
        phoneNumber: phoneNumber,
        story: currentUser.value!.story,
        urlImage: photoURL);
    await FirebaseFirestore.instance
        .collection("users")
        .doc(newUser.id)
        .update(newUser.toJson());
    currentUser.value = newUser;
    updateTextController(currentUser);
    updateUserInAuth(
        email: email, name: name, phone: phone, photoUrl: urlImage);
  }

  void resetEditUser() {
    if (currentUser.value!.phoneNumber == null) {
      phoneController.value.text = "";
    } else {
      phoneController.value.text = currentUser.value!.phoneNumber!;
    }
    if (currentUser.value!.email == null) {
      emailController.value.text = "";
    } else {
      emailController.value.text = currentUser.value!.email!;
    }
    if (currentUser.value!.name == null) {
      nameController.value.text = "";
    } else {
      nameController.value.text = currentUser.value!.name!;
    }
  }
}
