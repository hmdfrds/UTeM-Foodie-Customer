import 'package:flutter/cupertino.dart';

class OrderProvider with ChangeNotifier {
  String? status = "";
  String? amount = '';
  bool success = false;

  filterOrder(status) {
    this.status = status;
    notifyListeners();
  }

  totalAmount(double amount) {
    this.amount = amount.toStringAsFixed(0);
    notifyListeners();
  }

  setPaymentStatus(status) {
    success = status;
    notifyListeners();
  }
}
