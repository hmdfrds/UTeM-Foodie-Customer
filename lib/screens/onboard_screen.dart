import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

import '../constant.dart';

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({Key? key}) : super(key: key);

  @override
  _OnBoardScreenState createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> {
  // to control the PageViews
  final _controller = PageController(
    initialPage: 0,
  );

  // variable for DotIndicator to keep on track of current page
  int _currentPage = 0;

  // List of page to be pass insert PageViews
  final List<Widget> _pages = [
    Column(
      children: [
        Expanded(child: Image.asset('images/mobile_location.png')),
        const Text(
          'Set Your Delivery Location',
          style: kPageViewTextStyle,
          textAlign: TextAlign.center,
        )
      ],
    ),
    Column(
      children: [
        Expanded(child: Image.asset('images/online_food_store.png')),
        const Text(
          'Order Online from Your Favourite Store',
          style: kPageViewTextStyle,
          textAlign: TextAlign.center,
        )
      ],
    ),
    Column(
      children: [
        Expanded(child: Image.asset('images/food_deliver.png')),
        const Text(
          'Quick Deliver to your Doorstep',
          style: kPageViewTextStyle,
          textAlign: TextAlign.center,
        )
      ],
    ),
  ];

  // The screen
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _controller,
            children: _pages,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        DotsIndicator(
          dotsCount: _pages.length,
          position: _currentPage.toDouble(),
          decorator: DotsDecorator(
            size: const Size.square(9.0),
            activeSize: const Size(18.0, 9.0),
            activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            activeColor: Colors.deepOrangeAccent,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
