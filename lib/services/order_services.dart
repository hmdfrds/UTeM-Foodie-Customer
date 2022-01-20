import 'package:cloud_firestore/cloud_firestore.dart';

class OrderServices {
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');

  Future<DocumentReference> saveOrder(Map<String, dynamic> data) {
    var result = orders.add({
      data,
    });
    return result;
  }

  Future<void> saveOrder1(data) {
    return orders
        .add({
          {
            'full_name': 'fullName', // John Doe
            'company': 'company', // Stokes and Sons
            'age': 'age' // 42
          }
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  String statusComment(document) {
    if (document['currentOrderStatus'] == "Picked Up") {
      return 'Your order is Picked by ${document['deliveryBoy']['name']}';
    }
    if (document['currentOrderStatus'] == "On The Way") {
      return 'Your delivery person ${document['deliveryBoy']['name']} is on the way';
    }
    if (document['currentOrderStatus'] == "Delivered") {
      return 'Your order is now Complete';
    }

    return 'Mr. ${document['deliveryBoy']['name']} is on the way to Pick your Order';
  }

  String statusCommentInsideList(document, status) {
    print(status);
    if (status == "Picked Up") {
      return 'Your order is Picked by ${document['deliveryBoy']['name']}';
    }
    if (status == "On The Way") {
      return 'Your delivery person ${document['deliveryBoy']['name']} is on the way';
    }
    if (status == "Delivered") {
      return 'Your order is now Complete';
    }

    return 'Mr. ${document['deliveryBoy']['name']} is on the way to Pick your Order';
  }
}
