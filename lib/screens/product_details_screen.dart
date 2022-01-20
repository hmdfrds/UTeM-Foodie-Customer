// ignore_for_file: unnecessary_const

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_text/expandable_text.dart';

import 'package:flutter/material.dart';
import 'package:utem_foodie/widgets/bottom_sheet_container.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({Key? key, this.documentSnapshot})
      : super(key: key);
  static const String id = 'product-details-screen';
  final DocumentSnapshot? documentSnapshot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Menu Detail'),
        centerTitle: true,
      ),
      bottomSheet: BotttomSheetContainer(
        documentSnapshot: documentSnapshot!,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const Icon(Icons.fastfood_outlined),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  documentSnapshot!['productName'],
                  style: const TextStyle(fontSize: 22),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 35,
                ),
                Text(
                  'RM${documentSnapshot!['price']}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Hero(
                  tag: 'product${documentSnapshot!['productName']}',
                  child: Image.network(documentSnapshot!['productImage'])),
            ),
            Divider(
              color: Colors.grey[400],
              thickness: 6,
            ),
            Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Row(
                  children: const [
                    Icon(Icons.description),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'About this product',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                )),
            Divider(
              color: Colors.grey[400],
            ),
            Padding(
              padding:
                  const EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
              child: ExpandableText(
                documentSnapshot!['description'],
                expandText: 'View more',
                collapseText: 'View less',
                maxLines: 2,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            Divider(
              color: Colors.grey[400],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              child: const Text(
                'Other product info',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            Divider(
              color: Colors.grey[400],
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
              child: Text(
                'Seller : ${documentSnapshot!['seller']['shopName']}',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(
              height: 60,
            )
          ],
        ),
      ),
    );
  }
}
