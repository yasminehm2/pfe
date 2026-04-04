// lib/ui/widgets/arrival_alert_banner.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/providers/tracking_provider.dart';

class ArrivalAlertBanner extends StatelessWidget {
  const ArrivalAlertBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final update = context.watch<TrackingProvider>().currentUpdate;

    if (update == null || !update.arrivalAlert) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
      ),
      child: Row(
        children: [
          const Icon(Icons.notification_important, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Your bus is arriving! ETA: ${update.etaMinutes.toStringAsFixed(1)} min",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}