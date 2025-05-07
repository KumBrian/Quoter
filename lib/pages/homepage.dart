import 'dart:io';
import 'dart:math' show Random;
import 'dart:ui' as ui;

import 'package:card_swiper/card_swiper.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quoter/Components/custom_card.dart';
import 'package:quoter/Models/quote.dart';
import 'package:quoter/Networking/network_helper.dart';
import 'package:quoter/constants.dart';
import 'package:quoter/pages/favorites_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../Components/custom_icon_button.dart';

final GlobalKey previewContainer = GlobalKey();
int currentIndex = 0;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  SwiperController swiperController = SwiperController();
  late AnimationController animationController;
  late Animation<double> animation;

  late List<Quote> quotes = [];
  late List<Quote> likedQuotes = [];
  bool isWaiting = false;
  late Quote currentQuote;

  @override
  void initState() {
    super.initState();
    getQuotes();
  }

  @override
  void dispose() {
    super.dispose();
    swiperController.dispose();
  }

  void getQuotes() async {
    setState(() {
      isWaiting = true;
    });
    final result = <Quote>[];
    for (int i = 0; i < 5; i++) {
      final response = await fetchQuote();
      if (response?.statusCode == 200) {
        final quote = await decodeQuote(response!);
        result.add(quote);
      } else {
        print('Returning Null');
      }
    }
    setState(() {
      isWaiting = false;
      quotes = result;
    });
  }

  void shuffle() {
    var newIndex = Random().nextInt(quotes.length);
    setState(() {
      swiperController.move(
        newIndex,
      );
    });
  }

  Widget displaySwiper(Size size) {
    List<GlobalKey<FlipCardState>> flipCardKeys = List.generate(
      quotes.length,
      (index) => GlobalKey<FlipCardState>(),
    );

    return SizedBox(
      height: size.height * 0.5,
      child: Swiper(
          controller: swiperController,
          itemCount: quotes.length,
          onIndexChanged: (index) async {
            // ignore: unused_local_variable
            final canVibrate = await Haptics.canVibrate();
            await Haptics.vibrate(HapticsType.light);
            setState(() {
              swiperController.index = index;
              currentIndex = index;
            });
          },
          viewportFraction: 0.8,
          itemHeight: double.infinity,
          itemWidth: double.infinity,
          scale: 0.8,
          itemBuilder: (context, index) {
            final isCurrent = index == currentIndex;
            return isCurrent
                ? RepaintBoundary(
                    key: previewContainer,
                    child: CustomCard(
                        flipCardKeys: flipCardKeys,
                        quotes: quotes,
                        index: index),
                  )
                : CustomCard(
                    flipCardKeys: flipCardKeys, quotes: quotes, index: index);
          }),
    );
  }

  List<Widget> displayButtons() {
    return [
      CustomIconButton(
        icon: CupertinoIcons.shuffle_medium,
        label: 'Shuffle',
        onTap: () {
          shuffle();
          displaySnackBar('Shuffled');
        },
        isLiked: false,
      ),
      CustomIconButton(
        icon: Icons.favorite,
        label: 'Like',
        onTap: () {
          if (quotes[swiperController.index].isLiked) {
            setState(() {
              quotes[swiperController.index].isLiked = false;
              likedQuotes.remove(quotes[swiperController.index]);
            });
            displayLikeButtonSnackBar(quotes[swiperController.index].isLiked);
          } else {
            setState(() {
              quotes[swiperController.index].isLiked = true;
              likedQuotes.add(quotes[swiperController.index]);
            });
            displayLikeButtonSnackBar(quotes[swiperController.index].isLiked);
          }
        },
        isLiked:
            quotes.isEmpty ? false : quotes[swiperController.index].isLiked,
      ),
      CustomIconButton(
        icon: Icons.share,
        label: 'Share',
        onTap: () async {
          //implement the sharing here
          //TODO: create pop up to select between copying text or saving image
          try {
            await Future.delayed(const Duration(
                milliseconds: 100)); // slight delay helps sometimes
            await WidgetsBinding.instance.endOfFrame;

            RenderRepaintBoundary boundary = previewContainer.currentContext!
                .findRenderObject() as RenderRepaintBoundary;

            if (boundary.debugNeedsPaint) {
              await Future.delayed(const Duration(milliseconds: 20));
              return;
            }

            ui.Image image = await boundary.toImage(pixelRatio: 3.0);
            ByteData? byteData =
                await image.toByteData(format: ui.ImageByteFormat.png);
            Uint8List pngBytes = byteData!.buffer.asUint8List();

            final tempDir = await getTemporaryDirectory();
            final file = await File('${tempDir.path}/quote.png').create();
            await file.writeAsBytes(pngBytes);

            await Share.shareXFiles([XFile(file.path)],
                text: "Quote of the Day 💬");
          } catch (e) {
            print("Error sharing quote image: $e");
          }
        },
        isLiked: false,
      ),
    ];
  }

  PreferredSizeWidget displayAppBar() {
    return AppBar(
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: () {
              try {
                setState(() {
                  quotes.clear();
                  getQuotes();
                });
              } catch (e) {
                displaySnackBar('$e');
              }
            },
            child: const Icon(
              CupertinoIcons.refresh_circled,
              color: kSecondaryDark,
              size: 50,
            ),
          ),
        )
      ],
      backgroundColor: kPrimaryLighterDark,
      centerTitle: true,
      toolbarHeight: 100,
      elevation: 0,
      title: Text(
        'QUOTES',
        style: GoogleFonts.getFont(
          'Montserrat',
          fontSize: 40,
          color: kSecondaryDark,
        ),
      ),
      leading: Builder(builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: const Icon(
              Icons.menu,
              color: kSecondaryDark,
              size: 50,
            ),
          ),
        );
      }),
    );
  }

  void displayLikeButtonSnackBar(bool isLiked) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.info(
        backgroundColor: isLiked
            ? kSecondaryDark.withValues(alpha: 0.9)
            : kPrimaryDark.withValues(alpha: 0.9),
        textStyle: GoogleFonts.getFont('Montserrat',
            color: isLiked ? kPrimaryDark : Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w100),
        message: isLiked
            ? 'You Liked a Quote By ${quotes[swiperController.index].author}'
            : 'You Disliked the Quote By ${quotes[swiperController.index].author}',
      ),
    );
  }

  void displaySnackBar(String text) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.info(
        backgroundColor: kSecondaryDark.withValues(alpha: 0.9),
        textStyle: GoogleFonts.getFont('Montserrat',
            color: kPrimaryDark, fontSize: 20, fontWeight: FontWeight.w700),
        message: text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      drawer: SafeArea(
        child: Drawer(
          width: 250,
          backgroundColor: kPrimaryDark,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.cancel_sharp,
                    size: 50,
                    color: kSecondaryDark,
                  ),
                ),
              ),
              const SizedBox(
                height: 70,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: TextButton(
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(EdgeInsets.zero),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    List<Quote> quotes = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (BuildContext context) {
                            return FavoritesPage(likedQuotes: likedQuotes);
                          }),
                        ) ??
                        [];
                    setState(() {
                      likedQuotes = quotes;
                    });
                  },
                  child: Text(
                    'FAVORITES',
                    style: GoogleFonts.getFont('Montserrat',
                        fontSize: 24, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(
                height: 70,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Row(
                  children: [
                    Text(
                      'THEME',
                      style: GoogleFonts.getFont('Montserrat',
                          fontSize: 24, color: Colors.white),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Expanded(
                            child: Icon(
                              CupertinoIcons.moon_fill,
                              color: kSecondaryDark,
                              size: 25,
                            ),
                          ),
                          const SizedBox(
                            width: 35,
                          ),
                          Expanded(
                              child:
                                  Switch(value: false, onChanged: (value) {})),
                          const SizedBox(
                            width: 20,
                          ),
                          const Expanded(
                            child: Icon(
                              CupertinoIcons.sun_min_fill,
                              color: kSecondaryDark,
                              size: 25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: kPrimaryDark,
      appBar: displayAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 25,
        ),
        child: Column(
          children: [
            Expanded(
              flex: 8,
              child: isWaiting ? const LoadingRings() : displaySwiper(size),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(quotes.length, (index) {
                  return SizedBox(
                    height: 20,
                    width: 20,
                    child: index == swiperController.index
                        ? Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: const BoxDecoration(
                                color: kSecondaryDark, shape: BoxShape.circle),
                          )
                        : Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: const BoxDecoration(
                                color: kPrimaryLighterDark,
                                shape: BoxShape.circle),
                          ),
                  );
                }),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: displayButtons(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
