import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import 'package:stripe_payment/stripe_payment.dart';
import 'package:utem_foodie/providers/order_provider.dart';
import 'package:utem_foodie/services/payment-service.dart';

class ExistingCardsPage extends StatefulWidget {
  const ExistingCardsPage({Key? key}) : super(key: key);
  static const String id = 'existing-cards';

  @override
  ExistingCardsPageState createState() => ExistingCardsPageState();
}

class ExistingCardsPageState extends State<ExistingCardsPage> {
  final StripeService _stripeService = StripeService();
  User? user = FirebaseAuth.instance.currentUser;
  List cards = [
    {
      'cardNumber': '4242424242424242',
      'expiryDate': '04/24',
      'cardHolderName': 'Muhammad Ahsan Ayaz',
      'cvvCode': '424',
      'showBackView': false,
    },
    {
      'cardNumber': '5555555566554444',
      'expiryDate': '04/23',
      'cardHolderName': 'Tracer',
      'cvvCode': '123',
      'showBackView': false,
    }
  ];

  Future<StripeTransactionResponse?> payViaExistingCard(
      BuildContext context, card, amount) async {
    await EasyLoading.show(status: 'Please Wait...');
    var expiryArr = card['expiryDate'].split('/');
    CreditCard stripeCard = CreditCard(
      number: card['cardNumber'],
      expMonth: int.parse(expiryArr[0]),
      expYear: int.parse(expiryArr[1]),
    );
    var response = await StripeService.payViaExistingCard(
        amount: '${amount.toString()}00', currency: 'MYR', card: stripeCard);
    await EasyLoading.dismiss();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(
          content: Text(response!.message),
          duration: const Duration(milliseconds: 5000),
        ))
        .closed
        .then((_) {
      Navigator.pop(context);
      Navigator.pop(context);
    });
    return response;
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    return FutureBuilder<QuerySnapshot>(
      future: _stripeService.card.where('uid', isEqualTo: user!.uid).get(),
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
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.orange,
            ),
            body: const Center(
              child: Text('No Credit Cards added in your account'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.orange,
            title: const Text('Choose existing card'),
          ),
          body: Container(
            padding:
                const EdgeInsets.only(left: 8, right: 8, top: 10, bottom: 10),
            child: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                var card = snapshot.data!.docs[index];
                return InkWell(
                  onTap: () {
                    payViaExistingCard(context, card, orderProvider.amount)
                        .then((response) {
                      if (response!.success) {
                        orderProvider.setPaymentStatus(response.success);
                      }
                    });
                  },
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
          ),
        );
      },
    );
  }
}
