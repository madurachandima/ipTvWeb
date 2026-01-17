import 'dart:async';
import 'package:http/http.dart' as http;

enum ConnectionQuality { excellent, good, fair, poor, offline }

class NetworkService {
  final _qualityController = StreamController<ConnectionQuality>.broadcast();
  final _latencyController = StreamController<int>.broadcast();

  Stream<ConnectionQuality> get onQualityChanged => _qualityController.stream;
  Stream<int> get onLatencyChanged => _latencyController.stream;

  Timer? _timer;
  int _consecutiveFailures = 0;

  void startMonitoring() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _checkQuality());
    _checkQuality(); // Initial check
  }

  void stopMonitoring() {
    _timer?.cancel();
  }

  Future<void> _checkQuality() async {
    final stopwatch = Stopwatch()..start();
    try {
      // Using a small, reliable endpoint for latency check
      final response = await http
          .get(Uri.parse('https://www.google.com/generate_204'))
          .timeout(const Duration(seconds: 3));

      stopwatch.stop();
      _consecutiveFailures = 0;

      if (response.statusCode == 204 || response.statusCode == 200) {
        final latency = stopwatch.elapsedMilliseconds;
        _latencyController.add(latency);
        _qualityController.add(_mapLatencyToQuality(latency));
      } else {
        _handleFailure();
      }
    } catch (e) {
      _handleFailure();
    }
  }

  void _handleFailure() {
    _consecutiveFailures++;
    if (_consecutiveFailures >= 2) {
      _qualityController.add(ConnectionQuality.offline);
      _latencyController.add(-1);
    } else {
      _qualityController.add(ConnectionQuality.poor);
    }
  }

  ConnectionQuality _mapLatencyToQuality(int latency) {
    if (latency < 150) return ConnectionQuality.excellent;
    if (latency < 400) return ConnectionQuality.good;
    if (latency < 800) return ConnectionQuality.fair;
    return ConnectionQuality.poor;
  }

  void dispose() {
    _timer?.cancel();
    _qualityController.close();
    _latencyController.close();
  }
}
