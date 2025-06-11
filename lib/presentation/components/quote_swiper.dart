import 'package:card_swiper/card_swiper.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/foundation.dart'
    show listEquals; // ADDED: Import for listEquals
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quoter/bloc/cubit/swiper_cubit.dart';
import 'package:quoter/constants.dart';
import 'package:quoter/models/quote.dart';
import 'package:quoter/presentation/components/single_quote_card.dart'; // NO CHANGE: Keep this import as is
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
  // --- REMOVED: No need for a separate _swiperController field here.
  // We'll use widget.swiperController directly as it's passed in.
  // late final SwiperController _swiperController;

  // --- CHANGE: Made flipCardKeys private with an underscore
  late List<GlobalKey<FlipCardState>> _flipCardKeys;

  @override
  void initState() {
    super.initState();
    // --- REMOVED: No need to initialize _swiperController here.
    // _swiperController = widget.swiperController;

    // --- NO CHANGE (in logic): Initialize _flipCardKeys based on initial quotes.
    _flipCardKeys = List.generate(
      widget.allQuotes.length,
      (i) => GlobalKey<FlipCardState>(),
    );
  }

  // --- ADDED: This method handles cases where the list of quotes might change.
  // If the `allQuotes` list updates, we need to regenerate the `_flipCardKeys`
  // to ensure each `SingleQuoteCard` has a unique and stable key corresponding
  // to its position, preventing unexpected behavior with FlipCard states.
  @override
  void didUpdateWidget(covariant QuoteSwiper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only regenerate keys if the list length changes or if the content is different.
    if (widget.allQuotes.length != oldWidget.allQuotes.length ||
        !listEquals(widget.allQuotes, oldWidget.allQuotes)) {
      _flipCardKeys = List.generate(
        widget.allQuotes.length,
        (i) => GlobalKey<FlipCardState>(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // --- REMOVED: This BlocProvider.value is redundant.
    // The SwiperCubit is already provided higher up in the widget tree by your MultiBlocProvider in main.dart.
    // Wrapping it again here just creates an unnecessary new instance of the cubit,
    // which BlocBuilder would then look up anyway.
    // return BlocProvider.value(
    //   value: context.read<SwiperCubit>(),
    //   child:
    return BlocBuilder<SwiperCubit, int>(
      builder: (context, currentIndex) {
        return SizedBox(
            height: size.height * 0.5,
            child: Swiper(
                controller: widget
                    .swiperController, // --- CHANGE: Use widget.swiperController directly
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
                  // --- NO CHANGE: Vibration logic remains
                  if (await Vibration.hasAmplitudeControl()) {
                    Vibration.vibrate(duration: 50, amplitude: 9);
                  }
                },
                viewportFraction: 0.9,
                itemHeight: double.infinity,
                itemWidth: double.infinity,
                scale: 1,
                itemBuilder: (context, index) {
                  // --- NO CHANGE: Using SingleQuoteCard as before
                  return SingleQuoteCard(
                    quote: widget.allQuotes[index],
                    // --- CHANGE: Use the private _flipCardKeys list
                    flipKey: _flipCardKeys[index],
                  );
                }));
      },
    );
  }
}
