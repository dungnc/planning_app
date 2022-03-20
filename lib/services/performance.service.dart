import 'package:agileplanning/services/logging.service.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PerformanceService {
  static final instance = PerformanceService._();
  static final _logger =
      LoggingService.withTag((PerformanceService).toString());

  PerformanceService._();

  final Map<String, Trace> _traces = Map();

  Future<void> startTrace(String trace) async {
    if (kIsWeb) {
      return;
    }

    if (_traces.containsKey(trace)) {
      _logger.info(
          'Already started trace $trace, skipping attempt to start again');
      return;
    }

    _traces[trace] = await FirebasePerformance.startTrace(trace);
  }

  Future<void> putAttribute(
      {String trace, String attribute, String value}) async {
    if (!kIsWeb) {
      return;
    }

    _traces[trace].putAttribute(attribute, value);
  }

  Future<void> incrementMetric({String trace, String metric, int value}) async {
    if (!kIsWeb) {
      return;
    }

    _traces[trace].incrementMetric(metric, value);
  }

  Future<void> stopTrace(String trace) async {
    if (kIsWeb) {
      return;
    }

    assert(_traces.containsKey(trace));
    _traces[trace].stop();
    _traces.remove(trace);
  }
}
