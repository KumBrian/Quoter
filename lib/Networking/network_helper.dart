import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../Models/quote.dart';

String apiKey = dotenv.env['API_KEY'] ?? '';

Future fetchQuote() async {
  final http.Response response = await http.get(
      Uri.parse('https://api.api-ninjas.com/v1/quotes?category=happiness'),
      headers: {'X-Api-Key': apiKey});

  if (response.statusCode == 200) {
    print(response);
    return response;
  } else {
    print('Error: ${response.statusCode}');
  }
  return 'Error getting Quotes';
}

Future<Quote> decodeQuote(http.Response response) async {
  List jsonData = jsonDecode(response.body);
  return Quote.fromJson(jsonData);
}
