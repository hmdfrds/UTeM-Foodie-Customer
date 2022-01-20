import 'package:chips_choice_null_safety/chips_choice_null_safety.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:utem_foodie/providers/order_provider.dart';
import 'package:utem_foodie/screens/rating_screen.dart';
import 'package:utem_foodie/services/order_services.dart';

import 'package:intl/intl.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({Key? key}) : super(key: key);
  static const String id = 'my-orders-screen';

  @override
  State<MyOrders> createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  final OrderServices _orderServices = OrderServices();
  final format = DateFormat('yyyy-MM-dd hh:mm');
  User? user = FirebaseAuth.instance.currentUser;

  Color? statusColors(DocumentSnapshot document) {
    if (document['currentOrderStatus'] == 'Accepted') {
      return Colors.blueGrey[400];
    }
    if (document['currentOrderStatus'] == 'Rejected') {
      return Colors.red;
    }
    if (document['currentOrderStatus'] == 'Picked Up') {
      return Colors.pink[900];
    }
    if (document['currentOrderStatus'] == 'On The Way') {
      return Colors.purple[900];
    }
    if (document['currentOrderStatus'] == 'Delivered') {
      return Colors.green;
    }
    return Colors.orange;
  }

  Icon statusIcon(DocumentSnapshot document) {
    if (document['currentOrderStatus'] == 'Accepted') {
      return Icon(
        Icons.assignment_turned_in_outlined,
        color: statusColors(document),
      );
    }
    if (document['currentOrderStatus'] == 'Picked Up') {
      return Icon(
        Icons.cases,
        color: statusColors(document),
      );
    }
    if (document['currentOrderStatus'] == 'On The Way') {
      return Icon(
        Icons.delivery_dining,
        color: statusColors(document),
      );
    }
    if (document['currentOrderStatus'] == 'Delivered') {
      return Icon(
        Icons.shopping_bag,
        color: statusColors(document),
      );
    }
    return Icon(
      Icons.assignment_turned_in_outlined,
      color: statusColors(document),
    );
  }

  int tag = 0;
  List<String> options = [
    'All Orders',
    'Ordered',
    'Accepted',
    'Picked Up',
    'On the way',
    'Delivered',
  ];
  @override
  Widget build(BuildContext context) {
    var _orderProvider = Provider.of<OrderProvider>(context);
    if (tag == 0) {
      _orderProvider.status = null;
    }
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.orange,
          centerTitle: true,
          title: const Text(
            'My Orders',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Column(children: [
          SizedBox(
            height: 56,
            width: MediaQuery.of(context).size.width,
            child: ChipsChoice<int>.single(
              value: tag,
              onChanged: (val) => setState(() {
                tag = val;
                if (val > 0) {
                  _orderProvider.filterOrder(options[val]);
                } else {
                  _orderProvider.filterOrder(null);
                }
              }),
              choiceItems: C2Choice.listFrom<int, String>(
                source: options,
                value: (i, v) => i,
                label: (i, v) => v,
              ),
              choiceStyle: const C2ChoiceStyle(
                color: Colors.red,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _orderServices.orders
                .where('userId', isEqualTo: user!.uid)
                .where('currentOrderStatus', isEqualTo: _orderProvider.status)
                .snapshots(),
            builder: (context, snapshot) {
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
                  child: Text('No ${options[tag]} Order.'),
                );
              }

              return Expanded(
                child: ListView(
                  children: snapshot.data!.docs.map((document) {
                    return Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            horizontalTitleGap: 0,
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 14,
                              child: statusIcon(document),
                            ),
                            title: Text(
                              document['currentOrderStatus'],
                              style: TextStyle(
                                  fontSize: 12,
                                  color: statusColors(document),
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'On ${format.format(DateTime.parse(document['timestamp']))}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Payment Type : ${document['cod'] == true ? 'Cash on delivery' : 'Paid Online'}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Amount : RM${document['total'].toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          if (document['deliveryBoy']['name'].length > 2)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  color: Colors.orangeAccent.withOpacity(.3),
                                  child: ExpansionTile(
                                    backgroundColor: Colors.orangeAccent,
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: Image.network(
                                        document['deliveryBoy']['image'],
                                        height: 24,
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Text(
                                          '${document['deliveryBoy']['name']}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          'On ${format.format(DateTime.parse(document['timestamp']))}',
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                    subtitle: Text(
                                      _orderServices.statusComment(document),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    children: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, i) {
                                          int index =
                                              document['orderStatus'].length -
                                                  i -
                                                  1;
                                          return document[
                                                      'currentOrderStatus'] ==
                                                  document['orderStatus'][index]
                                                      ['orderStatus']
                                              ? Container()
                                              : ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    child: Image.network(
                                                      document['deliveryBoy']
                                                          ['image'],
                                                      height: 24,
                                                    ),
                                                  ),
                                                  title: Text(
                                                    '${document['deliveryBoy']['name']}',
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                  subtitle: Text(
                                                    _orderServices
                                                        .statusCommentInsideList(
                                                            document,
                                                            document['orderStatus']
                                                                    [index][
                                                                'orderStatus']),
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                  trailing: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        'On ${document['orderStatus'][index]['time'].toString()}',
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      )
                                                    ],
                                                  ),
                                                );
                                        },
                                        itemCount:
                                            document['orderStatus'].length - 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ExpansionTile(
                            title: const Text(
                              'Order details',
                              style:
                                  TextStyle(fontSize: 10, color: Colors.black),
                            ),
                            subtitle: const Text(
                              'View order details',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black26),
                            ),
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, i) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Image.network(document['products']
                                          [i]['productImage']),
                                      backgroundColor: Colors.white,
                                    ),
                                    title: Text(
                                      document['products'][i]['productName'],
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    subtitle: Text(
                                      '${document['products'][i]['qty']} x ${document['products'][i]['price']} = ${document['products'][i]['total']}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                },
                                itemCount: document['products'].length,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 12, right: 12, top: 8, bottom: 8),
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              'Seller : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              document['seller']['shopName'],
                                              style: const TextStyle(
                                                  color: Colors.grey),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Text(
                                              'Receiver : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              '${document['receiverName']}',
                                              style: const TextStyle(
                                                  color: Colors.grey),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Text(
                                              'Location : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              '${document['location']}',
                                              style: const TextStyle(
                                                  color: Colors.grey),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Text(
                                              'Delivery Fee : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'RM${document['deliveryFee']}',
                                              style: const TextStyle(
                                                  color: Colors.grey),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            height: 3,
                            color: Colors.grey,
                          ),
                          statusContainer(document, context),
                          const Divider(
                            height: 3,
                            thickness: 3,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ]));
  }

  Widget statusContainer(DocumentSnapshot document, context) {
    if (document['currentOrderStatus'] == 'Delivered' && !document['rated']) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.grey[300],
          height: 50,
          child: FlatButton(
            onPressed: () {
              pushNewScreenWithRouteSettings(
                context,
                settings: const RouteSettings(name: RatingScreen.id),
                screen: RatingScreen(
                  document: document,
                ),
                withNavBar: false,
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            },
            color: statusColors(document),
            child: const Text(
              'Rate',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
      );
    }

    return Container();
  }

  List justRotate(List someArray) {
    var x;
    var i;
    x = someArray.length;
    for (i = (someArray.length - 1); i > 0; i--) {
      someArray[i] = someArray[i - 1];
    }
    someArray[0] = x;
    return someArray;
  }
}
