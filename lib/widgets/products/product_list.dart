import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utem_foodie/providers/store_provider.dart';
import 'package:utem_foodie/services/product_services.dart';
import 'package:utem_foodie/widgets/products/product_card.widget.dart';

class ProductListWidget extends StatelessWidget {
  const ProductListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _storeProvider = Provider.of<StoreProvider>(context);
    ProductServices _productServices = ProductServices();
    return FutureBuilder<QuerySnapshot>(
      future: _productServices.products
          .where('published', isEqualTo: true)
          .where('category.mainCategory',
              isEqualTo: _storeProvider.selectedCategory)
          .where('category.subCategory',
              isEqualTo: _storeProvider.selectedSubCategory)
          .where('seller.sellerUid',
              isEqualTo: _storeProvider.storeDetails!['uid'])
          .get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong...');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.docs.isEmpty) {
          return Container();
        }
        if (!snapshot.hasData) {
          return Container();
        }
        return Column(children: [
          
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4)),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    '${snapshot.data!.docs.length} Items',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey[600]),
                  ),
                )
              ],
            ),
          ),
          ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: snapshot.data!.docs.map((document) {
              return ProductCard(document: document);
            }).toList(),
          ),
        ]);
      },
    );
  }
}
