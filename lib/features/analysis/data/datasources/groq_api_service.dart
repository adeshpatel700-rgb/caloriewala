import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/food_item_model.dart';
import '../models/nutrition_model.dart';

/// Groq API service — food image analysis + nutrition calculation
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

  // ── Public methods ──────────────────────────────────────────────────────────

  Future<List<FoodItemModel>> analyzeImage(File imageFile) async {
    try {
      final bytes       = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      if (bytes.length > AppConfig.maxImageSizeBytes) {
        throw ValidationException('Image too large. Please use an image smaller than 5MB.');
      }

      final response = await _makeRequestWithRetry(
        endpoint: '/chat/completions',
        data: {
          'model': EnvConfig.visionModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are an Indian food expert. Respond ONLY with raw JSON, no markdown, no prose.',
            },
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': _imagePrompt()},
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
                },
              ],
            },
          ],
          'temperature': 0.2,
          'max_tokens': 800,
        },
      );

      return _parseFoodItems(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to analyze image: ${e.toString()}');
    }
  }

  Future<List<FoodItemModel>> analyzeTextDescription(String description) async {
    if (description.trim().isEmpty) {
      throw ValidationException('Please provide a food description');
    }
    try {
      final response = await _makeRequestWithRetry(
        endpoint: '/chat/completions',
        data: {
          'model': EnvConfig.textModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are an expert Indian food nutritionist. Respond with valid JSON only, no additional text.',
            },
            {
              'role': 'user',
              'content': _textPrompt(description),
            },
          ],
          'temperature': 0.3,
          'max_tokens': 800,
          'response_format': {'type': 'json_object'},
        },
      );
      return _parseFoodItems(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException('Failed to analyze text: ${e.toString()}');
    }
  }

  Future<NutritionModel> calculateNutrition(List<FoodItemModel> foodItems) async {
    try {
      final foodList = foodItems.map((i) => '${i.name} - ${i.portion}').join('\n');
      final response = await _makeRequestWithRetry(
        endpoint: '/chat/completions',
        data: {
          'model': EnvConfig.textModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are an expert nutritionist for Indian cuisine. Respond with valid JSON only.',
            },
            {
              'role': 'user',
              'content': _nutritionPrompt(foodList),
            },
          ],
          'temperature': 0.2,
          'max_tokens': 500,
          'response_format': {'type': 'json_object'},
        },
      );
      return _parseNutrition(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException('Failed to calculate nutrition: ${e.toString()}');
    }
  }

  // ── Prompts ─────────────────────────────────────────────────────────────────

  String _imagePrompt() =>
      'Identify all food items in this image. '
      'Return ONLY raw JSON in exactly this structure:\n'
      '{"items":[{"name":"<English name>","hindi_name":"<Hindi or empty>","portion":"<e.g. 1 roti, 1 cup, 150g>","confidence":"high"}]}\n'
      'Use realistic Indian portion sizes. List each distinct food separately.';

  String _textPrompt(String description) =>
      'User said: "$description"\n'
      'List all food items with portions. Return JSON:\n'
      '{"items":[{"name":"<name>","hindi_name":"<Hindi or empty>","portion":"<e.g. 2 roti, 1 cup dal>","confidence":"high"}]}';

  String _nutritionPrompt(String foodList) =>
      'Calculate total nutrition for:\n$foodList\n\n'
      'Return JSON: {"total_calories":number,"protein_g":number,"carbs_g":number,"fat_g":number,'
      '"health_note":"<one sentence>","disclaimer":"Approximate estimates."}';

  // ── Parsing ─────────────────────────────────────────────────────────────────

  List<FoodItemModel> _parseFoodItems(Response response) {
    try {
      final raw  = response.data['choices'][0]['message']['content'] as String;
      final data = jsonDecode(_extractJson(raw)) as Map<String, dynamic>;
      return (data['items'] as List<dynamic>? ?? [])
          .map((e) => FoodItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException('Could not parse food data: ${e.toString()}');
    }
  }

  NutritionModel _parseNutrition(Response response) {
    try {
      final raw = response.data['choices'][0]['message']['content'] as String;
      return NutritionModel.fromJson(jsonDecode(_extractJson(raw)) as Map<String, dynamic>);
    } catch (e) {
      throw ServerException('Could not parse nutrition data: ${e.toString()}');
    }
  }

  /// Strip markdown code fences (```json ... ```) before JSON decoding.
  /// Also strips any prose before the first { or [.
  String _extractJson(String raw) {
    final s = raw.trim();
    // Match ``` or ```json fenced blocks
    final m = RegExp(r'^```(?:json)?\s*\n([\s\S]*?)\n?```\s*$').firstMatch(s);
    if (m != null) return m.group(1)!.trim();
    // Fallback: find first JSON token
    final ob = s.indexOf('{');
    final oa = s.indexOf('[');
    if (ob == -1 && oa == -1) return s;
    final start = (ob == -1) ? oa : (oa == -1) ? ob : (ob < oa ? ob : oa);
    return s.substring(start);
  }

  // ── Retry & error handling ──────────────────────────────────────────────────

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
        await Future.delayed(Duration(seconds: attempt * 2));
        return _makeRequestWithRetry(endpoint: endpoint, data: data, attempt: attempt + 1);
      }
      rethrow;
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException('Request timed out. Please try again.');
    }
    final code = e.response?.statusCode;
    if (code != null) {
      switch (code) {
        case 401: return ServerException('Invalid API key. Check your .env configuration.');
        case 429: return ServerException('Too many requests. Please wait and try again.');
        case 413: return ServerException('Photo too large. Use a smaller image.');
        case 500:
        case 502:
        case 503: return ServerException('Groq server error. Please try again shortly.');
        default:  return ServerException('API error ($code): ${e.response?.data}');
      }
    }
    return NetworkException('Network error — please check your internet connection.');
  }
}
