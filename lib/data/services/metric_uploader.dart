import 'package:dio/dio.dart';

class MetricUploader {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  static const String _base =
      "https://farmaciajoshua-f7bncqe5aaefdsfp.westus3-01.azurewebsites.net"; // ajusta según tu caso
  static const String _url = "$_base/api/metrics/batch";

  static Future<void> upload(List<Map<String, dynamic>> items) async {
    if (items.isEmpty) return;

    try {
      await _dio.post(
        _url,
        data: items, // array de métricas
        options: Options(headers: {"Content-Type": "application/json"}),
      );
    } catch (e) {
      throw Exception("Error subiendo métricas/logs: $e");
    }
  }
}
