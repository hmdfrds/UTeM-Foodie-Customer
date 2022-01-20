import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? productName, category, image, shopName, price;
  DocumentSnapshot? document;

  Product(
      {required this.productName,
      required this.category,
      required this.image,
      required this.shopName,
      required this.price,
      required this.document,
      });
}
