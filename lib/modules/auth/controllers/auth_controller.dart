import 'package:chat_app/modules/auth/views/startPage.dart';
import 'package:chat_app/modules/auth/views/widgets/input_verify_number.dart';
import 'package:chat_app/modules/auth/views/widgets/verify_email_page.dart';
import 'package:chat_app/modules/home/views/main_view.dart';
import 'package:chat_app/modules/profile/views/widgets/profile_view.dart';
import 'package:chat_app/service/services_method.dart';
import 'package:chat_app/service/storage_service.dart';
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
  RxBool isEMailVerified = false.obs;
  RxBool isLoad = false.obs;
  RxBool isUpdateInfor = false.obs;
  RxBool isPhone = false.obs;
  void changeIsUpdateInforToTrue() {
    isUpdateInfor.value = true;
  }

  void resetIsUpdateInfor() {
    isUpdateInfor.value = false;
  }

  @override
  void onInit() async {
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
      await updateUser(user.value!).whenComplete(() {
        print("Fine");
      });

      // ever function used for observe changes of user and perform a certain activity whenever user changes
    }
    ever(user, initialScreen); // every times user changes, initialScreen notify
    updateTextController(currentUser);
  }

  @override
  void onClose() {
    // TODO: implement onClose
    emailController.value.dispose();
    passwordControllerRegister.value.dispose();
    phoneController.value.dispose();
    nameController.value.dispose();
    super.onClose();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  void updateUserInAuth(
      {String? name, String? email, String? photoUrl, String? phone}) async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      var displayName = name ?? user.displayName;
      var photoURL = photoUrl ?? user.photoURL;
      Object? phoneNumber = phone ?? user.phoneNumber;
      var newEmail = email ?? user.email;
      await user.updateDisplayName(displayName);
      await user.updateEmail(newEmail!);
      await user.updatePhotoURL(photoURL);
      // await user.updatePhoneNumber(phoneNumber);
      // await user.updatePhoneNumber(phoneNumber);
      print(
          "received value 2: displayName: $displayName, photoURL: $photoURL, phoneNumber:$phoneNumber, newEmail: $newEmail ");
      // updateUser(user);
    }
  }

  Future<void> sendVerificationCodeToPhoneNumber(String phoneNumber) async {
    try {
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Automatic verification (e.g., on Android with auto-read SMS)
          // In this example, we'll assume this case won't happen
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Verification failed: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          print("Code sent to $phoneNumber");
          // setState(() {
          //   _verificationId = verificationId;
          // });
          print("verificationId: $verificationId");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("Auto retrieval timeout");
        },
      );
    } catch (e) {
      print("Error sending verification code: $e");
    }
  }

  Future updateUser(User user) async {
    currentUser.value = userModel.User(
      email: user.email,
      name: user.displayName ?? "No name",
      id: user.uid,
      phoneNumber: user.phoneNumber,
      urlImage: user.photoURL ??
          "https://t4.ftcdn.net/jpg/03/59/58/91/360_F_359589186_JDLl8dIWoBNf1iqEkHxhUeeOulx0wOC5.jpg",
      userStatus: userModel.UserStatus.OFFLINE,
      // urlCoverImage: newUser!.urlCoverImage ??
      //     "https://wallpaperaccess.com/full/393735.jpg"
    );
    userModel.User? newUser = await getDataFromFirebase(user);
    if (newUser != null) {
      currentUser.value!.urlCoverImage = newUser.urlCoverImage;
    } else {
      currentUser.value!.urlCoverImage =
          "https://wallpaperaccess.com/full/393735.jpg";
    }

    currentUser.value!.showALlAttribute();
    updateTextController(currentUser);
  }

  Future<userModel.User?> getDataFromFirebase(User user) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      userModel.User modelUser = userModel.User.fromJson(data);
      return modelUser;
    }
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
    if (isGGLogin.value) {
      if (user == null) {
        Get.offAll(() => const StartPage());
      } else {
        Get.offAll(() => MainView());
      }
    } else {
      if (user != null && user.emailVerified && isUpdateInfor.value == true) {
        // Get.to((ProfileView));
      } else if (user != null && user.emailVerified) {
        Get.offAll(() => MainView());
      } else if (user != null && !user.emailVerified) {
        Get.offAll(() => const VerifyEmailPage());
      } else {
        Get.offAll(() => const StartPage());
      }
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
        await updateUser(result.user!); //HERE

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

  void changeEmailVerified() {
    isEMailVerified.value = !isEMailVerified.value;
  }

  Future<bool> sendEmailVerification(User? user) async {
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        await user.reload();
        return true;
      } catch (e) {
        print('Lỗi khi gửi email xác minh: $e');
        return false;
      }
    }
    return false;
  }

  Future sendVerificationEmail(User? user) async {
    try {
      await user!.sendEmailVerification();
      //   await user.reload();
      if (user.emailVerified) {
        isLoad.value = false;
      } else {
        isLoad.value = true;
      }
    } catch (e) {}
  }

  bool isEmailVerified(User? user) {
    return user?.emailVerified ?? false;
  }

  // create user == register with email & pass

  Future<bool> sendEmailVerificationLink(String email) async {
    String emailLink = 'https://www.example.com/completeSignUp?email=$email';
    var actionCodeSettings = ActionCodeSettings(
      url: emailLink,
      handleCodeInApp: true,
      iOSBundleId: 'com.example.ios',
      androidPackageName: 'com.example.android',
      androidInstallApp: true,
      androidMinimumVersion: '12',
      dynamicLinkDomain: 'example.page.link',
    );

    FirebaseAuth.instance
        .sendSignInLinkToEmail(
            email: email, actionCodeSettings: actionCodeSettings)
        .catchError((onError) {
      return false;
    }).then((value) {
      return true;
    });
    return false;
  }

  Future addUserToFirebase(User? user) async {
    await updateUser(user!);

    if (currentUser.value == null) {
      print("No way");
    } else {
      // if (result.user!.emailVerified) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.value!.id)
          .set(currentUser.toJson());
      isLogin.value = true;
    }
  }

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
          result.user!.delete();
          firebaseAuth.signOut();
          Get.snackbar("About User", "User message",
              snackPosition: SnackPosition.BOTTOM,
              titleText: const Text("Notice"),
              messageText: const Text(
                "User already exists",
              ),
              backgroundColor: Colors.redAccent);
        } else {
          addUserToFirebase(result.user!); // HERE
          // create a new document in friend
          ServiceMethod.createFriendForNewUser(currentUser.value);
          // final value = await sendEmailVerification(result.user);
          // if (value) {
          // bool isVerified = isEmailVerified(result.user!);
          // bool isVerified =
          //     await sendEmailVerificationLink(result.user!.email!);
          // if (isVerified) {
          // print('Email đã được xác minh');
          // updateUser(result.user!);

          // if (currentUser.value == null) {
          //   print("No way");
          // } else {
          //   // if (result.user!.emailVerified) {
          //   await FirebaseFirestore.instance
          //       .collection("users")
          //       .doc(currentUser.value!.id)
          //       .set(currentUser.toJson());
          //   isLogin.value = true;
          //   await result.user!.reload();
          // }

          // Get.snackbar("About User", "User message",
          //     snackPosition: SnackPosition.BOTTOM,
          //     titleText: const Text("Account create successfully"),
          //     backgroundColor: Colors.redAccent);
          // }
          // } else {
          //   await firebaseAuth.currentUser!.delete();
          //   await firebaseAuth.signOut();
          //   print('Email chưa được xác minh');
          // }
          // } else {
          //   await firebaseAuth.currentUser!.delete();
          //   await firebaseAuth.signOut();
          //   print("Your road finish at the moment");
          // }
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

// password
  Future changePassword(
      {required String? newPass,
      required String? oldPass,
      required String email}) async {
    final cre = EmailAuthProvider.credential(email: email, password: oldPass!);
    await firebaseAuth.currentUser!
        .reauthenticateWithCredential(cre)
        .then((value) => firebaseAuth.currentUser!.updatePassword(newPass!))
        .catchError((err) {
      print("An error occured: $email");
    });
  }

  Future<bool> isValidCurrentPassword(String currentPassword) async {
    try {
      final user = firebaseAuth.currentUser;
      final credential = EmailAuthProvider.credential(
          email: user!.email!, password: currentPassword);
      await firebaseAuth.currentUser!.reauthenticateWithCredential(credential);
      print("isValidCurrentPassword: true");
      return true;
    } catch (e) {
      print("Error: $e");
      print("isValidCurrentPassword: false");
      return false;
    }
  }

  //sign out
  Future signOut() async {
    await firebaseAuth.signOut();
    await _googleSignIn.signOut();
    currentUser.value = null;
    user.value = null;
    isLogin.value = false;
    isGGLogin.value = false;
    isEMailVerified.value = false;
    // update();
  }

  Future signOutWithGG() async {
    await firebaseAuth.signOut();
    _googleSignIn.signOut();
    isLogin.value = false;
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
            isLogin.value = true;
            await updateUser(userCredential.user!); // HERE
            var result = await existedUserCheckWithPhoneOrEmail(
                email: userCredential.user!.email);
            if (result == false) {
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(currentUser.value!.id)
                  .set(currentUser.toJson())
                  .whenComplete(() {
                Get.snackbar(
                  "Notice",
                  "Sign in successful",
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.grey[800],
                );
              });
              //set a document in friends collection
              ServiceMethod.createFriendForNewUser(currentUser.value);
            }

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
                urlCoverImage: element.data()['urlCoverImage'],
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
          urlCoverImage: element.data()['urlCoverImage'],
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
      {String? email,
      String? phone,
      String? name,
      String? urlImage,
      String? coverImage}) async {
    var displayName = name ?? currentUser.value!.name;
    var photoURL = urlImage ?? currentUser.value!.urlImage;
    if (phone != null) {
      await sendVerificationCodeToPhoneNumber("+84$phone");
    }
    var phoneNumber = phone ?? currentUser.value!.phoneNumber;
    var newEmail = email ?? currentUser.value!.email;
    var newCoverImage = coverImage ?? currentUser.value!.urlCoverImage;
    print(
        "received value: displayName: $displayName, photoURL: $photoURL, phoneNumber:$phoneNumber, newEmail: $newEmail ");

    userModel.User newUser = userModel.User(
        userStatus: currentUser.value!.userStatus,
        email: newEmail,
        id: currentUser.value!.id,
        name: displayName,
        phoneNumber: phoneNumber,
        story: currentUser.value!.story,
        urlImage: photoURL,
        urlCoverImage: newCoverImage);
    await FirebaseFirestore.instance
        .collection("users")
        .doc(newUser.id)
        .update(newUser.toJson());
    currentUser.value = newUser;
    updateTextController(currentUser); // HERE
    updateUserInAuth(
        email: email, name: name, phone: phone, photoUrl: urlImage); //HERE
  }

  Future updateUserToFirebase(
      {String? email,
      String? phone,
      String? name,
      String? urlImage,
      required String uid,
      String? urlCoverImage}) async {
    String? newEmail = email ?? currentUser.value!.email;
    String? phoneNumber = phone ?? currentUser.value!.phoneNumber;
    String? displayName = name ?? currentUser.value!.name;
    String? urlPhoto = urlImage ?? currentUser.value!.urlImage;
    String? coverImage = urlCoverImage ?? currentUser.value!.urlCoverImage;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      "name": displayName,
      "email": newEmail,
      "phoneNumber": phoneNumber,
      "urlImage": urlPhoto,
      "urlCoverImage": coverImage,
    }).whenComplete(() async {
      await editUser(
          email: newEmail,
          name: displayName,
          phone: phoneNumber,
          coverImage: coverImage,
          urlImage: urlPhoto);
    }).catchError((error) {
      print("Occured an error: $error");
    });
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

  void updatePassword(String newPassword) async {
    User? currentUser = firebaseAuth.currentUser;
    try {
      await currentUser!.updatePassword(newPassword);
      print("Update successfully");
    } catch (e) {
      print(e);
    }
  }
}
