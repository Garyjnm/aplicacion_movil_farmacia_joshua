import 'package:dio/dio.dart';

class MetricUploader {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  // Cambia esta URL si usas dispositivo REAL
  static const String _url = "http://localhost:50498/api/metrics/batch";

  static Future<void> upload(List<Map<String, dynamic>> items) async {
    if (items.isEmpty) return;

    try {
      await _dio.post(
        _url,
        data: items, // enviamos array de logs/metricas
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );
    } catch (e) {
      // el buffer manejará el reintento
      throw Exception("Error subiendo métricas/logs: $e");
    }
  }
}
