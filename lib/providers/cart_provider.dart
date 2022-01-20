import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:utem_foodie/services/cart_services.dart';

class CartProvider with ChangeNotifier {
  final CartServices _cartServices = CartServices();

  double subTotal = 0.0;
  int cartQty = 0;
  QuerySnapshot? snapshot;
  bool cod = true;
  List cartList = [];
  Future<double?> getCartTotal() async {
    double cartTotal = 0.0;
    List _newList = [];
    QuerySnapshot snapshot = await _cartServices.cart
        .doc(_cartServices.user!.uid)
        .collection('products')
        .get();
    if (snapshot.size == 0) {
      cartQty = snapshot.size;
      notifyListeners();
      return null;
    }

    for (var element in snapshot.docs) {
      if (!_newList.contains(element.data())) {
        _newList.add(element.data());
        cartList = _newList;
      }

      if (element['total'] is num) {
        cartTotal = cartTotal + element['total'];
      } else {
        cartTotal = cartTotal + num.parse(element['total']);
      }
    }
    subTotal = cartTotal;
    cartQty = snapshot.size;
    this.snapshot = snapshot;
    notifyListeners();
    return cartTotal;
  }

  setPaymentMethod(positive) {
    if (positive) {
      cod = false;
    } else {
      cod = true;
    }
    notifyListeners();
  }
}
