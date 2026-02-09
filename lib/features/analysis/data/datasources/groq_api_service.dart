import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/food_item_model.dart';
import '../models/nutrition_model.dart';

/// Service for interacting with Groq API for food analysis
class GroqApiService {
  final Dio _dio;

  GroqApiService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: EnvConfig.groqBaseUrl,
              connectTimeout: Duration(seconds: AppConfig.apiTimeoutSeconds),
              receiveTimeout: Duration(seconds: AppConfig.apiTimeoutSeconds),
              headers: {
                'Authorization': 'Bearer ${EnvConfig.groqApiKey}',
                'Content-Type': 'application/json',
              },
            ));

  /// Analyze image and detect food items
  /// Returns list of detected food items with portions and confidence
  Future<List<FoodItemModel>> analyzeImage(File imageFile) async {
    try {
      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Check image size
      if (bytes.length > AppConfig.maxImageSizeBytes) {
        throw ValidationException(
          'Image too large. Please use an image smaller than 5MB.',
        );
      }

      final prompt = _buildImageAnalysisPrompt();

      final response = await _makeRequestWithRetry(
        endpoint: '/chat/completions',
        data: {
          'model': EnvConfig.visionModel,
          'messages': [
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': prompt},
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image',
                  },
                },
              ],
            },
          ],
          'temperature': 0.3,
          'max_tokens': 1000,
        },
      );

      return _parseFoodItemsResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException('Failed to analyze image: ${e.toString()}');
    }
  }

  /// Analyze food from text description (no image)
  /// Returns list of detected food items with portions
  Future<List<FoodItemModel>> analyzeTextDescription(String description) async {
    try {
      if (description.trim().isEmpty) {
        throw ValidationException('Please provide a food description');
      }

      final prompt = _buildTextAnalysisPrompt(description);

      final response = await _makeRequestWithRetry(
        endpoint: '/chat/completions',
        data: {
          'model': EnvConfig.textModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are an expert Indian food nutritionist. '
                  'Always respond with valid JSON only, no additional text.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.3,
          'max_tokens': 800,
          'response_format': {'type': 'json_object'},
        },
      );

      return _parseFoodItemsResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException('Failed to analyze text: ${e.toString()}');
    }
  }

  /// Calculate nutrition information from food items
  /// Returns detailed nutritional breakdown
  Future<NutritionModel> calculateNutrition(
    List<FoodItemModel> foodItems,
  ) async {
    try {
      final foodList =
          foodItems.map((item) => '${item.name} - ${item.portion}').join('\n');

      final prompt = _buildNutritionPrompt(foodList);

      final response = await _makeRequestWithRetry(
        endpoint: '/chat/completions',
        data: {
          'model': EnvConfig.textModel,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are an expert nutritionist specializing in Indian cuisine. '
                      'Always respond with valid JSON only, no additional text.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.2,
          'max_tokens': 500,
          'response_format': {'type': 'json_object'},
        },
      );

      return _parseNutritionResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(
        'Failed to calculate nutrition: ${e.toString()}',
      );
    }
  }

  /// Make API request with retry logic
  Future<Response> _makeRequestWithRetry({
    required String endpoint,
    required Map<String, dynamic> data,
    int attempt = 1,
  }) async {
    try {
      return await _dio.post(endpoint, data: data);
    } on DioException catch (e) {
      if (attempt < AppConfig.maxRetryAttempts &&
          (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.response?.statusCode == 429)) {
        // Wait before retry (exponential backoff)
        await Future.delayed(Duration(seconds: attempt * 2));
        return _makeRequestWithRetry(
          endpoint: endpoint,
          data: data,
          attempt: attempt + 1,
        );
      }
      rethrow;
    }
  }

  /// Build prompt for image analysis
  String _buildImageAnalysisPrompt() {
    return '''You are an expert Indian food nutritionist. Analyze this food image and identify:
1. All food items visible
2. Estimated portion sizes (in grams or standard measures like "1 roti", "1 katori", "1 cup")
3. Cooking method if identifiable

Respond in JSON format:
{
  "items": [
    {
      "name": "food name in English",
      "hindi_name": "food name in Hindi (optional)",
      "portion": "estimated portion",
      "confidence": "high/medium/low"
    }
  ],
  "notes": "any additional observations"
}

Focus on Indian cuisine. If unsure, provide best estimate with lower confidence.
Be specific with portions - use standard Indian measures when possible.''';
  }

  /// Build prompt for text-based food analysis
  String _buildTextAnalysisPrompt(String description) {
    return '''User described their food: "$description"

Analyze this food description and identify:
1. All food items mentioned
2. Quantities (if mentioned, or estimate reasonable portions)
3. Any cooking methods mentioned

Respond in JSON format:
{
  "items": [
    {
      "name": "food name in English",
      "hindi_name": "food name in Hindi (if applicable)",
      "portion": "estimated portion (e.g., '2 roti', '1 cup', '100g')",
      "confidence": "high/medium/low"
    }
  ],
  "notes": "any clarifications needed"
}

Examples:
- "2 roti aur dal" → 2 roti (50g each), 1 katori dal (150g)
- "chicken biryani" → 1 plate chicken biryani (300g)
- "samosa and chai" → 2 samosa (60g each), 1 cup chai (200ml)

Note: For Indian foods, use standard portion sizes.''';
  }

  /// Build prompt for nutrition calculation
  String _buildNutritionPrompt(String foodList) {
    return '''Calculate nutritional information for these Indian food items:

$foodList

Provide:
1. Total calories (kcal)
2. Protein (g)
3. Carbohydrates (g)
4. Fat (g)
5. Brief health note (1 sentence, culturally appropriate for Indian users)

Respond in JSON:
{
  "total_calories": number,
  "protein_g": number,
  "carbs_g": number,
  "fat_g": number,
  "health_note": "string",
  "disclaimer": "These are approximate estimates based on standard recipes."
}

Use authentic Indian food nutrition data. Account for typical cooking methods (ghee, oil usage).
Be accurate with portion-based calculations.''';
  }

  /// Parse food items from API response
  List<FoodItemModel> _parseFoodItemsResponse(Response response) {
    try {
      final content = response.data['choices'][0]['message']['content'];
      final jsonData = jsonDecode(content) as Map<String, dynamic>;
      final items = jsonData['items'] as List<dynamic>;

      return items
          .map((item) => FoodItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException('Failed to parse food items: ${e.toString()}');
    }
  }

  /// Parse nutrition info from API response
  NutritionModel _parseNutritionResponse(Response response) {
    try {
      final content = response.data['choices'][0]['message']['content'];
      final jsonData = jsonDecode(content) as Map<String, dynamic>;

      return NutritionModel.fromJson(jsonData);
    } catch (e) {
      throw ServerException(
        'Failed to parse nutrition data: ${e.toString()}',
      );
    }
  }

  /// Handle Dio errors and convert to appropriate exceptions
  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException('Request timeout. Please check your connection.');
    }

    if (e.response != null) {
      final statusCode = e.response!.statusCode;

      switch (statusCode) {
        case 401:
          return ServerException(
            'Invalid API key. Please check your .env configuration.',
          );
        case 429:
          return ServerException(
            'Rate limit exceeded. Please try again later.',
          );
        case 500:
        case 502:
        case 503:
          return ServerException(
            'Server error. Please try again later.',
          );
        default:
          return ServerException(
            'API error (${statusCode}): ${e.response!.data}',
          );
      }
    }

    return NetworkException('Network error. Please check your connection.');
  }
}
