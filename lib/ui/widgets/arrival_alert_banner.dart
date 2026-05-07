import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/rotation_provider.dart';

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

    // Reset the flag if the bus is no longer near (in case of route updates)
    if (update == null || !update.arrivalAlert) {
      _hasShownAlert = false;
      return const SizedBox.shrink();
    }

    // Trigger the pop-out if it hasn't been shown yet for this arrival
    if (update.arrivalAlert && !_hasShownAlert) {
      _hasShownAlert = true;

      // We use addPostFrameCallback to trigger the dialog after the build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showArrivalDialog(context, update.etaMinutes);
      });
    }

    return const SizedBox.shrink();
  }

  void _showArrivalDialog(BuildContext context, double eta) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must acknowledge by pressing OK
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.notification_important, color: Colors.orangeAccent),
              SizedBox(width: 10),
              Text("Bus Arriving!"),
            ],
          ),
          content: Text(
            "Your bus is almost here. Estimated arrival in ${eta.toStringAsFixed(1)} minutes.",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "OK",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
            ),
          ],
        );
      },
    );
  }
}