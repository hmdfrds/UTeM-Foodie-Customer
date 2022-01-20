import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utem_foodie/providers/store_provider.dart';

class VendorBanner extends StatefulWidget {
  const VendorBanner({Key? key}) : super(key: key);

  @override
  _VendorBannerState createState() => _VendorBannerState();
}

class _VendorBannerState extends State<VendorBanner> {
  int _index = 0;
  int _dataLength = 1;

  @override
  void didChangeDependencies() {
    var _storeProvider = Provider.of<StoreProvider>(context);
    getVendorBannerFromDb(_storeProvider);
    super.didChangeDependencies();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getVendorBannerFromDb(StoreProvider storeProvider) async {
    var _fireStore = FirebaseFirestore.instance;
    QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection('vendorbanner')
        .where("sellerUid", isEqualTo: storeProvider.storeDetails!['uid'])
        .get();
    if (mounted) {
      setState(() {
        _dataLength = snapshot.docs.length;
      });
    }
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    var _storeProvider = Provider.of<StoreProvider>(context);
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          if (_dataLength != 0)
            FutureBuilder(
              future: getVendorBannerFromDb(_storeProvider),
              builder: (_,
                  AsyncSnapshot<
                          List<QueryDocumentSnapshot<Map<String, dynamic>>>>
                      snapShot) {
                return snapShot.data == null
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: CarouselSlider.builder(
                            itemCount: _dataLength,
                            itemBuilder: (context, index, currentIndex) {
                              DocumentSnapshot<Map<String, dynamic>>?
                                  sliderImage;
                              if (snapShot.hasData) {
                                sliderImage = snapShot.data![index];
                              }

                              Map<String, dynamic>? getImage =
                                  sliderImage!.data();
                              return SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Image.network(
                                    getImage!['imageUrl'],
                                    fit: BoxFit.fill,
                                  ));
                            },
                            options: CarouselOptions(
                                viewportFraction: 1,
                                initialPage: 0,
                                autoPlay: true,
                                height: 180,
                                onPageChanged:
                                    (int i, carouselPageChangedReason) {
                                  setState(() {
                                    _index = i;
                                  });
                                })),
                      );
              },
            ),
          if (_dataLength != 0)
            DotsIndicator(
              dotsCount: _dataLength,
              position: _index.toDouble(),
              decorator: DotsDecorator(
                  size: const Size.square(5.0),
                  activeSize: const Size(18.0, 5.0),
                  activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  activeColor: Theme.of(context).primaryColor),
            )
        ],
      ),
    );
  }
}
