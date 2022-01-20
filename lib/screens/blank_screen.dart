import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:utem_foodie/screens/welcome_screen.dart';


class BlankScreen extends StatefulWidget {
  const BlankScreen({Key? key}) : super(key: key);
  static const String id = "blank-screen";

  @override
  _BlankScreenState createState() => _BlankScreenState();
}

class _BlankScreenState extends State<BlankScreen> {
  @override
  void initState() {
    Timer(
        const Duration(
          microseconds: 1,
        ), () {
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            WelcomeScreen.id, (Route<dynamic> route) => false);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
