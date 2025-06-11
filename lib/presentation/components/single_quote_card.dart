import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:quoter/constants.dart';
import 'package:quoter/models/quote.dart';
import 'package:quoter/presentation/components/custom_card.dart';

class SingleQuoteCard extends StatelessWidget {
  final Quote quote;
  final GlobalKey<FlipCardState> flipKey;

  const SingleQuoteCard({
    super.key,
    required this.quote,
    required this.flipKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: kPrimaryDark,
      child: Center(
        child: AspectRatio(
          aspectRatio: 12 / 16,
          child: CustomCard(
            quote: quote,
            flipCardKey: flipKey,
          ),
        ),
      ),
    );
  }
}
