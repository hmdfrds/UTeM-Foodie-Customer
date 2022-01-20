import 'package:flutter/material.dart';
import 'package:utem_foodie/widgets/category_widget.dart';
import 'package:utem_foodie/widgets/products/best_selling_product.dart';
import 'package:utem_foodie/widgets/products/featured_products.dart';
import 'package:utem_foodie/widgets/products/recently_added_products.dart';
import 'package:utem_foodie/widgets/vendor_appbar.dart';
import 'package:utem_foodie/widgets/vendor_banner.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({Key? key}) : super(key: key);
  static const String id = 'vendor-home-screen';

  @override
  _VendorHomeScreenState createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
      headerSliverBuilder: (context, bool innerBoxIsScrolled) {
        return [
          const VendorAppBar(),
        ];
      },
      body: ListView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: const [
          VendorBanner(),
          VendorCategories(),
          RecentlyAdded(),
          FeaturedProducts(),
          BestSellingProduct(),
          SizedBox(
            height: 45,
          ),
        ],
      ),
    ));
  }
}
