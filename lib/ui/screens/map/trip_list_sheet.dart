import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/displayInfo_model.dart';
import '../../../providers/station_provider.dart';
import '../../../providers/displayInfo_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/rotation_provider.dart';
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
    final displayProvider = context.watch<DisplayInfoProvider>();
    final stationProvider = context.watch<StationProvider>();
    final userProvider = context.watch<UserProvider>();
    final primaryColor = Theme.of(context).colorScheme.primary;

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
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
          ),
          ListTile(
            leading: _selectedTrip != null
                ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _selectedTrip = null))
                : const Icon(Icons.location_on, color: Colors.red),
            title: Text(
              _selectedTrip == null ? widget.stationName : "Line ${_selectedTrip!.lineNumber} Itinerary",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ),
          const Divider(),
          Expanded(
            child: _selectedTrip == null
                ? _buildListView(displayProvider, stationProvider, primaryColor)
                : _buildDetailView(_selectedTrip!, displayProvider, userProvider, primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(DisplayInfoProvider displayProvider, StationProvider stationProvider, Color primaryColor) {
    if (displayProvider.isLoading && displayProvider.selectedStationTrips.isEmpty) return const Center(child: CircularProgressIndicator());
    if (displayProvider.selectedStationTrips.isEmpty) return const Center(child: Text("No active buses for this station."));

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: displayProvider.selectedStationTrips.length,
      itemBuilder: (context, index) {
        final trip = displayProvider.selectedStationTrips[index];
        final bool isCancelled = trip.isCancelled;

        return Card(
          elevation: isCancelled ? 0 : 2,
          color: isCancelled ? Colors.grey[100] : Colors.white,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: isCancelled ? BorderSide(color: Colors.grey[300]!) : BorderSide.none),
          child: ListTile(
            onTap: isCancelled ? null : () async {
              if (_selectedTrip?.id != trip.id) {
                setState(() => _selectedTrip = trip);
                final itinerary = await displayProvider.fetchTripItinerary(trip.id!);
                stationProvider.fetchRoadAlignedPath(itinerary);
                displayProvider.triggerCameraToBus();
              } else {
                setState(() => _selectedTrip = trip);
              }
            },
            leading: CircleAvatar(
              backgroundColor: isCancelled ? Colors.grey[400] : primaryColor, // 🚀 Theme!
              child: Text(trip.lineNumber ?? "?", style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
            title: Row(
              children: [
                Text("Departure: ${trip.departureTime}", style: TextStyle(fontWeight: FontWeight.bold, color: isCancelled ? Colors.grey[500] : Colors.black, decoration: isCancelled ? TextDecoration.lineThrough : null)),
                if (isCancelled) ...[
                  const SizedBox(width: 8),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(4)), child: const Text("CANCELLED", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold))),
                ]
              ],
            ),
            subtitle: Text(isCancelled ? "Service Interrupted" : "Bus: ${trip.busPlate}", style: TextStyle(color: isCancelled ? Colors.grey[400] : Colors.black54)),
            trailing: isCancelled ? Icon(Icons.block, color: Colors.red[300]) : const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }

  Widget _buildDetailView(DisplayInfoModel trip, DisplayInfoProvider provider, UserProvider user, Color primaryColor) {
    final bool isAuthenticated = user.currentUser != null;
    final bool isGuest = !isAuthenticated || user.currentUser!.id.trim().isEmpty || user.currentUser!.id.toUpperCase().contains('GUEST');
    final bool isRealUser = !isGuest;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 10),
              _buildTripSummary(trip, provider, isRealUser),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text("STOPS SEQUENCE", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, letterSpacing: 1.1)), // 🚀 Theme!
              ),

              if (provider.isLoading && provider.currentItinerary.isEmpty)
                const Center(child: LinearProgressIndicator())
              else
                ...provider.currentItinerary.asMap().entries.map((entry) {
                  int idx = entry.key;
                  StationModel stop = entry.value;
                  bool isLast = idx == provider.currentItinerary.length - 1;

                  String timeDisplay = "${stop.minutesFromStartStation ?? 0} min";
                  if (stop.hasPassed) timeDisplay = "Passed";
                  else if (stop.liveEtaMinutes != null) timeDisplay = "${stop.liveEtaMinutes} min (Live)";

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(stop.hasPassed ? Icons.check_circle : Icons.radio_button_checked, size: 18, color: stop.hasPassed ? Colors.grey : primaryColor), // 🚀 Theme!
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
                            decoration: BoxDecoration(color: stop.hasPassed ? Colors.grey[200] : primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), // 🚀 Theme!
                            child: Text(timeDisplay, style: TextStyle(color: stop.hasPassed ? Colors.grey : primaryColor, fontWeight: FontWeight.bold, fontSize: 11)), // 🚀 Theme!
                          ),
                        ],
                      ),
                      if (!isLast)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Container(height: 30, width: 2, color: stop.hasPassed ? Colors.grey[300] : primaryColor.withOpacity(0.3)), // 🚀 Theme!
                        ),
                    ],
                  );
                }),
              const SizedBox(height: 20),
            ],
          ),
        ),
        if (!trip.isCancelled) _buildTrackButton(trip, user, isGuest),
      ],
    );
  }

  Widget _buildTripSummary(DisplayInfoModel trip, DisplayInfoProvider provider, bool isRealUser) {
    final bool currentlyFavorite = provider.favoriteTrips.any((t) => t.id == trip.id);
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

  Widget _buildTrackButton(DisplayInfoModel trip, UserProvider user, bool isGuest) {
    return Padding(
      padding: const EdgeInsets.all(20),
      // 🚀 Removed the manual styling block! AppTheme dictates this is SORETRAS Green now.
      child: ElevatedButton(
        onPressed: () async {
          final String userId = isGuest ? "GUEST-TEMPORARY" : user.currentUser!.id;
          context.read<DisplayInfoProvider>().setTrackedStation(widget.stationId);
          bool success = await Provider.of<RotationProvider>(context, listen: false).activateAndTrack(trip.id!, widget.stationId, userId);
          if (success) Navigator.pop(context);
        },
        child: const Text("CONFIRM & TRACK"),
      ),
    );
  }
}