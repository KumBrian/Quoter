import 'dart:math' show Random, pi;

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quoter/Networking/network_helper.dart';
import 'package:quoter/constants.dart';
import 'package:quoter/pages/favorites_page.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../Components/custom_icon_button.dart';
import '../Components/quotation_mark.dart';
import '../Models/quote.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController authorCardController;
  late Animation authorCardAnimation;
  SwiperController swiperController = SwiperController();

  late List quotes = [];
  late List<Quote> likedQuotes = [];
  bool isWaiting = false;
  late Quote currentQuote;

  void getQuotes() async {
    setState(() {
      isWaiting = true;
    });
    final result = [];
    for (int i = 0; i < 5; i++) {
      final response = await fetchQuote();
      if (response.statusCode == 200) {
        final quote = await decodeQuote(response);
        result.add(quote);
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

  @override
  void initState() {
    super.initState();
    getQuotes();
    authorCardController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    authorCardAnimation = Tween(begin: 0.0, end: pi / 2).animate(
      CurvedAnimation(parent: authorCardController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    super.dispose();
    swiperController.dispose();
    authorCardController.dispose();
  }

  Widget displaySwiper() {
    return Swiper(
      controller: swiperController,
      itemCount: quotes.length,
      onIndexChanged: (index) {
        authorCardController.reverse();
        setState(() {
          swiperController.index = index;
        });
      },
      viewportFraction: 0.9,
      itemHeight: double.infinity,
      itemWidth: double.infinity,
      scale: 0.8,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                if (authorCardAnimation.isCompleted) {
                  authorCardController.reverse();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: kPrimaryLighterDark,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Expanded(
                      flex: 1,
                      child: QuotationMark(
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Center(
                          child: Text(
                            quotes.isNotEmpty
                                ? quotes[index].quote
                                : 'Loading...',
                            style: GoogleFonts.getFont('Montserrat',
                                fontSize: 32,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: QuotationMark(
                        alignment: Alignment.centerRight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                authorCardController.forward();
              },
              child: AnimatedBuilder(
                animation: authorCardAnimation,
                builder: (BuildContext context, Widget? child) {
                  return Transform(
                    alignment: Alignment.centerLeft,
                    transform: Matrix4.rotationX(authorCardAnimation.value),
                    child: child,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: kSecondaryDark,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      quotes.isNotEmpty ? quotes[index].author : 'Loading...',
                      style: GoogleFonts.getFont('Moon Dance',
                          fontSize: 40, color: kPrimaryDark),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
        icon: Icons.copy_rounded,
        label: 'Copy',
        onTap: () async {
          await Clipboard.setData(ClipboardData(
              text:
                  "`${quotes[swiperController.index].quote}`\n\nBy ${quotes[swiperController.index].author}"));
          displaySnackBar('Copied');
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
                print(e);
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

  Widget displayLoadingAnimation() {
    return Center(
      child: LoadingAnimationWidget.discreteCircle(
        color: kSecondaryDark,
        secondRingColor: kPrimaryLighterDark,
        size: 100,
      ),
    );
  }

  void displayLikeButtonSnackBar(bool isLiked) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.info(
        backgroundColor: isLiked
            ? kSecondaryDark.withOpacity(0.9)
            : kPrimaryDark.withOpacity(0.9),
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
        backgroundColor: kSecondaryDark.withOpacity(0.9),
        textStyle: GoogleFonts.getFont('Montserrat',
            color: kPrimaryDark, fontSize: 20, fontWeight: FontWeight.w700),
        message: text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    var quotes = await Navigator.push(
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
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 16),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: isWaiting ? displayLoadingAnimation() : displaySwiper(),
            ),
            const SizedBox(
              height: 18,
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: displayButtons(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
