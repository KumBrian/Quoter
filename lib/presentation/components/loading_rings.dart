import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quoter/constants.dart';

class LoadingRings extends StatelessWidget {
  const LoadingRings({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.discreteCircle(
        color: kSecondaryDark,
        secondRingColor: kPrimaryLighterDark,
        size: 100,
      ),
    );
  }
}
