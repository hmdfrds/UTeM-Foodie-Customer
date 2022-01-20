import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:utem_foodie/providers/store_provider.dart';
import 'package:utem_foodie/screens/vendor_home_screen.dart';
import 'package:utem_foodie/services/store_services.dart';

class TopPickStore extends StatelessWidget {
  final StoreServices _storeServices = StoreServices();
  @override
  Widget build(BuildContext context) {
    final _storeData = Provider.of<StoreProvider>(context);
    return StreamBuilder<QuerySnapshot>(
      stream: _storeServices.getTopPickedStore(),
      builder: (context, AsyncSnapshot<QuerySnapshot>? snapshot) {
        if (!snapshot!.hasData) return const CircularProgressIndicator();

        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color: Colors.amber,
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Top Picked Stores',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Flexible(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: snapshot.data!.docs.map((document) {
                      return InkWell(
                        onTap: () {
                          _storeData.getSelectedStore(document);
                          pushNewScreenWithRouteSettings(
                            context,
                            settings:
                                const RouteSettings(name: VendorHomeScreen.id),
                            screen: const VendorHomeScreen(),
                            withNavBar: true,
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            // color: Colors.red,
                            width: 80,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 80.0,
                                  width: 80.0,
                                  child: Card(
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(4.0),
                                      child: Image.network(
                                          (document.data()
                                              as Map)['imageUrl'],
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 35,
                                  child: Text(
                                    document['shopName'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
