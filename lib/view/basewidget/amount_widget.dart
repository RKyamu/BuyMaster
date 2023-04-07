import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';

class AmountWidget extends StatelessWidget {
  final String title;
  final String amount;
  var haveMinus;

  AmountWidget({
    @required this.title,
    @required this.amount,
    this.haveMinus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title,
            style: titilliumRegular.copyWith(
                fontSize: Dimensions.FONT_SIZE_DEFAULT)),
        Text(haveMinus ? "- $amount" : amount,
            style: titilliumRegular.copyWith(
                fontSize: Dimensions.FONT_SIZE_DEFAULT)),
      ]),
    );
  }
}
