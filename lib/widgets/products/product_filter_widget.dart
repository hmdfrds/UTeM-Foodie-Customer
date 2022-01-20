import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utem_foodie/providers/store_provider.dart';
import 'package:utem_foodie/services/product_services.dart';

class ProductFilterWidget extends StatefulWidget {
  const ProductFilterWidget({Key? key}) : super(key: key);

  @override
  _ProductFilterWidgetState createState() => _ProductFilterWidgetState();
}

class _ProductFilterWidgetState extends State<ProductFilterWidget> {
  final List _subCatList = [];
  final ProductServices _productServices = ProductServices();
  @override
  void didChangeDependencies() {
    var _store = Provider.of<StoreProvider>(context);
    _subCatList.clear();
    FirebaseFirestore.instance
        .collection('products')
        .where('published', isEqualTo: true)
        .where('seller.sellerUid', isEqualTo: _store.storeDetails!.id)
        .where('category.mainCategory', isEqualTo: _store.selectedCategory)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var element in querySnapshot.docs) {
        setState(() {
          _subCatList.add(element['category']['subCategory']);
        });
      }
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var _storeData = Provider.of<StoreProvider>(context);
    return FutureBuilder<DocumentSnapshot>(
        future:
            _productServices.category.doc(_storeData.selectedCategory).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something Went Wrong'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData) {
            return Container();
          }
   
          Map<dynamic, dynamic> data = snapshot.data!.data() as Map;
   
          return Container(
              height: 50,
              color: Colors.grey,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  ActionChip(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    label: const Text('All'),
                    onPressed: () {
                      _storeData.setSelectedSubCategory(null);
                    },
                    backgroundColor: Colors.white,
                  ),
                  ListView.builder(
                    itemCount: data['subCat'].length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return _subCatList.contains(data['subCat'][index]['name'])
                          ? Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: ActionChip(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                                label: Text(data['subCat'][index]['name']),
                                onPressed: () {
                                  _storeData.setSelectedSubCategory(
                                      data['subCat'][index]['name']);
                                },
                                backgroundColor: Colors.white,
                              ))
                          : Container();
                    },
                  )
                ],
              ));
        });
  }
}
