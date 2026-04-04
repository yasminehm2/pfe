import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart'; // Needed for the FAB logic
import '../../../logic/providers/map_provider.dart';

class BusMapScreen extends StatefulWidget {
  const BusMapScreen({super.key});

  @override
  State<BusMapScreen> createState() => _BusMapScreenState();
}

class _BusMapScreenState extends State<BusMapScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Fetch stations immediately using the coordinates passed from Login/Signup/Guest
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MapProvider>(context, listen: false);

      // Move camera to the user's specific location immediately
      _mapController.move(provider.currentViewCenter, 14.0);

      provider.fetchNearbyStations(
        provider.currentViewCenter.latitude,
        provider.currentViewCenter.longitude,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const String thunderforestApiKey = 'e02688ad3960419581bb60759e0c80ed';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sfax Bus Network"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final center = _mapController.camera.center;
              context.read<MapProvider>().fetchNearbyStations(
                center.latitude,
                center.longitude,
              );
            },
          )
        ],
      ),
      body: Consumer<MapProvider>(
        builder: (context, mapProvider, child) {
          return Stack(
            children: [
              // --- The Map Layer ---
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: mapProvider.currentViewCenter,
                  initialZoom: 14.0,
                  minZoom: 5.0,
                  maxZoom: 18.0,
                  onMapEvent: (event) {
                    if (event is MapEventMoveEnd) {
                      mapProvider.fetchNearbyStations(
                        event.camera.center.latitude,
                        event.camera.center.longitude,
                      );
                    }
                  },
                ),
                children: [
                  // 1. Map Tiles
                  TileLayer(
                    urlTemplate:
                    'https://tile.thunderforest.com/transport/{z}/{x}/{y}.png?apikey=$thunderforestApiKey',
                    userAgentPackageName: 'com.example.bus1',
                    fallbackUrl:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),

                  // 2. Your Specific Location Icon (Option 1)
                  CurrentLocationLayer(
                    alignPositionOnUpdate: AlignOnUpdate.never, // We handle movement manually via FAB
                    style: LocationMarkerStyle(
                      marker: const DefaultLocationMarker(
                        child: Icon(
                          Icons.person_pin_circle, // 🚀 This is your icon!
                          color: Colors.redAccent,
                          size: 35,
                        ),
                      ),
                      markerSize: const Size(40, 40),
                      showAccuracyCircle: true,
                      accuracyCircleColor: Colors.blueAccent.withOpacity(0.1),
                    ),
                  ),

                  // 3. Bus Station Markers
                  MarkerLayer(
                    markers: mapProvider.allMarkers,
                    rotate: true,
                  ),
                ],
              ),

              // --- Floating Loading Indicator ---
              if (mapProvider.isLoading)
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4)
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          Text("Updating stations...",
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),

      // --- FAB: Re-center on REAL Current Position ---
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          try {
            // 1. Get current real position
            Position position = await Geolocator.getCurrentPosition();
            LatLng newPos = LatLng(position.latitude, position.longitude);

            // 2. Move map and update Provider
            _mapController.move(newPos, 15.0);
            context.read<MapProvider>().updateCenter(newPos);

            // 3. Refresh stations for the new area
            context.read<MapProvider>().fetchNearbyStations(newPos.latitude, newPos.longitude);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Could not determine location")),
            );
          }
        },
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}