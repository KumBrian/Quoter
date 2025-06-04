import 'package:hive_flutter/adapters.dart';
import 'package:quoter/models/quote.dart';

part 'hive_quote.g.dart';

@HiveType(typeId: 0)
class HiveQuote extends HiveObject {
  @HiveField(0)
  String author;

  @HiveField(1)
  String quote;

  HiveQuote({required this.author, required this.quote});

  factory HiveQuote.fromQuote(Quote quote) {
    return HiveQuote(author: quote.author, quote: quote.quote);
  }

  Quote toQuote() {
    return Quote(author: author, quote: quote, isLiked: true);
  }
}

class LikedQuotesRepository {
  static const String boxName = 'liked_quotes';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(HiveQuoteAdapter());
    await Hive.openBox<HiveQuote>(boxName);
  }

  Box<HiveQuote> get _box => Hive.box<HiveQuote>(boxName);

  List<Quote> getAllLikedQuotes() {
    return _box.values.map((hiveQuote) => hiveQuote.toQuote()).toList();
  }

  Future<void> addQuote(Quote quote) async {
    final hiveQuote = HiveQuote.fromQuote(quote);
    // Use the quote text as the key; assumes text is unique
    await _box.put(quote.quote.substring(1, 5) + quote.author, hiveQuote);
  }

  Future<void> removeQuote(Quote quote) async {
    await _box.delete(quote.quote.substring(1, 5) + quote.author);
  }

  bool isFavorite(Quote quote) {
    return _box.containsKey(quote.quote.substring(1, 5) + quote.author);
  }
}
