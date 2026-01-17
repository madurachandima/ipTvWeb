import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/iptv_provider.dart';
import '../services/network_service.dart';

class SignalStrengthIndicator extends StatelessWidget {
  const SignalStrengthIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IPTVProvider>(
      builder: (context, provider, child) {
        if (!provider.networkMonitoringEnabled) return const SizedBox.shrink();

        final quality = provider.connectionQuality;
        final latency = provider.currentLatency;

        return Tooltip(
          message: quality == ConnectionQuality.offline
              ? 'Offline'
              : 'Connection: ${quality.name.toUpperCase()}\nLatency: ${latency}ms',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBars(quality),
              if (latency > 0) ...[
                const SizedBox(width: 8),
                Text(
                  '${latency}ms',
                  style: TextStyle(
                    fontSize: 10,
                    color: _getColor(quality).withValues(alpha: 0.7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBars(ConnectionQuality quality) {
    final color = _getColor(quality);
    final activeBars = _getBarCount(quality);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (index) {
        final isActive = index < activeBars;
        return Container(
          width: 3,
          height: 4.0 + (index * 3),
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: isActive ? color : Colors.white24,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }

  int _getBarCount(ConnectionQuality quality) {
    switch (quality) {
      case ConnectionQuality.excellent:
        return 4;
      case ConnectionQuality.good:
        return 3;
      case ConnectionQuality.fair:
        return 2;
      case ConnectionQuality.poor:
        return 1;
      case ConnectionQuality.offline:
        return 0;
    }
  }

  Color _getColor(ConnectionQuality quality) {
    switch (quality) {
      case ConnectionQuality.excellent:
        return Colors.greenAccent;
      case ConnectionQuality.good:
        return Colors.lightGreenAccent;
      case ConnectionQuality.fair:
        return Colors.orangeAccent;
      case ConnectionQuality.poor:
        return Colors.redAccent;
      case ConnectionQuality.offline:
        return Colors.grey;
    }
  }
}
