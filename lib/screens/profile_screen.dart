import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:utem_foodie/providers/auth_provider.dart';
import 'package:utem_foodie/screens/blank_screen.dart';
import 'package:utem_foodie/screens/my_orders_screen.dart';
import 'package:utem_foodie/screens/my_rating_screen.dart';
import 'package:utem_foodie/screens/payment/credit_card_ilst.dart';
import 'package:utem_foodie/screens/profile_update_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  static const String id = 'profile-screen';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    var userDetails = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0.0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Column(children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'MY ACCOUNT',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Stack(children: [
            Container(
              color: Colors.redAccent,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          userDetails.snapshot != null &&
                                  userDetails.snapshot!['firstName'] != ''
                              ? '${userDetails.snapshot!['firstName'][0]}'
                              : '',
                          style: const TextStyle(
                              fontSize: 50, color: Colors.white),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        height: 70,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userDetails.snapshot != null &&
                                      userDetails.snapshot!['firstName'] != ''
                                  ? '${userDetails.snapshot!['firstName']} ${userDetails.snapshot!['lastName']}'
                                  : 'Update Your Name',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white),
                            ),
                            if (userDetails.snapshot != null &&
                                userDetails.snapshot!['email'] != null)
                              Text(
                                userDetails.snapshot!['email'],
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                            Text(
                              userDetails.snapshot != null
                                  ? userDetails.snapshot!['number']
                                  : '',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ]),
              ),
            ),
            Positioned(
                right: 10.0,
                child: IconButton(
                  onPressed: () {
                    pushNewScreenWithRouteSettings(
                      context,
                      settings: const RouteSettings(name: UpdateProfile.id),
                      screen: const UpdateProfile(),
                      withNavBar: false,
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                  ),
                ))
          ]),
          const Divider(),
          ListTile(
            onTap: () {
              pushNewScreenWithRouteSettings(
                context,
                settings: const RouteSettings(name: MyOrders.id),
                screen: const MyOrders(),
                withNavBar: false,
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            },
            leading: const Icon(Icons.history),
            title: const Text('My Orders'),
            horizontalTitleGap: 2,
          ),
          const Divider(),
          ListTile(
            onTap: () {
              pushNewScreenWithRouteSettings(
                context,
                settings: const RouteSettings(name: CreditCardList.id),
                screen: const CreditCardList(),
                withNavBar: false,
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            },
            leading: const Icon(Icons.credit_card),
            title: const Text('Manage Credit Card'),
            horizontalTitleGap: 2,
          ),
          const Divider(),
          ListTile(
            onTap: () {
              pushNewScreenWithRouteSettings(
                context,
                settings: const RouteSettings(name: MyRatingScreen.id),
                screen: MyRatingScreen(),
                withNavBar: false,
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            },
            leading: const Icon(Icons.comment_outlined),
            title: const Text('My Ratings & Reviews'),
            horizontalTitleGap: 2,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.power_settings_new),
            title: const Text('Logout'),
            horizontalTitleGap: 2,
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return CupertinoAlertDialog(
                      title: const Text("Log out"),
                      content: const Text("Are you sure you want to Logout"),
                      actions: [
                        CupertinoDialogAction(
                            child: const Text("YES"),
                            onPressed: () {
                              _signOut().then((value) {
                                pushNewScreenWithRouteSettings(
                                  context,
                                  settings:
                                      const RouteSettings(name: BlankScreen.id),
                                  screen: const BlankScreen(),
                                  withNavBar: false,
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              });
                              Navigator.of(context).pop();
                            }),
                        CupertinoDialogAction(
                            child: const Text("NO"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            })
                      ],
                    );
                  });
            },
          ),
          const Divider(),
        ]),
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
