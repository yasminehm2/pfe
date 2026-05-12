import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rotation_provider.dart';

/**
 * 🔔 THE ARRIVAL ALERT POP-UP:
 * Now triggers a formal AlertDialog when the bus is close.
 */
class ArrivalAlertBanner extends StatefulWidget {
  const ArrivalAlertBanner({super.key});

  @override
  State<ArrivalAlertBanner> createState() => _ArrivalAlertBannerState();
}

class _ArrivalAlertBannerState extends State<ArrivalAlertBanner> {
  bool _hasShownAlert = false;

  @override
  Widget build(BuildContext context) {
    final update = context.watch<RotationProvider>().currentUpdate;
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (update == null) {
      _hasShownAlert = false;
      return const SizedBox.shrink();
    }

    // 🚀 THE FIX: Frontend Override!
    // We check if ETA is 5 minutes or less, ignoring the backend's arrivalAlert boolean if it's wrong.
    final bool isBusNear = update.arrivalAlert || update.etaMinutes <= 5.0;

    // Reset the flag if the bus is no longer near (e.g., user tracked a different bus)
    if (!isBusNear) {
      _hasShownAlert = false;
      return const SizedBox.shrink();
    }

    // Trigger the pop-out if it hasn't been shown yet for this arrival
    if (isBusNear && !_hasShownAlert) {
      _hasShownAlert = true;

      // We use addPostFrameCallback to trigger the dialog safely after the build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showArrivalDialog(context, update.etaMinutes, primaryColor);
      });
    }

    return const SizedBox.shrink();
  }

  void _showArrivalDialog(BuildContext context, double eta, Color primaryColor) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must acknowledge by pressing OK
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              Icon(Icons.notification_important, color: primaryColor), // 🚀 Using Theme!
              const SizedBox(width: 10),
              const Text("Bus Arriving!"),
            ],
          ),
          content: Text(
            "Your bus is almost here. Estimated arrival in ${eta.toStringAsFixed(1)} minutes.",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "OK",
                style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor), // 🚀 Using Theme!
              ),
            ),
          ],
        );
      },
    );
  }
}