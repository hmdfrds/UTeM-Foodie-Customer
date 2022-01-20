import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:utem_foodie/services/cart_services.dart';
import 'package:utem_foodie/widgets/cart/cart_card.dart';

class CartList extends StatefulWidget {
  const CartList({Key? key, required this.document}) : super(key: key);
  final DocumentSnapshot document;

  @override
  _CartListState createState() => _CartListState();
}

class _CartListState extends State<CartList> {
  final CartServices _cartServices = CartServices();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: _cartServices.cart
            .doc(_cartServices.user!.uid)
            .collection('products')
            .get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
     
          if (snapshot.hasError) {
            return const Text('something went wrong');
          }
          if (!snapshot.hasData) {
            return Container();
          }
          if (snapshot.hasData) {
            return ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: snapshot.data!.docs.map((DocumentSnapshot e) {
                return CartCard(
                  document: e,
                );
              }).toList(),
            );
          }

          return Container();
        });
  }
}
