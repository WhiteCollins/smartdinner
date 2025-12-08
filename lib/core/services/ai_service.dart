import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:developer' as developer;
import '../config/ai_config.dart';

class AiService {
  final String baseUrl;
  final Duration timeout;

  AiService({
    String? baseUrl,
    Duration? timeout,
  })  : baseUrl = baseUrl ?? AiConfig.baseUrl,
        timeout = timeout ?? AiConfig.timeout;

  /// Verificar estado del servicio de IA
  Future<Map<String, dynamic>> getHealth() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/health')).timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorMsg = 'Health check failed: ${response.statusCode}';
        developer.log('❌ $errorMsg');
        throw Exception(errorMsg);
      }
    } on http.ClientException catch (e) {
      final errorMsg = 'Connection failed: Cannot reach AI service at $baseUrl';
      developer.log('❌ $errorMsg - $e');
      throw Exception(errorMsg);
    } on TimeoutException catch (e) {
      final errorMsg = 'Connection timeout: AI service not responding';
      developer.log('❌ $errorMsg - $e');
      throw Exception(errorMsg);
    } catch (e) {
      final errorMsg = 'AI Service health check error: $e';
      developer.log('❌ $errorMsg');
      throw Exception(errorMsg);
    }
  }

  /// Obtener estado del modelo
  Future<Map<String, dynamic>> getModelStatus() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/models/status')).timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Model status failed: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('❌ AI Service model status error: $e');
      rethrow;
    }
  }

  /// Obtener predicción para un item específico
  Future<Map<String, dynamic>> getPrediction({
    required String itemId,
    required String itemName,
    required String date,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/predict'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'item_id': itemId,
              'item_name': itemName,
              'date': date,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Prediction failed: ${response.body}');
      }
    } catch (e) {
      developer.log('❌ AI Service prediction error: $e');
      rethrow;
    }
  }

  /// Obtener predicciones por lotes
  Future<List<dynamic>> getBatchPredictions({
    required List<Map<String, String>> items,
    required String date,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/batch-predict'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'items': items,
              'date': date,
            }),
          )
          .timeout(AiConfig.batchTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['predictions'] as List<dynamic>;
      } else {
        final errorMsg = 'Batch prediction failed: ${response.statusCode}';
        developer.log('❌ $errorMsg - Body: ${response.body}');
        throw Exception(errorMsg);
      }
    } on http.ClientException catch (e) {
      final errorMsg = 'Connection failed: Cannot reach AI service';
      developer.log('❌ $errorMsg - $e');
      throw Exception(errorMsg);
    } on TimeoutException catch (e) {
      final errorMsg = 'Request timeout: AI service took too long to respond';
      developer.log('❌ $errorMsg - $e');
      throw Exception(errorMsg);
    } catch (e) {
      final errorMsg = 'AI Service batch prediction error: $e';
      developer.log('❌ $errorMsg');
      throw Exception(errorMsg);
    }
  }

  /// Entrenar modelo
  Future<Map<String, dynamic>> trainModel({int daysOfHistory = 90}) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/train'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'days_of_history': daysOfHistory,
              'force_retrain': false,
            }),
          )
          .timeout(const Duration(minutes: 2));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Training failed: ${response.body}');
      }
    } catch (e) {
      developer.log('❌ AI Service training error: $e');
      rethrow;
    }
  }
}
