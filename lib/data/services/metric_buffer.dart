import 'dart:async';
import 'metric_uploader.dart';

class MetricBuffer {
  static final MetricBuffer _instance = MetricBuffer._internal();
  factory MetricBuffer() => _instance;

  MetricBuffer._internal() {
    _startFlushTimer();
  }

  final List<Map<String, dynamic>> _buffer = [];
  final int _maxBufferSize = 15;       // cuando lleguen a 15 logs/metrics, se envía
  final int _flushIntervalSeconds = 10; // cada 10 segundos se intenta enviar

  Timer? _timer;

  void addMetric(Map<String, dynamic> data) {
    _buffer.add(data);

    if (_buffer.length >= _maxBufferSize) {
      flush();
    }
  }

  void _startFlushTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(seconds: _flushIntervalSeconds),
      (timer) => flush(),
    );
  }

  Future<void> flush() async {
    if (_buffer.isEmpty) return;

    final List<Map<String, dynamic>> itemsToSend = List.from(_buffer);
    _buffer.clear();

    try {
      await MetricUploader.upload(itemsToSend);
    } catch (e) {
      // Si falla, regresamos los datos al buffer para reintento
      _buffer.insertAll(0, itemsToSend);
    }
  }
}
