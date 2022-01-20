import 'package:flutter/material.dart';

import 'package:utem_foodie/screens/login_screen.dart';
import 'package:utem_foodie/screens/onboard_screen.dart';
import 'package:utem_foodie/screens/register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static const String id = 'welcome-screen';
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loginTextButton = TextButton(
      child: RichText(
        text: const TextSpan(
          text: 'Already a Customer ? ',
          style: TextStyle(color: Colors.grey),
          children: [
            TextSpan(
              text: 'Login',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.orangeAccent),
            ),
          ],
        ),
      ),
      onPressed: () {
        Navigator.pushNamed(context, LoginScreen.id);
      },
    );

    var elvtBtnSetDeliveryLocation = ElevatedButton(
      child: const Text(
        'CLICK HERE TO REGISTER',
        style: TextStyle(color: Colors.white),
      ),
      style: TextButton.styleFrom(
          primary: Colors.black,
          elevation: 0,
          backgroundColor: Colors.deepOrangeAccent),
      onPressed: () {
        Navigator.pushNamed(context, RegisterScreen.id);
      },
    );

    var text1 = const Text(
      'Still dont have an account?',
      style: TextStyle(color: Colors.grey),
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Expanded(child: OnBoardScreen()),
                text1,
                const SizedBox(height: 10),
                elvtBtnSetDeliveryLocation,
                const SizedBox(height: 20),
                loginTextButton
              ],
            ),
          
          ],
        ),
      ),
    );
  }
}
