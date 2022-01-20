import 'package:cloud_firestore/cloud_firestore.dart';

class StoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String collection = "vendors";
  CollectionReference vendorBanner =
      FirebaseFirestore.instance.collection('vendorbanner');
  CollectionReference vendors =
      FirebaseFirestore.instance.collection('vendors');

  Stream<QuerySnapshot> getTopPickedStore() {
    return _firestore
        .collection(collection)
        .where("accVerified", isEqualTo: true)
        .where("isTopPicked", isEqualTo: true)
        .orderBy("shopName")
        .snapshots();
  }

  Future<DocumentSnapshot> getShopDetails(sellerUid) async {
    DocumentSnapshot snapshot = await vendors.doc(sellerUid).get();
    return snapshot;
  }
}
