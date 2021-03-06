import 'package:cloud_firestore/cloud_firestore.dart';

class DbFunctions {
  final _firestore = FirebaseFirestore.instance;

  Future getSliderImage() async {
    QuerySnapshot snapshot = await _firestore.collection("slider").get();
    return snapshot.docs;
  }
}
