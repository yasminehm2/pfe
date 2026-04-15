import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import '../../../logic/providers/auth_provider.dart';
import '../../../logic/providers/map_provider.dart';
import '../../../data/models/station_model.dart';
import 'trip_list_sheet.dart';

class BusMapScreen extends StatefulWidget {
  const BusMapScreen({super.key});

  @override
  State<BusMapScreen> createState() => _BusMapScreenState();
}

class _BusMapScreenState extends State<BusMapScreen> {
  final MapController _mapController = MapController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _debounceTimer;

  bool _isPlanningRoute = false;
  StationModel? _startStation;
  StationModel? _endStation;
  bool _useCurrentLocationAsStart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MapProvider>();

      provider.onStationSelected = (stationId, stationName) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => TripListSheet(stationName: stationName),
        );
        provider.fetchTripsForStation(stationId);
      };
    });
  }

  void _onMapMoved(MapCamera camera) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (!_isPlanningRoute) {
        context.read<MapProvider>().fetchNearbyStations(
          camera.center.latitude,
          camera.center.longitude,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final mapProvider = context.watch<MapProvider>();

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(authProvider),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: mapProvider.currentViewCenter,
              initialZoom: 14.5,
              onMapReady: () {
                mapProvider.fetchNearbyStations(
                  mapProvider.currentViewCenter.latitude,
                  mapProvider.currentViewCenter.longitude,
                );
              },
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) _onMapMoved(position);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
              ),
              const CurrentLocationLayer(),
              if (mapProvider.routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: mapProvider.routePoints,
                      color: Colors.blueAccent.withOpacity(0.9),
                      strokeWidth: 5.0,
                      borderColor: Colors.blue.shade900,
                      borderStrokeWidth: 2.0,
                    ),
                  ],
                ),
              MarkerLayer(markers: mapProvider.allMarkers),
            ],
          ),

          if (mapProvider.isLoading)
            const Center(
              child: Card(
                elevation: 4,
                shape: CircleBorder(),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                ),
              ),
            ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 15,
            right: 15,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isPlanningRoute
                  ? _buildRouteHeader(mapProvider)
                  : _buildFloatingSearchBar(mapProvider),
            ),
          ),

          Positioned(
            bottom: 25,
            right: 15,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "route_toggle",
                  mini: true,
                  backgroundColor: _isPlanningRoute ? Colors.redAccent : Colors.blueAccent,
                  onPressed: () {
                    setState(() {
                      if (_isPlanningRoute) {
                        _isPlanningRoute = false;
                        mapProvider.routePoints = [];
                      } else {
                        _isPlanningRoute = true;
                      }
                    });
                  },
                  child: Icon(_isPlanningRoute ? Icons.close : Icons.directions, color: Colors.white),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: "my_gps",
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () async {
                    try {
                      Position pos = await Geolocator.getCurrentPosition();
                      _mapController.move(LatLng(pos.latitude, pos.longitude), 15.5);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Ensure Location is enabled")),
                      );
                    }
                  },
                  child: const Icon(Icons.my_location, color: Colors.blueAccent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(AuthProvider auth) {
    final bool isGuest = auth.currentUser == null;
    final String name = isGuest ? "Guest User" : auth.currentUser!.name;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(isGuest ? "Sfax Public Transport" : auth.currentUser!.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                isGuest ? Icons.person_outline : Icons.person,
                size: 40,
                color: Colors.blueAccent,
              ),
            ),
          ),

          // 🚀 LOGGED-IN USER OPTIONS
          if (!isGuest) ...[
            ListTile(
              leading: const Icon(Icons.map_outlined, color: Colors.blueAccent),
              title: const Text("Map View"),
              onTap: () {
                Navigator.pop(context); // Close drawer
                // Optional: reset map to initial state
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border, color: Colors.redAccent),
              title: const Text("Favorites"),
              onTap: () {
                // Navigate to your favorites screen (to be implemented)
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Favorites feature coming soon!")),
                );
              },
            ),
          ],

          // 🚀 GUEST USER OPTIONS
          if (isGuest) ...[
            ListTile(
              leading: const Icon(Icons.login, color: Colors.green),
              title: const Text("Log In"),
              onTap: () => Navigator.pushNamed(context, '/login'),
            ),
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.orange),
              title: const Text("Sign Up"),
              onTap: () => Navigator.pushNamed(context, '/signup'),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined, color: Colors.blueGrey),
              title: const Text("Back to Welcome"),
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
            ),
          ],

          const Spacer(),
          const Divider(),

          // 🚀 LOGOUT (Only for Users)
          if (!isGuest)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Logout"),
              onTap: () {
                auth.logout();
                Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
              },
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFloatingSearchBar(MapProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]
      ),
      child: Autocomplete<StationModel>(
        displayStringForOption: (s) => s.nameFr,
        optionsBuilder: (textValue) => textValue.text.isEmpty
            ? const Iterable<StationModel>.empty()
            : provider.allStations.where((s) => s.nameFr.toLowerCase().contains(textValue.text.toLowerCase())),
        onSelected: (station) {
          _mapController.move(LatLng(station.latitude, station.longitude), 16.5);
          provider.onStationSelected?.call(station.id, station.nameFr);
        },
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: "Search stations in Sfax...",
              border: InputBorder.none,
              prefixIcon: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.blueGrey),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer()
              ),
              suffixIcon: const Icon(Icons.search, color: Colors.blueAccent),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRouteHeader(MapProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15)]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAutocompleteInput(
            hint: _useCurrentLocationAsStart ? "My Current Location" : "From station",
            icon: Icons.circle_outlined,
            color: Colors.green,
            isEnabled: !_useCurrentLocationAsStart,
            stations: provider.allStations,
            onSelected: (s) => setState(() => _startStation = s),
          ),
          CheckboxListTile(
            value: _useCurrentLocationAsStart,
            onChanged: (val) => setState(() => _useCurrentLocationAsStart = val!),
            title: const Text("Use Current Location", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
          const Divider(height: 10),
          _buildAutocompleteInput(
            hint: "To destination",
            icon: Icons.location_on,
            color: Colors.redAccent,
            stations: provider.allStations,
            onSelected: (s) => setState(() => _endStation = s),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12)
              ),
              onPressed: () async {
                LatLng? start;
                if (_useCurrentLocationAsStart) {
                  Position pos = await Geolocator.getCurrentPosition();
                  start = LatLng(pos.latitude, pos.longitude);
                } else if (_startStation != null) {
                  start = LatLng(_startStation!.latitude, _startStation!.longitude);
                }

                if (start != null && _endStation != null) {
                  await provider.getRoute(start, LatLng(_endStation!.latitude, _endStation!.longitude));
                  _mapController.move(start, 15.0);
                  setState(() => _isPlanningRoute = false);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select both start and end locations")),
                  );
                }
              },
              child: const Text("Show Road Path", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutocompleteInput({
    required String hint,
    required IconData icon,
    required Color color,
    required List<StationModel> stations,
    required Function(StationModel) onSelected,
    bool isEnabled = true
  }) {
    return Autocomplete<StationModel>(
      displayStringForOption: (s) => s.nameFr,
      optionsBuilder: (text) => (text.text.isEmpty || !isEnabled)
          ? const Iterable<StationModel>.empty()
          : stations.where((s) => s.nameFr.toLowerCase().contains(text.text.toLowerCase())),
      onSelected: onSelected,
      fieldViewBuilder: (ctx, ctrl, fn, _) => TextField(
        controller: ctrl,
        focusNode: fn,
        enabled: isEnabled,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: color, size: 20),
            border: InputBorder.none,
            isDense: true
        ),
      ),
    );
  }
}