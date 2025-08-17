import 'package:chat/services/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';

class DatabaseMethod {
  Future adduserdetails(Map<String, dynamic> userinfoMap, String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(userinfoMap);
      return null; // Return null if successful
    } catch (e) {
      return e.toString(); // Return error message if an error occurs
    }
  }

  Future<QuerySnapshot> getuserbyemail(String email) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      print("Firestore data: ${querySnapshot.docs.first.data()}");
      return querySnapshot;
    } catch (e) {
      print("Firestore error: $e");
      throw e; // Re-throw to trigger your catch block
    }
  }

  Future<QuerySnapshot> Search(String username) async {
    return FirebaseFirestore.instance
        .collection("users")
        .orderBy("username")
        .startAt([username.toLowerCase()])
        .endAt([username.toLowerCase() + '\uf8ff'])
        .limit(10)
        .get();
  }

  createChatRoom(
    String chatRoomId,
    Map<String, dynamic> chatRoomInfoMap,
  ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomId)
        .get();
    if (snapshot.exists) {
      return true;
    } else {
      return FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
    }
  }

  // Future<QuerySnapshot> Search(String username) async {
  //   return FirebaseFirestore.instance
  //       .collection("users")
  //       .where("searchkey", isEqualTo: username.substring(0, 1).toUpperCase())
  //       .where("username", isGreaterThanOrEqualTo: username.toLowerCase())
  //       .where("username", isLessThan: username.toLowerCase() + 'z')
  //       .limit(10)
  //       .get();
  // }
  Future addMessage(
    String messageId,
    String chatRoomId,
    Map<String, dynamic> messageInfoMap,
  ) async {
    return await FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
  }

  updateLastMessageSend(
    String chatRoomId,

    Map<String, dynamic> lastmessageInfoMap,
  ) async {
    return await FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomId)
        .update(lastmessageInfoMap);
  }

  // Inside DatabaseMethod class:
  Stream<QuerySnapshot> getmessages(String chatRoomId) {
    return FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("time", descending: true)
        .snapshots(); // Must be .snapshots(), not .get()
  }

  Future<QuerySnapshot> getthisuserinfo(String username) async {
    return FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: username.toLowerCase())
        .get();
  }

  Future<Stream<QuerySnapshot>> getChatRooms(String chatRoomId) async {
    String? myUsername = await SharedPreferenceHelper().getUserName();
    print("Fetching chatroom for: ${myUsername}");
    return FirebaseFirestore.instance
        .collection("chatRooms")
        .where("users", arrayContains: myUsername)
        .orderBy("lastmesssageSendts", descending: true)
        .snapshots();
  }

  // Future<Stream<QuerySnapshot>> getmessages(String chatRoomId) async {
  //   return FirebaseFirestore.instance
  //       .collection("chatroom")
  //       .doc("chatRoomId")
  //       .collection("chats")
  //       .orderBy("time", descending: true)
  //       .snapshots();
  // }
}
