import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:quoter/data/data_provider/data_provider.dart';
import 'package:quoter/models/quote.dart';

class QuotesRepository {
  QuotesDataProvider quotesDataProvider;
  QuotesRepository({required this.quotesDataProvider});

  Future<List<Quote>> fetchQuotes(String category) async {
    List<Quote> quotes = [];
    try {
      final response = await quotesDataProvider.fetchQuotes(category);
      final data = jsonDecode(response);
      for (int i = 0; i < data.length; i++) {
        quotes.add(Quote.fromJson(data, i));
      }
    } catch (e) {
      debugPrint("Error fetching quotes: $e");
      throw Exception("Error fetching quotes");
    }

    return quotes;
  }
}
