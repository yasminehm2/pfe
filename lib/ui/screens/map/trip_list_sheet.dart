// lib/ui/screens/map/trip_list_sheet.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../logic/providers/map_provider.dart';
import '../../../logic/providers/auth_provider.dart';
import '../../../data/models/rotation_model.dart';
import '../../../data/models/user_model.dart';

class TripListSheet extends StatefulWidget {
  final String stationName;
  const TripListSheet({super.key, required this.stationName});

  @override
  State<TripListSheet> createState() => _TripListSheetState();
}

class _TripListSheetState extends State<TripListSheet> {
  RotationModel? _selectedTrip; // null = List view, not null = Detail/Itinerary view

  @override
  Widget build(BuildContext context) {
    final mapProvider = context.watch<MapProvider>();
    final authProvider = context.watch<AuthProvider>();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
          _buildHandle(),
          // Toggle Header based on view state
          _buildHeader(
            _selectedTrip == null ? widget.stationName : "Line ${_selectedTrip!.lineNumber} Itinerary",
            isDetail: _selectedTrip != null,
          ),
          const Divider(height: 1),

          Expanded(
            child: _selectedTrip == null
                ? _buildListView(mapProvider)
                : _buildDetailView(_selectedTrip!, mapProvider, authProvider),
          ),
        ],
      ),
    );
  }

  // --- VIEW 1: TRIP LIST ---
  Widget _buildListView(MapProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
    }

    if (provider.selectedStationTrips.isEmpty) {
      return _buildEmptyState("No active trips for this line group.");
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.selectedStationTrips.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final trip = provider.selectedStationTrips[index];
        return _TripTile(
          trip: trip,
          onSelect: (selected) {
            setState(() => _selectedTrip = selected);
            provider.fetchTripItinerary(selected.id!); // Trigger backend itinerary fetch
          },
        );
      },
    );
  }

  // --- VIEW 2: TRIP DETAILS & ITINERARY ---
  Widget _buildDetailView(RotationModel trip, MapProvider provider, AuthProvider auth) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            children: [
              _buildMetricTile(Icons.directions_bus, "Bus Plate", trip.busPlate ?? "N/A"),
              _buildMetricTile(Icons.timer_outlined, "Schedule",
                  "${trip.departureTime ?? '--:--'} → ${trip.arrivalTime ?? '--:--'}"),
              const SizedBox(height: 20),
              const Text(
                "STOPS SEQUENCE",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueAccent, letterSpacing: 1.1),
              ),
              const SizedBox(height: 15),

              if (provider.isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: LinearProgressIndicator(),
                ))
              else
                ...provider.currentItinerary.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var stop = entry.value;
                  return _buildStationStep(
                    stop.nameFr,
                    isFirst: idx == 0,
                    isLast: idx == provider.currentItinerary.length - 1,
                  );
                }),
            ],
          ),
        ),
        _buildConfirmButton(trip, auth),
      ],
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildHeader(String title, {required bool isDetail}) {
    return ListTile(
      leading: isDetail
          ? IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => setState(() => _selectedTrip = null),
      )
          : const Icon(Icons.location_on, color: Colors.red),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close, color: Colors.grey),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildConfirmButton(RotationModel trip, AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 2,
        ),
        onPressed: () {
          // If Guest, we can optionally show the dialog here instead of earlier
          // if (auth.currentUser?.role == UserRole.GUEST) { ... }

          Navigator.pop(context); // Close sheet

          // Action: Here you navigate to your live tracking screen or update map state
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Tracking ${trip.lineNumber} (${trip.busPlate})"),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: const Text(
          "CONFIRM & TRACK BUS",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildMetricTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blueAccent.withOpacity(0.1),
            child: Icon(icon, size: 18, color: Colors.blueAccent),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStationStep(String name, {required bool isFirst, required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 2,
                height: 10,
                color: isFirst ? Colors.transparent : Colors.blueAccent.withOpacity(0.5),
              ),
              Icon(
                isFirst || isLast ? Icons.radio_button_checked : Icons.circle,
                size: isFirst || isLast ? 18 : 12,
                color: Colors.blueAccent,
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast ? Colors.transparent : Colors.blueAccent.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isFirst || isLast ? FontWeight.bold : FontWeight.normal,
                  color: isFirst || isLast ? Colors.black87 : Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() => Center(
    child: Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 45,
      height: 5,
      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
    ),
  );

  Widget _buildEmptyState(String msg) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.bus_alert_outlined, size: 50, color: Colors.grey[300]),
        const SizedBox(height: 10),
        Text(msg, style: const TextStyle(color: Colors.grey)),
      ],
    ),
  );
}

// --- TILE COMPONENT ---

class _TripTile extends StatelessWidget {
  final RotationModel trip;
  final Function(RotationModel) onSelect;

  const _TripTile({required this.trip, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelect(trip), // All roles (Guest/Passenger) can view details
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Line Badge
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  trip.lineNumber ?? "??",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 15),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${trip.departureStation} → ${trip.arrivalStation}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Bus Plate: ${trip.busPlate}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}