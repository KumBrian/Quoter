import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../Models/quote.dart';

String apiKey = dotenv.env['API_KEY'] ?? '';
String baseUrl = dotenv.env['BASE_URL'] ?? '';

Future<http.Response?> fetchQuote() async {
  final http.Response response = await http.get(
      Uri.parse('$baseUrl?category=happiness'),
      headers: {'X-Api-Key': apiKey});

  if (response.statusCode == 200) {
    print(response.body);
    return response;
  } else {
    print('Error: ${response.statusCode}');
  }
  return null;
}

Future<Quote> decodeQuote(http.Response response) async {
  List jsonData = jsonDecode(response.body);
  return Quote.fromJson(jsonData);
}
