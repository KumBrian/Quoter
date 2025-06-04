import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

String apiKey = dotenv.env['API_KEY'] ?? '';
String baseUrl = dotenv.env['BASE_URL'] ?? '';

class QuotesDataProvider {
  Future<String> fetchQuotes() async {
    try {
      final http.Response response =
          await http.get(Uri.parse(baseUrl), headers: {'X-Api-Key': apiKey});
      if (response.statusCode == 200) {
        return response.body;
      }
      throw Exception("Couldn't get response from API");
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return '';
    }
  }
}
