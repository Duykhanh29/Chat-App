import 'package:chat_app/data/models/friend.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceMethod {
  ServiceMethod();
  static Future<User?> getUserFromIDWithoutGetAllDB(String id) async {
    User? user;
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').doc(id).get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        user = User(
          id: data['id'],
          name: data['name'],
          email: data['email'],
          phoneNumber: data['phoneNumber'],
          story: data['story'],
          urlImage: data['urlImage'],
          userStatus: getUserStatus(data['userStatus']),
        );
      }
    } catch (e) {
      // Xử lý lỗi nếu cần
    }
    return user;
  }

  static Future createFriendForNewUser(User? user) async {
    try {
      Friends friend = Friends(userID: user!.id);
      final snapshot = await FirebaseFirestore.instance
          .collection('friends')
          .doc(user.id)
          .set(friend.toJson());
    } catch (e) {
      print("An error occured: $e");
    }
  }
}
