import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

class RatingScreen extends StatefulWidget {
  RatingScreen({Key? key, this.document}) : super(key: key);
  DocumentSnapshot? document;
  static const String id = 'rating-screen';

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final _commentTextController = TextEditingController();
  CollectionReference ratings =
      FirebaseFirestore.instance.collection('ratings');
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');
  User? user = FirebaseAuth.instance.currentUser;
  double _rating = 3;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'Rate This Order',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              const SizedBox(height: 20.0),
              Text(
                'Rating: $_rating',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                keyboardType: TextInputType.multiline,
                controller: _commentTextController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.comment),
                  labelText: "Comment",
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: const BorderSide(),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        EasyLoading.show(status: 'Please Wait...');
                        final format = DateFormat('yyyy-MM-dd hh:mm');
                        DateTime now = DateTime.now();
                        String time = format.format(now);
                        ratings.add({
                          'rating': _rating,
                          'comment': _commentTextController.text,
                          'sellerId': widget.document!['seller']['sellerId'],
                          'userId': widget.document!['userId'],
                          'orderId': widget.document!.id,
                          'time': time,
                        }).then((value) {
                          orders.doc(widget.document!.id).update({
                            'rated': true,
                          }).then((value) {
                            EasyLoading.dismiss();

                            Navigator.of(context).pop();
                          });
                        });
                      },
                      child: const Text(
                        'Submit',
                        style: TextStyle(fontSize: 15),
                      ),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.deepOrange),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: const BorderSide(color: Colors.red))),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
