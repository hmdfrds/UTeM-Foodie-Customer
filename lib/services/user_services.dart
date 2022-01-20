import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utem_foodie/models/user_model.dart';

class UserServices {
  String collection = 'users';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // create user data
  Future<void> createUserData(Map<String, dynamic> values) async {
    String id = values['id'];
    await _firestore.collection(collection).doc(id).set(values);
  }

  // update user data
  Future<void> updateUserData(Map<String, dynamic> values) async {
    String id = values['id'];
    await _firestore.collection(collection).doc(id).update(values);
  }

  // get user data by user id
  Future<DocumentSnapshot?> getUserById(String id) async {
    return await _firestore.collection(collection).doc(id).get().then((doc) {
      if (doc['id'] != null) {
        print('data not null');
        UserModel.fromSnapshot(doc);
        return doc;
      } else {
        print('data is null');
        return null;
      }
    });
  }
}
