// lib/ui/screens/map/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../logic/providers/auth_provider.dart';
import '../../../logic/providers/map_provider.dart';
import '../../../logic/providers/tracking_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mapProvider = context.watch<MapProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Favourite Trips",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: mapProvider.favoriteTrips.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mapProvider.favoriteTrips.length,
        itemBuilder: (context, index) {
          final trip = mapProvider.favoriteTrips[index];

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ExpansionTile(
                  onExpansionChanged: (expanded) {
                    if (expanded) {
                      mapProvider.fetchTripItinerary(trip.id!);
                    }
                  },
                  shape: const Border(),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blue[900],
                    child: Text(
                      trip.lineNumber ?? "?",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    "${trip.departureTime} → ${trip.arrivalTime}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Bus Plate: ${trip.busPlate}"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "STATION SEQUENCE:",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent),
                          ),
                          const SizedBox(height: 8),
                          if (mapProvider.isLoading)
                            const LinearProgressIndicator()
                          else
                            Wrap(
                              children: mapProvider.currentItinerary.isNotEmpty
                                  ? mapProvider.currentItinerary
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                int idx = entry.key;
                                var station = entry.value;
                                bool isLast = idx == mapProvider.currentItinerary.length - 1;
                                return Text(
                                  isLast
                                      ? station.nameFr
                                      : "${station.nameFr} - ",
                                  style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 14),
                                );
                              }).toList()
                                  : [
                                const Text(
                                    "Tap to load sequence...",
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic))
                              ],
                            ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent),
                        tooltip: "Remove from favourites",
                        onPressed: () {
                          mapProvider.toggleFavorite(trip);
                        },
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          final trackingProvider = context.read<TrackingProvider>();

                          navigator.pop(); // Return to map

                          // Make sure we have the itinerary loaded to get the start station ID
                          await mapProvider.fetchTripItinerary(trip.id!);

                          String startStationId = "";
                          if (mapProvider.currentItinerary.isNotEmpty) {
                            startStationId = mapProvider.currentItinerary.first.id;
                          }

                          final String userId = authProvider.currentUser?.id ?? "GUEST_USER";

                          // 🚀 FIX: Call the unified TrackingProvider method
                          bool success = await trackingProvider.activateAndTrack(
                              trip.id!,
                              startStationId,
                              userId
                          );

                          if (success) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text("Tracking activated from Favourites!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text("Track Now",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_border, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No favourites yet",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap the star icon on any trip to save it here.",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}