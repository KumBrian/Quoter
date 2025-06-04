import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:quoter/data/data_provider/data_provider.dart';
import 'package:quoter/models/quote.dart';

class QuotesRepository {
  QuotesDataProvider quotesDataProvider;
  QuotesRepository({required this.quotesDataProvider});

  Future<List<Quote>> fetchQuotes() async {
    List<Quote> quotes = [];
    try {
      for (int i = 0; i < 5; i++) {
        final response = await quotesDataProvider.fetchQuotes();
        final data = jsonDecode(response);
        quotes.add(Quote.fromJson(data));
      }
    } catch (e) {
      debugPrint("Error fetching quotes: $e");
      throw Exception("Error fetching quotes");
    }

    return quotes;
  }
}
