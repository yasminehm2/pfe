// lib/ui/screens/map/bus_map_screen.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../../../logic/providers/auth_provider.dart';
import '../../../logic/providers/map_provider.dart';
import '../../../logic/providers/tracking_provider.dart';
import '../../../data/models/station_model.dart';
import 'trip_list_sheet.dart';
import 'favorites_screen.dart';

/**
 * 🗺️ THE MAIN MAP SCREEN:
 * Features: Route Planning, Search-to-Trip-List, and Live Tracking with Time Labels.
 */
class BusMapScreen extends StatefulWidget {
  const BusMapScreen({super.key});

  @override
  State<BusMapScreen> createState() => _BusMapScreenState();
}

class _BusMapScreenState extends State<BusMapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounceTimer;
  // 🚀 Track camera triggers to ensure the map jumps to the blue line on start
  int _lastCameraTrigger = 0;

  bool _isPlanningRoute = false;
  bool _isRouteHeaderVisible = false;
  double _mapRotation = 0.0;

  StationModel? _startStation;
  StationModel? _endStation;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MapProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      provider.resetMap();

      // Setup GPS and center map on user
      await _handleLocationPermission();

      // Load stations for the localized area
      if (mounted) {
        provider.fetchNearbyStations(
          _mapController.camera.center.latitude,
          _mapController.camera.center.longitude,
        );
      }
    });
  }

  Future<void> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("GPS is disabled. Please turn it on.")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      _showPermissionDialog();
      return;
    }

    Position pos = await Geolocator.getCurrentPosition();
    _mapController.move(LatLng(pos.latitude, pos.longitude), 14.5);
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Location Required"),
        content: const Text("Please enable location in settings to see nearby bus stops."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () {
            Geolocator.openAppSettings();
            Navigator.pop(context);
          }, child: const Text("Settings")),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _animatedMapRotation(double destRotation) {
    final controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    final animation = Tween<double>(begin: _mapController.camera.rotation, end: destRotation)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    animation.addListener(() => _mapController.rotate(animation.value));
    controller.forward().then((_) {
      setState(() => _mapRotation = destRotation);
      controller.dispose();
    });
  }

  void _onMapMoved(MapCamera camera) {
    if ((camera.rotation - _mapRotation).abs() > 0.1) setState(() => _mapRotation = camera.rotation);
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (!_isPlanningRoute) {
        Provider.of<MapProvider>(context, listen: false).fetchNearbyStations(
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
    final trackingProvider = context.watch<TrackingProvider>();

    // 🚀 AUTO-JUMP LOGIC: Jumps to blue line when tracking starts
    if (mapProvider.cameraMoveTrigger > _lastCameraTrigger) {
      _lastCameraTrigger = mapProvider.cameraMoveTrigger;
      if (mapProvider.liveBusLocation != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(mapProvider.liveBusLocation!, 15.0);
        });
      }
    }

    mapProvider.onStationSelected = (stationId, stationName) {
      if (!mounted) return;
      if (_isPlanningRoute) return;

      _searchFocusNode.unfocus();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => TripListSheet(stationName: stationName, stationId: stationId),
      );
      mapProvider.fetchTripsForStation(stationId);
    };

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(authProvider),
      body: GestureDetector(
        onTap: () => _searchFocusNode.unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: mapProvider.currentViewCenter,
                initialZoom: 14.5,
                onPositionChanged: (position, hasGesture) {
                  _onMapMoved(position);
                  if (hasGesture) _searchFocusNode.unfocus();
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://api.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=34a022d1c08742759c928e3c0f896dbc',
                  userAgentPackageName: 'com.example.bus1',
                ),

                // 🛤️ 1. THE BLUE ROUTE LINE
                if (mapProvider.routePoints.isNotEmpty && (trackingProvider.isTracking || trackingProvider.isLoading))
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: mapProvider.routePoints,
                        color: Colors.blueAccent.withOpacity(0.8),
                        strokeWidth: 6.0,
                      ),
                    ],
                  ),

                // 🚀 2. THE TIME LABELS (Over the blue line)
                if (trackingProvider.isTracking && mapProvider.currentItinerary.isNotEmpty)
                  MarkerLayer(markers: mapProvider.itineraryTimeLabels),

                const CurrentLocationLayer(),

                // 📍 3. STATION PINS & BUS ICON
                MarkerLayer(
                  markers: [
                    ...mapProvider.allMarkers,
                    if (mapProvider.liveBusLocation != null && trackingProvider.isTracking)
                      Marker(
                        point: mapProvider.liveBusLocation!,
                        width: 65, height: 65,
                        child: OverflowBox(
                          maxWidth: 80, maxHeight: 80,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                                child: const Icon(Icons.directions_bus, color: Colors.blue, size: 24),
                              ),
                              const Icon(Icons.arrow_drop_down, color: Colors.blue, size: 20),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            if (mapProvider.isLoading) const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),

            Positioned(
              top: MediaQuery.of(context).padding.top + 10, left: 15, right: 15,
              child: _isRouteHeaderVisible ? _buildRouteHeader(mapProvider) : _buildFloatingSearchBar(mapProvider),
            ),

            Positioned(
              bottom: 25, right: 15,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: "route_toggle", mini: true,
                    backgroundColor: _isPlanningRoute ? Colors.redAccent : Colors.blueAccent,
                    onPressed: () {
                      setState(() {
                        if (_isPlanningRoute) {
                          _isPlanningRoute = false; _isRouteHeaderVisible = false;
                          _startStation = null; _endStation = null; mapProvider.routePoints = [];
                        } else { _isPlanningRoute = true; _isRouteHeaderVisible = true; }
                      });
                    },
                    child: Icon(_isPlanningRoute ? Icons.close : Icons.directions, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton(
                    heroTag: "my_gps", mini: true, backgroundColor: Colors.white,
                    onPressed: () => _handleLocationPermission(),
                    child: const Icon(Icons.my_location, color: Colors.blueAccent),
                  ),
                ],
              ),
            ),

            if (trackingProvider.isTracking || trackingProvider.isLoading)
              Positioned(
                bottom: 35, left: 0, right: 0,
                child: Center(
                  child: FloatingActionButton.extended(
                    heroTag: "stop_tracking",
                    onPressed: () { trackingProvider.stopTracking(); mapProvider.clearTrackingVisuals(); },
                    backgroundColor: Colors.redAccent,
                    icon: const Icon(Icons.stop, color: Colors.white),
                    label: const Text("Stop Tracking", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingSearchBar(MapProvider provider) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: Autocomplete<StationModel>(
          displayStringForOption: (s) => s.nameFr,
          optionsBuilder: (TextEditingValue val) => val.text.isEmpty ? const Iterable<StationModel>.empty() : provider.allStations.where((s) => s.nameFr.toLowerCase().contains(val.text.toLowerCase()) || s.nameAr.contains(val.text)),
          onSelected: (station) {
            _searchFocusNode.unfocus(); _searchController.clear();
            _mapController.move(LatLng(station.latitude, station.longitude), 16.5);
            showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => TripListSheet(stationName: station.nameFr, stationId: station.id));
            provider.fetchTripsForStation(station.id);
          },
          fieldViewBuilder: (ctx, controller, focusNode, onFieldSubmitted) => TextField(
            controller: controller, focusNode: focusNode,
            decoration: InputDecoration(
                hintText: "Search stations...", border: InputBorder.none,
                prefixIcon: IconButton(icon: const Icon(Icons.menu), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
                suffixIcon: const Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.search, color: Colors.blueAccent)),
                contentPadding: const EdgeInsets.symmetric(vertical: 15)
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(AuthProvider auth) {
    final bool isRealUser = auth.isRealUser;
    return Drawer(
      child: Column(
        children: [
          if (isRealUser)
            DrawerHeader(
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1976D2), Color(0xFF64B5F6)])),
              child: SizedBox(width: double.infinity, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                const CircleAvatar(radius: 32, backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: Colors.blueAccent)),
                const SizedBox(height: 12),
                Text(auth.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                Text(auth.displayEmail, style: const TextStyle(fontSize: 14, color: Colors.white70)),
              ])),
            )
          else
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1976D2), Color(0xFF64B5F6)])),
              accountName: Text("Guest Mode", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              accountEmail: Text("Sfax Public Transport"),
              currentAccountPicture: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person_outline, size: 40, color: Colors.blueAccent)),
            ),

          ListTile(leading: const Icon(Icons.map_outlined, color: Colors.blueAccent), title: const Text("Map View"), onTap: () => Navigator.pop(context)),

          if (isRealUser) ...[
            // Registered User Menu
            ListTile(leading: const Icon(Icons.favorite, color: Colors.redAccent), title: const Text("Favourite Trips"), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen())); }),
            const Spacer(),
            ListTile(leading: const Icon(Icons.logout, color: Colors.redAccent), title: const Text("Logout"), onTap: () { context.read<TrackingProvider>().stopTracking(); context.read<MapProvider>().resetMap(); auth.logout(); Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false); }),
          ] else ...[
            // Guest User Menu
            ListTile(leading: const Icon(Icons.login, color: Colors.green), title: const Text("Login"), onTap: () => Navigator.pushNamed(context, '/login')),
            ListTile(leading: const Icon(Icons.person_add, color: Colors.blue), title: const Text("Sign Up"), onTap: () => Navigator.pushNamed(context, '/signup')),
            const Spacer(),
            ListTile(leading: const Icon(Icons.arrow_back, color: Colors.grey), title: const Text("Back to Welcome"), onTap: () { context.read<TrackingProvider>().stopTracking(); context.read<MapProvider>().resetMap(); auth.logout(); Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false); }),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRouteHeader(MapProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15)]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _buildAutocompleteInput(hint: "From Station", icon: Icons.circle_outlined, color: Colors.green, stations: provider.allStations, onSelected: (s) => setState(() => _startStation = s)),
        const SizedBox(height: 8), const Divider(), const SizedBox(height: 8),
        _buildAutocompleteInput(hint: "To Station", icon: Icons.location_on, color: Colors.redAccent, stations: provider.allStations, onSelected: (s) => setState(() => _endStation = s)),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              if (_startStation != null && _endStation != null) {
                setState(() { _isRouteHeaderVisible = false; _isPlanningRoute = false; });
                showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => TripListSheet(stationName: "From ${_startStation!.nameFr} to ${_endStation!.nameFr}", stationId: _startStation!.id));
                provider.fetchTripsForStation(_startStation!.id);
              } else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select stations."))); }
            },
            child: const Text("Find Trips", style: TextStyle(color: Colors.white))
        )),
      ]),
    );
  }

  Widget _buildAutocompleteInput({required String hint, required IconData icon, required Color color, required List<StationModel> stations, required Function(StationModel) onSelected}) {
    return Autocomplete<StationModel>(
      displayStringForOption: (s) => s.nameFr,
      optionsBuilder: (text) => text.text.isEmpty ? const Iterable<StationModel>.empty() : stations.where((s) => s.nameFr.toLowerCase().contains(text.text.toLowerCase())),
      onSelected: (s) { FocusScope.of(context).unfocus(); onSelected(s); },
      fieldViewBuilder: (ctx, ctrl, fn, _) => TextField(controller: ctrl, focusNode: fn, decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: color, size: 20), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)), isDense: true)),
    );
  }
}