import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class StoreProvider with ChangeNotifier {
  User? user = FirebaseAuth.instance.currentUser;
  DocumentSnapshot? storeDetails;
  String? selectedCategory;
  String? selectedSubCategory;

  String? selectedStoreName;
  String? selectedStoreId;

  getSelectedStore(storeDetails) {
    this.storeDetails = storeDetails;
    notifyListeners();
  }

  setSelectedCategory(selectedCategory) {
    this.selectedCategory = selectedCategory;
    notifyListeners();
  }
   setSelectedSubCategory(selectedSubCategory) {
    this.selectedSubCategory = selectedSubCategory;
    notifyListeners();
  }
}
