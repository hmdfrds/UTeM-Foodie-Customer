import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:utem_foodie/widgets/products/add_to_cart_widget.dart';
import 'package:utem_foodie/widgets/products/save_for_later.dart';

class BotttomSheetContainer extends StatefulWidget {
  const BotttomSheetContainer({Key? key, required this.documentSnapshot})
      : super(key: key);
  final DocumentSnapshot documentSnapshot;

  @override
  State<BotttomSheetContainer> createState() => _BotttomSheetContainerState();
}

class _BotttomSheetContainerState extends State<BotttomSheetContainer> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
            flex: 1,
            child: SaveForLater(
              documentSnapshot: widget.documentSnapshot,
            )),
        Flexible(
          flex: 1,
          child: AddToCartWidget(
            documentSnapshot: widget.documentSnapshot,
          ),
        )
      ],
    );
  }
}
