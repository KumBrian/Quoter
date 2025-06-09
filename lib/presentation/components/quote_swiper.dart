import 'package:card_swiper/card_swiper.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quoter/bloc/cubit/swiper_cubit.dart';
import 'package:quoter/constants.dart';
import 'package:quoter/models/quote.dart';
import 'package:quoter/presentation/components/single_quote_card.dart';
import 'package:vibration/vibration.dart';

class QuoteSwiper extends StatefulWidget {
  const QuoteSwiper(
      {super.key, required this.allQuotes, required this.swiperController});

  final List<Quote> allQuotes;
  final SwiperController swiperController;

  @override
  State<QuoteSwiper> createState() => _QuoteSwiperState();
}

class _QuoteSwiperState extends State<QuoteSwiper> {
  late final SwiperController _swiperController;
  late List<GlobalKey<FlipCardState>> flipCardKeys;

  @override
  void initState() {
    super.initState();
    _swiperController = widget.swiperController;

    // Pre-generate one key per quote so each FlipCard is stable:
    flipCardKeys = List.generate(
      widget.allQuotes.length,
      (i) => GlobalKey<FlipCardState>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: context.read<SwiperCubit>(),
      child: BlocBuilder<SwiperCubit, int>(
        builder: (context, currentIndex) {
          return SizedBox(
              height: size.height * 0.5,
              child: Swiper(
                  controller: _swiperController,
                  physics: const BouncingScrollPhysics(),
                  pagination: SwiperPagination(
                      builder: DotSwiperPaginationBuilder(
                    activeColor: kSecondaryDark,
                    color: kPrimaryLighterDark,
                    size: size.width * (size.width < 500 ? 0.03 : 0.01),
                  )),
                  indicatorLayout: PageIndicatorLayout.WARM,
                  itemCount: widget.allQuotes.length,
                  curve: Curves.decelerate,
                  loop: false,
                  onIndexChanged: (newIndex) async {
                    // Update cubit’s index

                    context.read<SwiperCubit>().updateIndex(newIndex);
                    if (await Vibration.hasAmplitudeControl()) {
                      Vibration.vibrate(duration: 50, amplitude: 9);
                    }
                  },
                  viewportFraction: 0.9,
                  itemHeight: double.infinity,
                  itemWidth: double.infinity,
                  scale: 1,
                  itemBuilder: (context, index) {
                    return SingleQuoteCard(
                      quote: widget.allQuotes[index],
                      flipKey: flipCardKeys[index],
                    );
                  }));
        },
      ),
    );
  }
}
