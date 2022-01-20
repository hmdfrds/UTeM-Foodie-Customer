import 'package:intl/intl.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:utem_foodie/providers/auth_provider.dart';
import 'package:utem_foodie/providers/cart_provider.dart';
import 'package:utem_foodie/providers/order_provider.dart';
import 'package:utem_foodie/screens/payment/stripe/home.dart';
import 'package:utem_foodie/screens/profile_screen.dart';
import 'package:utem_foodie/services/cart_services.dart';
import 'package:utem_foodie/services/store_services.dart';
import 'package:utem_foodie/services/user_services.dart';
import 'package:utem_foodie/widgets/cart/cart_list.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key, this.document}) : super(key: key);
  static const String id = 'cart-screen';
  final DocumentSnapshot? document;

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final StoreServices _storeServices = StoreServices();
  DocumentSnapshot? doc;
  final UserServices _userServices = UserServices();
  final CartServices _cartServices = CartServices();
  User? user = FirebaseAuth.instance.currentUser;
  final double _deliveryFee = 2;
  bool _checkingUser = false;
  bool positive = false;
  DocumentSnapshot? userDocument;
  String location = '';
  String receiver = '';
  final _formKey = GlobalKey<FormState>();
  var receiverNameController = TextEditingController();
  var locationController = TextEditingController();

  @override
  void initState() {
    _storeServices.getShopDetails(widget.document!['sellerUid']).then((value) {
      setState(() {
        doc = value;
      });
    });

    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      var userDetails = Provider.of<AuthProvider>(context, listen: false);
      userDetails.getUserDetails().then((value) {
        userDocument = value;
        receiver = '${value!['firstName']} ${value['lastName']}';
        location = value['defaultDeliveryLocation'];
      });
      receiver =
          '${userDetails.snapshot!['firstName']} ${userDetails.snapshot!['lastName']}';
      location = userDetails.snapshot!['defaultDeliveryLocation'];
    });
  }

  @override
  Widget build(BuildContext context) {
    var _cartProvider = Provider.of<CartProvider>(context);

    var _payable = _cartProvider.subTotal + _deliveryFee;

    final orderProvider = Provider.of<OrderProvider>(context);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey[300],
        bottomSheet: Container(
          height: 150,
          color: Colors.blueGrey[900],
          child: Column(children: [
            Container(
              height: 100,
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Delivery Info : '),
                        TextButton(
                            onPressed: () {
                              receiverNameController.text = receiver;
                              locationController.text = location;
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('TextField in Dialog'),
                                      content: Form(
                                        key: _formKey,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextFormField(
                                              controller:
                                                  receiverNameController,
                                              keyboardType: TextInputType.name,
                                              decoration: const InputDecoration(
                                                prefixIcon: Icon(Icons.person),
                                                labelText: "Receiver Name",
                                                fillColor: Colors.white,
                                              ),
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return 'Enter Receiver Name';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            TextFormField(
                                              controller: locationController,
                                              keyboardType: TextInputType.name,
                                              decoration: const InputDecoration(
                                                prefixIcon: Icon(
                                                    Icons.location_history),
                                                labelText: "Location",
                                                fillColor: Colors.white,
                                              ),
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return 'Enter Location';
                                                }
                                                return null;
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        FlatButton(
                                          color: Colors.red,
                                          textColor: Colors.white,
                                          child: const Text('CANCEL'),
                                          onPressed: () {
                                            setState(() {
                                              Navigator.pop(context);
                                            });
                                          },
                                        ),
                                        FlatButton(
                                          color: Colors.green,
                                          textColor: Colors.white,
                                          child: const Text('OK'),
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              location =
                                                  locationController.text;
                                              receiver =
                                                  receiverNameController.text;
                                              setState(() {
                                                Navigator.pop(context);
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            },
                            child: const Text(
                              'Change',
                              style: TextStyle(fontSize: 15, color: Colors.red),
                            )),
                      ],
                    ),
                    Text('Receiver : $receiver'),
                    Text('Location : $location'),
                  ],
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'RM${_cartProvider.subTotal.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    RaisedButton(
                      color: Colors.redAccent,
                      onPressed: () {
                        if (location == '') {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            duration: Duration(seconds: 1),
                            content: Text('^   insert location'),
                          ));
                        } else {
                          EasyLoading.show(status: 'Please Wait...');
                          _userServices.getUserById(user!.uid).then((value) {
                            if (value!['firstName'] == '') {
                              EasyLoading.dismiss();
                              setState(() {
                                _checkingUser = false;
                              });
                              pushNewScreenWithRouteSettings(context,
                                  screen: const ProfileScreen(),
                                  settings: const RouteSettings(
                                      name: ProfileScreen.id),
                                  withNavBar: false,
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino);
                            } else {
                              EasyLoading.dismiss();
                              if (_cartProvider.cod == false) {
                                orderProvider.totalAmount(_payable);

                                Navigator.pushNamed(context, StripeHomePage.id)
                                    .whenComplete(() {
                                  if (orderProvider.success) {
                                    _saveOrder(_cartProvider, _payable,
                                        _deliveryFee, orderProvider);
                                  }
                                });
                              } else {
                                _saveOrder(_cartProvider, _payable,
                                    _deliveryFee, orderProvider);
                              }
                          
                            }
                          });
                        }
                      },
                      child: _checkingUser
                          ? const CircularProgressIndicator()
                          : AbsorbPointer(
                              absorbing:
                                  _cartProvider.cartQty != 0 ? true : false,
                              child: const Text(
                                'CHECKOUT',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                    )
                  ],
                ),
              ),
            ),
          ]),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                iconTheme: const IconThemeData(
                  color: Colors.black, //change your color here
                ),
                floating: true,
                snap: true,
                backgroundColor: Colors.white,
                elevation: 0.0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.document!['shopName'],
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Row(
                      children: [
                        Text(
                          '${_cartProvider.cartQty} ${_cartProvider.cartQty > 1 ? 'Items,' : 'Item,'}',
                          style:
                              const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        Text(
                          'To pay RM${_cartProvider.subTotal.toStringAsFixed(0)} ',
                          style:
                              const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ];
          },
          body: _cartProvider.cartQty > 0
              ? SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Column(
                    children: [
                      if (doc != null)
                        ListTile(
                          tileColor: Colors.white,
                          leading: SizedBox(
                            height: 60,
                            width: 60,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  doc!['imageUrl'],
                                  fit: BoxFit.cover,
                                )),
                          ),
                          title: Text(doc!['shopName']),
                        ),
                      Container(
                        color: Colors.white,
                        height: 15,
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        child: Container(
                          color: Colors.white,
                          width: 50,
                          child: Center(
                            child: AnimatedToggleSwitch<bool>.dual(
                              current: positive,
                              innerColor: Colors.white,
                              first: false,
                              second: true,
                              dif: 90.0,
                              indicatorSize: const Size((150), double.infinity),
                              onChanged: (b) => setState(() {
                                positive = b;
                                _cartProvider.setPaymentMethod(positive);
                              }),
                              colorBuilder: (b) =>
                                  b ? Colors.red : Colors.green,
                              iconBuilder: (b, size, active) => b
                                  ? const Icon(
                                      Icons.credit_card,
                                      size: 50,
                                    )
                                  : const Icon(
                                      Icons.monetization_on,
                                      size: 50,
                                    ),
                              textBuilder: (b, size, active) => b
                                  ? const Center(
                                      child: Text(
                                      '               Pay online',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ))
                                  : const Center(
                                      child: Text('Cash on delivery        ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20))),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        height: 15,
                      ),
                      CartList(
                        document: widget.document!,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 4, left: 4, top: 4, bottom: 80),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Bill Details',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Basket value',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      Text(
                                          'RM${_cartProvider.subTotal.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                              color: Colors.grey))
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Delivery Fee',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      Text(
                                          'RM${_deliveryFee.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                              color: Colors.grey))
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Divider(
                                    color: Colors.grey,
                                  ),
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Total amount payable',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Text('RM${_payable.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : const Center(
                  child: Text('Cart Empty, Continue shopping'),
                ),
        ));
  }

  _saveOrder(CartProvider cartProvider, payable, deliveryFee,
      OrderProvider orderProvider) {
    final format = DateFormat('yyyy-MM-dd hh:mm');
    DateTime now = DateTime.now();
    String time = format.format(now);
    Map<String, String> map = {
      'orderStatus': 'Ordered',
      'time': time,
    };
    List orderStatus = [map];
    Map<String, dynamic> data = {
      'receiverName': receiver,
      'location': location,
      'products': cartProvider.cartList,
      'userId': user!.uid,
      'deliveryFee': deliveryFee,
      'total': payable,
      'cod': cartProvider.cod,
      'seller': {
        'shopName': widget.document!['shopName'],
        'sellerId': widget.document!['sellerUid'],
      },
      'timestamp': DateTime.now().toString(),
      'currentOrderStatus': 'Ordered',
      'orderStatus': orderStatus,
      'deliveryBoy': {
        'name': '',
        'phone': '',
        'location': '',
      },
      'rated': false,
    };

    FirebaseFirestore.instance.collection('orders').add(data).then((value) {
      orderProvider.success = false;
      _cartServices.deleteCart().then((value) {
        _cartServices.checkData().then((value) {
          Navigator.pop(context);
          EasyLoading.showSuccess('Your order is submitted');
          cartProvider.cod = true;
        });
      });
    });
  }
}
