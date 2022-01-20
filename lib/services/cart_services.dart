import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartServices {
  CollectionReference cart = FirebaseFirestore.instance.collection('cart');

  User? user = FirebaseAuth.instance.currentUser;

  Future<void>? addToCart(document) {
    cart.doc(user!.uid).set({
      'user': user!.uid,
      'sellerUid': document['seller']['sellerUid'],
      'shopName': document['seller']['shopName'],
    });

    return cart.doc(user!.uid).collection('products').add({
      'productId': document['productId'],
      'productName': document['productName'],
      'productImage': document['productImage'],
      'price': document['price'],
      'qty': 1,
      'total': document['price'],
    });
  }

  Future<void> updateCartQty(docId, qty, total) async {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('cart')
        .doc(user!.uid)
        .collection('products')
        .doc(docId);

    return FirebaseFirestore.instance
        .runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(documentReference);

          if (!snapshot.exists) {
            throw Exception("Product does not exist in cart!");
          }

          // Perform an update on the document
          transaction.update(documentReference, {'qty': qty, 'total': total});

          // Return the new count
          return qty;
        })
        .then((value) => print("Updated Cart"))
        .catchError((error) => print("Failed to update cart: $error"));
  }

  Future<void> removeFromCart(docId) async {
    cart.doc(user!.uid).collection('products').doc(docId).delete();
  }

  Future<void> checkData() async {
    await cart.doc(user!.uid).collection('products').get().then((value) {
      if (value.docs.isEmpty) {
        cart.doc(user!.uid).delete();
      }
    });
  }

  Future<void> deleteCart() async {
    cart.doc(user!.uid).collection('products').get().then((value) {
      value.docs.forEach((element) {
        element.reference.delete();
      });
    });
  }

  Future<String?> checkSeller() async {
    final snapshot = await cart.doc(user!.uid).get();
    return snapshot.exists ? snapshot['shopName'] : null;
  }

  Future<DocumentSnapshot> getShopName() async {
    DocumentSnapshot doc = await cart.doc(user!.uid).get();
    return doc;
  }
}
