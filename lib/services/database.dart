import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Future<QuerySnapshot> Search(String username) async {
  //   return FirebaseFirestore.instance
  //       .collection("users")
  //       .where("searchkey", isEqualTo: username.substring(0, 1).toUpperCase())
  //       .where("username", isGreaterThanOrEqualTo: username.toLowerCase())
  //       .where("username", isLessThan: username.toLowerCase() + 'z')
  //       .limit(10)
  //       .get();
  // }
}
