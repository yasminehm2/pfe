import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_provider.dart';
import '../../../providers/displayInfo_provider.dart';
import '../../../providers/station_provider.dart';
import '../../../data/models/displayInfo_model.dart';
import '../../../providers/rotation_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final displayProvider = context.watch<DisplayInfoProvider>();
    final stationProvider = context.read<StationProvider>();
    final userProvider = context.watch<UserProvider>();

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
      body: displayProvider.favoriteTrips.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: displayProvider.favoriteTrips.length,
        itemBuilder: (context, index) {
          final trip = displayProvider.favoriteTrips[index];

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ExpansionTile(
                  onExpansionChanged: (expanded) async {
                    if (expanded && displayProvider.currentItinerary.isEmpty) {
                      final itinerary = await displayProvider.fetchTripItinerary(trip.id!);
                      stationProvider.fetchRoadAlignedPath(itinerary);
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
                    "Departure: ${trip.departureTime}",
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Bus: ${trip.busPlate}"),
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
                          if (displayProvider.isLoading && displayProvider.currentItinerary.isEmpty)
                            const LinearProgressIndicator()
                          else
                            Wrap(
                              children: displayProvider.currentItinerary.isNotEmpty
                                  ? displayProvider.currentItinerary
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                int idx = entry.key;
                                var station = entry.value;
                                bool isLast = idx == displayProvider.currentItinerary.length - 1;
                                return Text(
                                  isLast ? station.nameFr : "${station.nameFr} - ",
                                  style: TextStyle(color: Colors.grey[800], fontSize: 13),
                                );
                              }).toList()
                                  : [const Text("Tap to load sequence...", style: TextStyle(fontStyle: FontStyle.italic))],
                            ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => displayProvider.toggleFavorite(trip),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _showStationPicker(context, trip, displayProvider, stationProvider, userProvider),
                        icon: const Icon(Icons.location_searching),
                        label: const Text("Select Station & Track"),
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

  void _showStationPicker(BuildContext context, DisplayInfoModel trip, DisplayInfoProvider displayProvider, StationProvider stationProvider, UserProvider userProvider) async {
    if (displayProvider.currentItinerary.isEmpty) {
      final itinerary = await displayProvider.fetchTripItinerary(trip.id!);
      stationProvider.fetchRoadAlignedPath(itinerary);
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Where are you boarding?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Text("Select your station to begin tracking.", style: TextStyle(color: Colors.grey)),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: displayProvider.currentItinerary.length,
                  itemBuilder: (context, index) {
                    final station = displayProvider.currentItinerary[index];
                    return ListTile(
                      leading: const Icon(Icons.radio_button_checked, color: Colors.blue),
                      title: Text(station.nameFr),
                      subtitle: Text(station.nameAr),
                      onTap: () async {
                        Navigator.pop(ctx);
                        Navigator.pop(context);

                        displayProvider.setTrackedStation(station.id);

                        final trackingProvider = context.read<RotationProvider>();
                        final String userId = userProvider.currentUser?.id ?? "GUEST";

                        bool success = await trackingProvider.activateAndTrack(
                            trip.id!,
                            station.id,
                            userId
                        );

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Tracking ${trip.lineNumber} from ${station.nameFr}")),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_border, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text("No favourites yet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text("Tap the star icon on any trip to save it here.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}