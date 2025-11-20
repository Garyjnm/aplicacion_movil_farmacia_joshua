import 'dart:async';
import 'metric_uploader.dart';

class MetricBuffer {
  static final MetricBuffer _instance = MetricBuffer._internal();
  factory MetricBuffer() => _instance;

  MetricBuffer._internal() {
    _startFlushTimer();
  }

  final List<Map<String, dynamic>> _buffer = [];
  final int _maxBufferSize = 15;
  final int _flushIntervalSeconds = 10;

  Timer? _timer;

  void addMetric(Map<String, dynamic> data) {
    // Nunca enviar Id desde el cliente
    data.remove('Id');
    data.remove('_id');
    data['type'] ??= 'metric';

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

    final itemsToSend = List<Map<String, dynamic>>.from(_buffer);
    _buffer.clear();

    try {
      await MetricUploader.upload(itemsToSend);
    } catch (_) {
      _buffer.insertAll(0, itemsToSend);
    }
  }
}