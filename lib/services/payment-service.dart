import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_payment/stripe_payment.dart';
import 'package:utem_foodie/services/cart_services.dart';

class StripeTransactionResponse {
  String message;
  bool success;
  StripeTransactionResponse({required this.message, required this.success});
}

class StripeService {
  CollectionReference card = FirebaseFirestore.instance.collection('cards');
  User? user = FirebaseAuth.instance.currentUser;
  
  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
  static String secret =
      'SECRET KEY LETAK SINI';
  static Map<String, String> headers = {
    'Authorization': 'Bearer ${StripeService.secret}',
    'Content-Type': 'application/x-www-form-urlencoded'
  };
  static init() {
    StripePayment.setOptions(StripeOptions(
        publishableKey:
            "PUBLIC KEY LETAK SINI",
        merchantId: "Test",
        androidPayMode: 'test'));
  }

  static Future<StripeTransactionResponse?> payViaExistingCard(
      {required String amount,
      required String currency,
      required CreditCard card}) async {
    StripeTransactionResponse? stripeTransactionResponse;
    try {
      var paymentMethod = await StripePayment.createPaymentMethod(
          PaymentMethodRequest(card: card));
      var paymentIntent =
          await StripeService.createPaymentIntent(amount, currency);
      var response = await StripePayment.confirmPaymentIntent(PaymentIntent(
          clientSecret: paymentIntent!['client_secret'],
          paymentMethodId: paymentMethod.id));
      if (response.status == 'succeeded') {
        stripeTransactionResponse = StripeTransactionResponse(
            message: 'Transaction successful', success: true);
      } else {
        stripeTransactionResponse = StripeTransactionResponse(
            message: 'Transaction failed, invalid credit card', success: false);
      }
    } on PlatformException catch (err) {
      stripeTransactionResponse =
          StripeService.getPlatformExceptionErrorResult(err);
    } catch (err) {
      stripeTransactionResponse = StripeTransactionResponse(
          message: 'Transaction failed: ${err.toString()}', success: false);
    }
    return stripeTransactionResponse;
  }

  static Future<StripeTransactionResponse?> payWithNewCard(
      {required String amount, required String currency}) async {
    StripeTransactionResponse? stripeTransactionResponse;
    try {
      var paymentMethod = await StripePayment.paymentRequestWithCardForm(
          CardFormPaymentRequest());
      var paymentIntent =
          await StripeService.createPaymentIntent(amount, currency);
      var response = await StripePayment.confirmPaymentIntent(PaymentIntent(
          clientSecret: paymentIntent!['client_secret'],
          paymentMethodId: paymentMethod.id));
      if (response.status == 'succeeded') {
        stripeTransactionResponse = StripeTransactionResponse(
            message: 'Transaction successful', success: true);
       
      } else {
        stripeTransactionResponse = StripeTransactionResponse(
            message: 'Transaction failed, invalid credit card', success: false);
      }
    } on PlatformException catch (err) {
      stripeTransactionResponse =
          StripeService.getPlatformExceptionErrorResult(err);
    } catch (err) {
      stripeTransactionResponse = StripeTransactionResponse(
          message: 'Transaction failed: ${err.toString()}', success: false);
    }
    return stripeTransactionResponse;
  }

  static getPlatformExceptionErrorResult(PlatformException err) {
    String message = 'Something went wrong';
    if (err.message != null) {
      message = err.message!;
    }
    if (err.code == 'cancelled') {
      message = 'Transaction cancelled';
    }

    return StripeTransactionResponse(message: message, success: false);
  }

  static Future<Map<String, dynamic>?> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      var response = await http.post(Uri.parse(StripeService.paymentApiUrl),
          body: body, headers: StripeService.headers);
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
    return null;
  }

  Future<void> saveCreditCard(Map<String, dynamic> values) async {
    await card.add(values);
  }

  Future<void> deleteCreditCard(id) async {
    await card.doc(id).delete();
  }
}
