// lib/ui/screens/map/trip_list_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../logic/providers/map_provider.dart';
import '../../../logic/providers/auth_provider.dart';
import '../../../logic/providers/tracking_provider.dart';
import '../../../data/models/rotation_model.dart';

class TripListSheet extends StatefulWidget {
  final String stationName;
  final String stationId;

  const TripListSheet({super.key, required this.stationName, required this.stationId});

  @override
  State<TripListSheet> createState() => _TripListSheetState();
}

class _TripListSheetState extends State<TripListSheet> {
  RotationModel? _selectedTrip;

  @override
  void didUpdateWidget(TripListSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stationName != widget.stationName) {
      _selectedTrip = null;
    }
  }

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
                  borderRadius: BorderRadius.circular(10)
              )
          ),
          ListTile(
            leading: _selectedTrip != null
                ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedTrip = null)
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
                onPressed: () => Navigator.pop(context)
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
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (provider.selectedStationTrips.isEmpty) {
      return const Center(child: Text("No active buses for this line."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: provider.selectedStationTrips.length,
      itemBuilder: (context, index) {
        final trip = provider.selectedStationTrips[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            onTap: () {
              setState(() => _selectedTrip = trip);
              provider.fetchTripItinerary(trip.id!);
            },
            leading: CircleAvatar(
              backgroundColor: Colors.blue[900],
              child: Text(
                  trip.lineNumber ?? "?",
                  style: const TextStyle(color: Colors.white, fontSize: 12)
              ),
            ),
            title: Text("${trip.departureTime} → ${trip.arrivalTime}"),
            subtitle: Text("Bus: ${trip.busPlate}"),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }

  Widget _buildDetailView(RotationModel trip, MapProvider provider, AuthProvider auth) {
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
              _buildTripInfoSummary(trip, provider, isRealUser),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                    "STOPS SEQUENCE",
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, letterSpacing: 1.2)
                ),
              ),
              if (provider.isLoading)
                const Center(child: LinearProgressIndicator())
              else if (provider.currentItinerary.isEmpty)
                const Center(child: Text("Itinerary data unavailable."))
              else
                ...provider.currentItinerary.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var stop = entry.value;
                  bool isLast = idx == provider.currentItinerary.length - 1;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.radio_button_checked, size: 18, color: Colors.blue[800]),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(stop.nameFr, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                Text(stop.nameAr, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                              ],
                            ),
                          ),
                          Text("${idx + 1}", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        ],
                      ),
                      if (!isLast)
                        const Padding(
                          padding: EdgeInsets.only(left: 7, top: 2, bottom: 2),
                          child: Text("-", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
                        ),
                    ],
                  );
                }),
              const SizedBox(height: 20),
            ],
          ),
        ),
        _buildTrackButton(trip, auth), // Removed mapProvider, kept auth
      ],
    );
  }

  Widget _buildTripInfoSummary(RotationModel trip, MapProvider provider, bool isRealUser) {
    final bool currentlyFavorite = provider.isFavorite(trip.id!);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              _infoLine(Icons.directions_bus, "Bus Plate", trip.busPlate ?? "N/A"),
              const Divider(),
              _infoLine(Icons.access_time, "Departure", trip.departureTime ?? "08:00"),
              _infoLine(Icons.timer_outlined, "Arrival", trip.arrivalTime ?? "08:45"),
            ],
          ),
          if (isRealUser)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () {
                  provider.toggleFavorite(trip);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(currentlyFavorite ? "Removed from Favourites" : "Added to Favourites"),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                icon: Icon(
                  currentlyFavorite ? Icons.star : Icons.star_border,
                  color: currentlyFavorite ? Colors.amber : Colors.grey,
                  size: 28,
                ),
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

  Widget _buildTrackButton(RotationModel trip, AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
        ),
        onPressed: () async {
          final navigator = Navigator.of(context);
          final messenger = ScaffoldMessenger.of(context);
          final trackingProvider = Provider.of<TrackingProvider>(context, listen: false);

          final String userId = auth.currentUser?.id ?? "GUEST_USER";

          // 🚀 FIX: Call the unified TrackingProvider method
          bool success = await trackingProvider.activateAndTrack(
              trip.id!,
              widget.stationId,
              userId
          );

          if (success) {
            navigator.pop();
            messenger.showSnackBar(
                const SnackBar(content: Text("Tracking activated. View bus on map."))
            );
          }
        },
        child: const Text("CONFIRM & TRACK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}