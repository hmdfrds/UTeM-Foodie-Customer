import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

class DotIndicator extends StatelessWidget {
  final int count;
  final int currentPage;
  final Size size;
  const DotIndicator(
      {Key? key,
      required this.currentPage,
      required this.count,
      required this.size})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return DotsIndicator(
      dotsCount: count,
      position: currentPage.toDouble(),
      decorator: DotsDecorator(
          size: size,
          activeSize: const Size(18.0, 9.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          activeColor: Theme.of(context).primaryColor),
    );
  }
}
