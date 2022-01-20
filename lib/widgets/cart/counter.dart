import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:utem_foodie/services/cart_services.dart';

class CounterForCard extends StatefulWidget {
  const CounterForCard({Key? key, required this.documentSnapshot})
      : super(key: key);
  final DocumentSnapshot documentSnapshot;

  @override
  State<CounterForCard> createState() => _CounterForCardState();
}

class _CounterForCardState extends State<CounterForCard> {
  User? user = FirebaseAuth.instance.currentUser;
  final CartServices _cartServices = CartServices();
  int _qty = 1;
  bool exist = false;
  String? _docId;
  bool _updating = false;
  getCardData() {
    FirebaseFirestore.instance
        .collection('cart')
        .doc(user!.uid)
        .collection('products')
        .where('productId', isEqualTo: widget.documentSnapshot['productId'])
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        for (var element in querySnapshot.docs) {
          if (element['productId'] == widget.documentSnapshot['productId']) {
            if (mounted) {
              setState(() {
                _qty = element['qty'];
                _docId = element.id;
                exist = true;
              });
            }
          }
        }
      } else {
        setState(() {
          exist = false;
        });
      }
    });
  }

  @override
  void initState() {
    getCardData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return exist
        ? StreamBuilder(
            stream: getCardData(),
            builder: (context, snapshot) {
              return Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.pink),
                    borderRadius: BorderRadius.circular(4)),
                height: 28,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (_qty == 1) {
                          _cartServices.removeFromCart(_docId).then((value) {
                            setState(() {
                              _updating = false;
                              exist = false;
                            });
                            _cartServices.checkData();
                          });
                        }
                        if (_qty > 1) {
                          setState(() {
                            _updating = true;
                          });
                          setState(() {
                            _qty--;
                          });
                        }
                        var total = _qty *
                            double.parse(widget.documentSnapshot['price']);
                        _cartServices
                            .updateCartQty(_docId, _qty, total)
                            .then((value) {
                          if (mounted) {
                            setState(() {
                              _updating = false;
                            });
                          }
                        });
                      },
                      child:
                          Icon(_qty == 1 ? Icons.delete_outline : Icons.remove),
                    ),
                    Container(
                      height: double.infinity,
                      width: 30,
                      color: Colors.pink,
                      child: Center(
                        child: FittedBox(
                          child: _updating
                              ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                )
                              : Text(
                                  _qty.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _qty++;
                          _updating = true;
                        });
                        var total = _qty *
                            double.parse(widget.documentSnapshot['price']);
                        _cartServices
                            .updateCartQty(_docId, _qty, total)
                            .then((value) {
                          setState(() {
                            _updating = false;
                          });
                        });
                      },
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              );
            },
          )
        : StreamBuilder(
            stream: getCardData(),
            builder: (context, snapshot) {
              return InkWell(
                onTap: () {
                  EasyLoading.show(status: 'Adding to Cart');
                  _cartServices.checkSeller().then((shopName) {
                    if (shopName ==
                        widget.documentSnapshot['seller']['shopName']) {
                      setState(() {
                        exist = true;
                      });
                      _cartServices
                          .addToCart(widget.documentSnapshot)!
                          .then((value) {
                        EasyLoading.showSuccess('Added to Cart');
                      });
                      return;
                    }

                    if (shopName == null) {
                      setState(() {
                        exist = true;
                      });
                      _cartServices
                          .addToCart(widget.documentSnapshot)!
                          .then((value) {
                        EasyLoading.showSuccess('Added to Cart');
                      });
                      return;
                    }
                    if (shopName !=
                        widget.documentSnapshot['seller']['shopName']) {
                      showDialog(shopName);
                      EasyLoading.dismiss();
                    }
                  });
                },
                child: Container(
                  height: 28,
                  decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(4)),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: Text(
                        'Add',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              );
            });
  }

  showDialog(shopName) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Replace Cart item?'),
            content: Text(
                'Your cart contains items from $shopName. Do you want to discard the discard the selection and add items from ${widget.documentSnapshot['seller']['shopName']}'),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'No',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              FlatButton(
                  onPressed: () {
                    _cartServices.deleteCart().then((value) {
                      _cartServices
                          .addToCart(widget.documentSnapshot)!
                          .then((value) {
                        setState(() {
                          exist = true;
                        });
                        Navigator.pop(context);
                      });
                    });
                  },
                  child: const Text(
                    'Yes',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ))
            ],
          );
        });
  }
}
