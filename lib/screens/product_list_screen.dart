import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utem_foodie/providers/store_provider.dart';
import 'package:utem_foodie/widgets/products/product_filter_widget.dart';
import 'package:utem_foodie/widgets/products/product_list.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({Key? key}) : super(key: key);
  static const String id = 'product-list-screen';

  @override
  Widget build(BuildContext context) {
    final _storeProvider = Provider.of<StoreProvider>(context);
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.orange,
              floating: true,
              snap: true,
              title: Text(
                _storeProvider.selectedCategory!,
                style: const TextStyle(color: Colors.white),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              expandedHeight: 110,
              flexibleSpace: Padding(
                padding: const EdgeInsets.only(top: 88),
                child: Container(
                  height: 56,
                  color: Colors.grey,
                  child: const ProductFilterWidget(),
                ),
              ),
            )
          ];
        },
        body: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: const [ProductListWidget()]),
      ),
    );
  }
}
