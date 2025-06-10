import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quoter/constants.dart';

class LoadingRings extends StatelessWidget {
  const LoadingRings({
    super.key,
    required this.size,
  });
  final double size;

  @override
  Widget build(BuildContext contextMain) {
    return Center(
      child: LoadingAnimationWidget.discreteCircle(
        color: kSecondaryDark,
        secondRingColor: kPrimaryLighterDark,
        size: size,
      ),
    );
  }
}
