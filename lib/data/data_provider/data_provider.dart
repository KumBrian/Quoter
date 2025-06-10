import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

class QuotesDataProvider {
  Future<String> fetchQuotes(String category) async {
    final generationConfig = GenerationConfig(
      temperature: 1.6,
      topP: 1,
      responseMimeType: 'application/json',
    );
    final safetySettings = [
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium,
          HarmBlockMethod.severity),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium,
          HarmBlockMethod.severity),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium,
          HarmBlockMethod.severity),
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium,
          HarmBlockMethod.severity),
    ];
    try {
      final ai = FirebaseAI.vertexAI();
      final model = ai.generativeModel(
        model: 'gemini-2.0-flash-001',
        generationConfig: generationConfig,
        safetySettings: safetySettings,
      );

      String promptText = '';

      if (category == '') {
        promptText =
            'You are an API for a quotes app called Quoter. Your task is to provide a JSON structured response containing 10 *distinct* and *fresh* quotes. Each quote must have a "quote", "author", and "category". Ensure each quote is no longer than 200 words. Strive to generate *unique* and *less commonly known* quotes across a *wide range of diverse and interesting categories* with every request. The quotes should be reasonable and inspiring, but always new.';
      } else {
        promptText =
            'You are an API for a quotes app called Quoter. Your task is to provide a JSON structured response with 10 *distinct* and *fresh* quotes. Each quote must have a "quote", "author", and a "category" matching the requested category: **$category**. Ensure each quote is no longer than 200 words. Generate unique and less commonly known quotes that fit the **$category** category. The quotes should be reasonable and inspiring.';
      }

      final prompt = [Content.text(promptText)];
      final response = await model.generateContent(prompt);
      if (response.text == null) {
        debugPrint('Error: $response');
        return '';
      }
      debugPrint(response.text);
      return response.text!;
    } catch (e) {
      return 'Error: $e';
    }
  }
}

class CategoryDataProvider {
  Future<String> fetchCategory(String description) async {
    final generationConfig = GenerationConfig(
      temperature: 1.6,
      topP: 1,
      responseMimeType: 'application/json',
    );
    final safetySettings = [
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium,
          HarmBlockMethod.severity),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium,
          HarmBlockMethod.severity),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium,
          HarmBlockMethod.severity),
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium,
          HarmBlockMethod.severity),
    ];
    try {
      final ai = FirebaseAI.vertexAI();
      final model = ai.generativeModel(
        model: 'gemini-2.0-flash-001',
        generationConfig: generationConfig,
        safetySettings: safetySettings,
      );

      String promptText = '';

      if (description == '') {
        throw Exception('Description cannot be empty');
      } else {
        promptText =
            """Analyze the following user query and extract the single most relevant and concise category keyword or phrase (from a list of common quote categories) that best describes the user's intent. If no clear category is found, respond with "general". Only return the category keyword/phrase, nothing else. User query: "$description"
            """;
      }

      final prompt = [Content.text(promptText)];
      final response = await model.generateContent(prompt);
      if (response.text == null) {
        debugPrint('Error: $response');
        return '';
      }
      debugPrint(response.text);
      return response.text!;
    } catch (e) {
      return 'Error: $e';
    }
  }
}
