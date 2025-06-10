import 'package:flutter/foundation.dart';
import 'package:quoter/data/data_provider/data_provider.dart';

class CategoryRepository {
  Future<String> fetchCategory(String description) async {
    String category = '';
    try {
      final response = await CategoryDataProvider().fetchCategory(description);
      category = response.replaceAll(RegExp(r'"'), '');
      return category;
    } catch (e) {
      debugPrint("Error fetching categories: $e");
      throw Exception("Error fetching categories");
    }
  }
}
