import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/displayInfo_model.dart';
import '../../../logic/providers/map_provider.dart';
import '../../../logic/providers/auth_provider.dart';
import '../../../logic/providers/tracking_provider.dart';
import '../../../data/models/station_model.dart';

class TripListSheet extends StatefulWidget {
  final String stationName;
  final String stationId;

  const TripListSheet({super.key, required this.stationName, required this.stationId});

  @override
  State<TripListSheet> createState() => _TripListSheetState();
}

class _TripListSheetState extends State<TripListSheet> {
  DisplayInfoModel? _selectedTrip;

  @override
  Widget build(BuildContext context) {
    final mapProvider = context.watch<MapProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          ListTile(
            leading: _selectedTrip != null
                ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _selectedTrip = null),
            )
                : const Icon(Icons.location_on, color: Colors.red),
            title: Text(
              _selectedTrip == null
                  ? widget.stationName
                  : "Line ${_selectedTrip!.lineNumber} Itinerary",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Divider(),
          Expanded(
            child: _selectedTrip == null
                ? _buildListView(mapProvider)
                : _buildDetailView(_selectedTrip!, mapProvider, authProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(MapProvider provider) {
    // 🚀 FIX: More specific loading check
    if (provider.isLoading && provider.selectedStationTrips.isEmpty) return const Center(child: CircularProgressIndicator());
    if (provider.selectedStationTrips.isEmpty) {
      return const Center(child: Text("No active buses for this station."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: provider.selectedStationTrips.length,
      itemBuilder: (context, index) {
        final trip = provider.selectedStationTrips[index];
        final bool isCancelled = trip.isCancelled;

        return Card(
          elevation: isCancelled ? 0 : 2,
          color: isCancelled ? Colors.grey[50] : Colors.white,
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            onTap: isCancelled
                ? null
                : () {
              // 🚀 FIX: Only fetch if the trip is actually different
              if (_selectedTrip?.id != trip.id) {
                setState(() => _selectedTrip = trip);
                provider.fetchTripItinerary(trip.id!);
              } else {
                setState(() => _selectedTrip = trip);
              }
            },
            leading: CircleAvatar(
              backgroundColor: isCancelled ? Colors.grey[400] : Colors.blue[900],
              child: Text(
                trip.lineNumber ?? "?",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            title: Row(
              children: [
                Text(
                  "Departure: ${trip.departureTime}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCancelled ? Colors.grey : Colors.black,
                    decoration: isCancelled ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (isCancelled) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "CANCELLED",
                      style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ]
              ],
            ),
            subtitle: Text(
              isCancelled ? "Service Interrupted" : "Bus: ${trip.busPlate}",
              style: TextStyle(color: isCancelled ? Colors.grey : null),
            ),
            trailing: isCancelled
                ? const Icon(Icons.block, color: Colors.redAccent)
                : const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }

  Widget _buildDetailView(DisplayInfoModel trip, MapProvider provider, AuthProvider auth) {
    final bool isAuthenticated = auth.currentUser != null;
    final bool isGuest = isAuthenticated && auth.currentUser!.id.toString().toUpperCase().contains('GUEST');
    final bool isRealUser = isAuthenticated && !isGuest;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 10),
              _buildTripSummary(trip, provider, isRealUser),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("STOPS SEQUENCE", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              ),
              // 🚀 FIX: Prevent layout shift by checking both loading and data presence
              if (provider.isLoading && provider.currentItinerary.isEmpty)
                const Center(child: LinearProgressIndicator())
              else
                ...provider.currentItinerary.asMap().entries.map((entry) {
                  int idx = entry.key;
                  StationModel stop = entry.value;
                  bool isLast = idx == provider.currentItinerary.length - 1;

                  String timeDisplay = "${stop.minutesFromStartStation ?? 0} min";
                  if (stop.hasPassed) {
                    timeDisplay = "Passed";
                  } else if (stop.liveEtaMinutes != null) {
                    timeDisplay = "${stop.liveEtaMinutes} min (Live)";
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(stop.hasPassed ? Icons.check_circle : Icons.radio_button_checked, size: 18, color: stop.hasPassed ? Colors.green : Colors.blue[800]),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(stop.nameFr, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: stop.hasPassed ? Colors.grey : Colors.black)),
                                Text(stop.nameAr, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: stop.hasPassed ? Colors.green[50] : Colors.blue[50], borderRadius: BorderRadius.circular(12)),
                            child: Text(timeDisplay, style: TextStyle(color: stop.hasPassed ? Colors.green : Colors.blue, fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ],
                      ),
                      if (!isLast)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Container(height: 30, width: 2, color: stop.hasPassed ? Colors.green[200] : Colors.blue[100]),
                        ),
                    ],
                  );
                }),
              const SizedBox(height: 20),
            ],
          ),
        ),
        if (!trip.isCancelled) _buildTrackButton(trip, auth),
      ],
    );
  }

  Widget _buildTripSummary(DisplayInfoModel trip, MapProvider provider, bool isRealUser) {
    final bool currentlyFavorite = provider.isFavorite(trip.id!);
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
      child: Stack(
        children: [
          Column(
            children: [
              _infoLine(Icons.directions_bus, "Bus Plate", trip.busPlate ?? "N/A"),
              const Divider(),
              _infoLine(Icons.access_time, "Departure", trip.departureTime ?? "N/A"),
            ],
          ),
          if (isRealUser)
            Positioned(
              top: 0, right: 0,
              child: IconButton(
                onPressed: () => provider.toggleFavorite(trip),
                icon: Icon(currentlyFavorite ? Icons.star : Icons.star_border, color: currentlyFavorite ? Colors.amber : Colors.grey, size: 28),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoLine(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTrackButton(DisplayInfoModel trip, AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () async {
          final String userId = auth.currentUser?.id ?? "GUEST";
          context.read<MapProvider>().setTrackedStation(widget.stationId);
          bool success = await Provider.of<TrackingProvider>(context, listen: false)
              .activateAndTrack(trip.id!, widget.stationId, userId);
          if (success) Navigator.pop(context);
        },
        child: const Text("CONFIRM & TRACK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}