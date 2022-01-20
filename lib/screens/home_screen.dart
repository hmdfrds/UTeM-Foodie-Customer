// ignore_for_file: prefer_const_constructors, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utem_foodie/providers/auth_provider.dart';
import 'package:utem_foodie/screens/top_store.dart';
import 'package:utem_foodie/services/product_services.dart';
import 'package:utem_foodie/widgets/image_slider.dart';

import 'package:utem_foodie/widgets/my_appbar.dart';
import 'package:utem_foodie/widgets/products/product_card.widget.dart';

class HomeScreen extends StatelessWidget {
  static const String id = 'home-screen';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    ProductServices _productServices = ProductServices();

    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [MyAppBar()];
          },
          body: ListView(
            children: [
              ImageSlider(),
              SizedBox(height: 160, child: TopPickStore()),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FutureBuilder<QuerySnapshot>(
                    future: _productServices.products
                        .where('published', isEqualTo: true)
                        .get(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong...');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text('No Food Available'),
                        );
                      }
                      if (!snapshot.hasData) {
                        return Center(
                          child: Text('No Food Available'),
                        );
                      }

                      return Column(children: [
                        Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4)),
                          child: Center(
                              child: Text(
                            'Featured Food',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          )),
                        ),
                        ListView(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: snapshot.data!.docs.map((document) {
                            return ProductCard(document: document);
                          }).toList(),
                        ),
                      ]);
                    },
                  )
                ],
              )
            ],
          )),
    );
  }
}
