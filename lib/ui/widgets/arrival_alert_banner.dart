// lib/ui/widgets/arrival_alert_banner.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/providers/tracking_provider.dart';

/**
 * 🔔 THE ARRIVAL ALERT BANNER:
 * A floating notification that appears at the top of the map
 * only when the bus is extremely close to the user.
 */
class ArrivalAlertBanner extends StatelessWidget {
  const ArrivalAlertBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // 👂 We listen to the TrackingProvider for live GPS updates.
    final update = context.watch<TrackingProvider>().currentUpdate;

    // 🕵️ CONDITIONAL RENDERING:
    // If there is no live data, OR if the 'arrivalAlert' flag from
    // the backend is false, we return an empty box (nothing is shown).
    if (update == null || !update.arrivalAlert) return const SizedBox.shrink();

    // 🚀 ALERT UI:
    // This part only runs when the bus is arriving.
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orangeAccent, // Warning color to grab attention
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
      ),
      child: Row(
        children: [
          // ⚠️ Pulse-like icon to signify urgency
          const Icon(Icons.notification_important, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              // Shows the precise minutes remaining (e.g., 0.5 min)
              "Your bus is arriving! ETA: ${update.etaMinutes.toStringAsFixed(1)} min",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}