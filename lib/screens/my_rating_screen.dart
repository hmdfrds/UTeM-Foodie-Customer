import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MyRatingScreen extends StatelessWidget {
  MyRatingScreen({Key? key}) : super(key: key);
  static const String id = 'my-rating-screen';
  CollectionReference ratings =
      FirebaseFirestore.instance.collection('ratings');
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        centerTitle: true,
        title: const Text('My Rating & Reviews'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ratings.where('userId', isEqualTo: user!.uid).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data!.size == 0) {
            return const Text('No Rating & Reviews');
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return Column(children: [
                const Divider(
                  height: 0,
                  thickness: 2,
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Id : ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        data['orderId'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RatingBar.builder(
                            initialRating: data['rating'],
                            minRating: 1,
                            itemSize: 20,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            ignoreGestures: true,
                            itemCount: 5,
                            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {},
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text('${data['rating']}'),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      data['comment'] == null
                          ? Container()
                          : Row(
                              children: [
                                const Text(
                                  'Comment : ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Text(
                                      '${data['comment']}',
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                )
                              ],
                            ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text('${data['time']}'),
                    ],
                  ),
                ),
                const Divider(
                  height: 0,
                  thickness: 2,
                ),
              ]);
            }).toList(),
          );
        },
      ),
    );
  }
}
