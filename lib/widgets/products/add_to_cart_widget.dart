import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:utem_foodie/services/cart_services.dart';
import 'package:utem_foodie/widgets/cart/counter_widget.dart';

class AddToCartWidget extends StatefulWidget {
  const AddToCartWidget({Key? key, required this.documentSnapshot})
      : super(key: key);

  final DocumentSnapshot documentSnapshot;
  @override
  _AddToCartWidgetState createState() => _AddToCartWidgetState();
}

class _AddToCartWidgetState extends State<AddToCartWidget> {
  final CartServices _cartServices = CartServices();
  User? user = FirebaseAuth.instance.currentUser;
  bool _loading = true;
  bool _exist = false;
  int quantity = 1;
  String? _docId;
  @override
  void initState() {
    getCartData();
    super.initState();
  }

  getCartData() async {
    final snapshot =
        await _cartServices.cart.doc(user!.uid).collection('products').get();
    if (snapshot.docs.isEmpty) {
      setState(() {
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore.instance
        .collection('cart')
        .doc(user!.uid)
        .collection('products')
        .where('productId', isEqualTo: widget.documentSnapshot['productId'])
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var element in querySnapshot.docs) {
        if (element['productId'] == widget.documentSnapshot['productId']) {
          setState(() {
            _exist = true;
            quantity = element['qty'];
            _docId = element.id;
          });
        }
      }
    });
    return _loading
        ? SizedBox(
            height: 56,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            ),
          )
        : _exist
            ? CounterWidget(
                documentSnapshot: widget.documentSnapshot,
                qty: quantity,
                docId: _docId!,
              )
            : InkWell(
                onTap: () {
                  EasyLoading.show(status: 'Adding to Cart');
                  FirebaseFirestore.instance
                      .collection('cart')
                      .doc(user!.uid)
                      .collection('products')
                      .where('productId',
                          isEqualTo: widget.documentSnapshot['productId'])
                      .get()
                      .then((QuerySnapshot querySnapshot) {
                    for (var element in querySnapshot.docs) {
                      if (element['productId'] ==
                          widget.documentSnapshot['productId']) {
                        setState(() {
                          _exist = true;
                          quantity = element['qty'];
                          _docId = element.id;
                        });
                      }
                    }
                  });
                  _cartServices
                      .addToCart(widget.documentSnapshot)!
                      .then((value) {
                    setState(() {
                      _exist = true;
                    });
                    EasyLoading.showSuccess('Added to Card');
                  });
                },
                child: Container(
                  height: 56,
                  color: Colors.orange,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            CupertinoIcons.cart,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Add to cart',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
  }
}
