import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:utem_foodie/screens/payment/create_new_card_screen.dart';
import 'package:utem_foodie/services/payment-service.dart';

class CreditCardList extends StatefulWidget {
  const CreditCardList({Key? key}) : super(key: key);
  static const String id = 'credit-card-list';

  @override
  _CreditCardListState createState() => _CreditCardListState();
}

class _CreditCardListState extends State<CreditCardList> {
  final StripeService _stripeService = StripeService();
  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          actions: [
            IconButton(
                onPressed: () {
                  pushNewScreenWithRouteSettings(
                    context,
                    settings: const RouteSettings(name: CreateNewCreditCard.id),
                    screen: const CreateNewCreditCard(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
                icon: const Icon(
                  Icons.add_circle_rounded,
                  color: Colors.white,
                ))
          ],
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          title: const Text(
            'Manage Cards',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _stripeService.card
              .where('uid', isEqualTo: user!.uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.data!.size == 0) {
              return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('No Credit Cards added in your account'),
                  const Divider(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        pushNewScreenWithRouteSettings(
                          context,
                          settings:
                              const RouteSettings(name: CreateNewCreditCard.id),
                          screen: const CreateNewCreditCard(),
                          withNavBar: false,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                      style: ElevatedButton.styleFrom(primary: Colors.orange),
                      child: const Text(
                        'Add Card',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ))
                ]),
              );
            }

            return Container(
              padding:
                  const EdgeInsets.only(left: 8, right: 8, top: 10, bottom: 10),
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  var card = snapshot.data!.docs[index];
                  print(card.data().toString());
                  return Slidable(
                    key: const ValueKey(0),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            EasyLoading.show(status: 'Please Wait...');
                            _stripeService
                                .deleteCreditCard(card.id)
                                .whenComplete(() {
                              EasyLoading.dismiss();
                            });
                          },
                          backgroundColor: const Color(0xFFFE4A49),
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: CreditCardWidget(
                      isHolderNameVisible: true,
                      cardNumber: card['cardNumber'],
                      expiryDate: card['expiryDate'],
                      cardHolderName: card['cardHolderName'],
                      cvvCode: card['cvvCode'],
                      showBackView: false,
                      onCreditCardWidgetChange: (CreditCardBrand) {},
                    ),
                  );
                },
              ),
            );
          },
        ));
  }
}
