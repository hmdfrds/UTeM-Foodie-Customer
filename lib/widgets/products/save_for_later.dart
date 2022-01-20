import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class SaveForLater extends StatefulWidget {
  const SaveForLater({Key? key, required this.documentSnapshot})
      : super(key: key);
  final DocumentSnapshot documentSnapshot;

  @override
  State<SaveForLater> createState() => _SaveForLaterState();
}

class _SaveForLaterState extends State<SaveForLater> {
  CollectionReference favourites =
      FirebaseFirestore.instance.collection('favourites');
  User? user = FirebaseAuth.instance.currentUser;
  bool exist = false;
  String? favoriteId;

  @override
  void initState() {
    favourites
        .where('customerId', isEqualTo: user!.uid)
        .where('product.productId',
            isEqualTo: widget.documentSnapshot['productId'])
        .get()
        .then((value) {
      print(value.size);
      if (value.size > 0) {
        setState(() {
          favoriteId = value.docs.first.id;
          exist = true;
        });
      } else {
        setState(() {
          exist = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (exist) {
          EasyLoading.show(status: 'Removing...');
          removeFromFavoriet(favoriteId!).then((value) {
            EasyLoading.showSuccess('Removed succesfully');
            exist = !exist;
            setState(() {});
          });
        } else {
          EasyLoading.show(status: 'Saving...');
          saveForLater()!.then((value) {
            EasyLoading.showSuccess('Saved succesfully');
            exist = !exist;
            favoriteId = value.id;
            setState(() {});
          });
        }
      },
      child: Container(
        height: 56,
        color: Colors.grey[800],
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.bookmark,
                  color: Colors.white,
                ),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: Text(
                    exist ? 'Remove from favourite' : 'Save to favourite',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<DocumentReference>? saveForLater() {
    CollectionReference _favourite =
        FirebaseFirestore.instance.collection('favourites');
    User? user = FirebaseAuth.instance.currentUser;
    return _favourite.add({
      'product': widget.documentSnapshot.data(),
      'customerId': user!.uid,
    });
  }

  Future<void> removeFromFavoriet(String id) {
    return favourites.doc(id).delete();
  }
}
