import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../../../providers/user_provider.dart';
import '../../../providers/station_provider.dart';
import '../../../providers/displayInfo_provider.dart';
import '../../../providers/rotation_provider.dart';
import '../../../data/models/station_model.dart';
import 'trip_list_sheet.dart';
import 'favorites_screen.dart';
import '../../widgets/arrival_alert_banner.dart';

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
  int _lastCameraTrigger = 0;

  bool _isPlanningRoute = false;
  bool _isRouteHeaderVisible = false;
  double _mapRotation = 0.0;
  bool _isFollowingBus = false;

  StationModel? _startStation;
  StationModel? _endStation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      context.read<StationProvider>().resetMap();
      context.read<DisplayInfoProvider>().clearTrackingVisuals();

      await _handleLocationPermission();
      if (mounted) {
        context.read<StationProvider>().fetchNearbyStations(
          _mapController.camera.center.latitude,
          _mapController.camera.center.longitude,
        );
      }
    });
  }

  Future<void> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("GPS is disabled. Please turn it on.")));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) _showPermissionDialog();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) _showPermissionDialog(isPermanent: true);
      return;
    }

    Position pos = await Geolocator.getCurrentPosition();
    _mapController.move(LatLng(pos.latitude, pos.longitude), 14.5);
  }

  void _showPermissionDialog({bool isPermanent = false}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final primaryColor = Theme.of(context).colorScheme.primary;
          return AlertDialog(
            title: const Text("Location Required"),
            content: Text(isPermanent
                ? "You have permanently disabled location. You must allow it in your phone settings to use the map."
                : "To see bus stops near you, you have to allow location permission."),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  if (isPermanent) {
                    await Geolocator.openAppSettings();
                  } else {
                    await _handleLocationPermission();
                  }
                },
                child: Text("OK", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
              ),
            ],
          );
        }
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onMapMoved(MapCamera camera) {
    if ((camera.rotation - _mapRotation).abs() > 0.1) setState(() => _mapRotation = camera.rotation);
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (!_isPlanningRoute) {
        context.read<StationProvider>().fetchNearbyStations(camera.center.latitude, camera.center.longitude);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final stationProvider = context.watch<StationProvider>();
    final displayProvider = context.watch<DisplayInfoProvider>();
    final trackingProvider = context.watch<RotationProvider>();

    // 🚀 We extract your Theme colors here!
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;
    final secondaryColor = colorScheme.secondary;

    if (displayProvider.cameraMoveTrigger > _lastCameraTrigger) {
      _lastCameraTrigger = displayProvider.cameraMoveTrigger;
      _isFollowingBus = true;
      if (displayProvider.liveBusLocation != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _mapController.move(displayProvider.liveBusLocation!, 15.5));
      }
    }

    if (trackingProvider.isTracking && _isFollowingBus && displayProvider.liveBusLocation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _mapController.move(displayProvider.liveBusLocation!, 15.5));
    }

    stationProvider.onStationSelected = (stationId, stationName) {
      if (!mounted) return;
      if (_isPlanningRoute) return;

      _searchFocusNode.unfocus();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => TripListSheet(stationName: stationName, stationId: stationId),
      );
      displayProvider.fetchTripsForStation(stationId);
    };

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(userProvider, primaryColor, secondaryColor),
      body: GestureDetector(
        onTap: () => _searchFocusNode.unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: stationProvider.currentViewCenter,
                initialZoom: 14.5,
                onPositionChanged: (position, hasGesture) {
                  _onMapMoved(position);
                  if (hasGesture && _isFollowingBus) setState(() => _isFollowingBus = false);
                  if (hasGesture) _searchFocusNode.unfocus();
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://api.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=34a022d1c08742759c928e3c0f896dbc',
                  userAgentPackageName: 'com.example.bus1',
                ),

                if (stationProvider.routePoints.isNotEmpty && (trackingProvider.isTracking || displayProvider.isLoading))
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: stationProvider.routePoints,
                        color: primaryColor.withOpacity(0.8), // 🚀 Using Theme!
                        strokeWidth: 6.0,
                      ),
                    ],
                  ),

                if (trackingProvider.isTracking && displayProvider.currentItinerary.isNotEmpty)
                  MarkerLayer(markers: displayProvider.itineraryTimeLabels),

                const CurrentLocationLayer(),

                MarkerLayer(
                  markers: [
                    ...stationProvider.allMarkers,
                    if (displayProvider.liveBusLocation != null && trackingProvider.isTracking)
                      Marker(
                        point: displayProvider.liveBusLocation!,
                        width: 65, height: 65,
                        child: OverflowBox(
                          maxWidth: 80, maxHeight: 80,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                                child: Icon(Icons.directions_bus, color: primaryColor, size: 24), // 🚀 Using Theme!
                              ),
                              Icon(Icons.arrow_drop_down, color: primaryColor, size: 20), // 🚀 Using Theme!
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            if (stationProvider.isLoading || displayProvider.isLoading)
              Center(child: CircularProgressIndicator(color: primaryColor)), // 🚀 Using Theme!

            const ArrivalAlertBanner(),

            Positioned(
              top: MediaQuery.of(context).padding.top + 10, left: 15, right: 15,
              child: _isRouteHeaderVisible ? _buildRouteHeader(stationProvider, displayProvider, primaryColor) : _buildFloatingSearchBar(stationProvider, displayProvider, primaryColor),
            ),

            Positioned(
              bottom: trackingProvider.isTracking ? 110 : 25,
              right: 15,
              child: Column(
                children: [
                  if (trackingProvider.isTracking && displayProvider.liveBusLocation != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FloatingActionButton(
                        heroTag: "follow_bus",
                        mini: true,
                        backgroundColor: _isFollowingBus ? Colors.orange : Colors.white,
                        onPressed: () {
                          setState(() => _isFollowingBus = !_isFollowingBus);
                          if (_isFollowingBus) _mapController.move(displayProvider.liveBusLocation!, 15.5);
                        },
                        child: Icon(_isFollowingBus ? Icons.videocam : Icons.videocam_off, color: _isFollowingBus ? Colors.white : Colors.orange),
                      ),
                    ),

                  FloatingActionButton(
                    heroTag: "route_toggle", mini: true,
                    backgroundColor: _isPlanningRoute ? Colors.redAccent : primaryColor, // 🚀 Using Theme!
                    onPressed: () {
                      setState(() {
                        if (_isPlanningRoute) {
                          _isPlanningRoute = false; _isRouteHeaderVisible = false;
                          _startStation = null; _endStation = null; stationProvider.routePoints = [];
                        } else { _isPlanningRoute = true; _isRouteHeaderVisible = true; }
                      });
                    },
                    child: Icon(_isPlanningRoute ? Icons.close : Icons.directions, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton(
                    heroTag: "my_gps", mini: true, backgroundColor: Colors.white,
                    onPressed: () => _handleLocationPermission(),
                    child: Icon(Icons.my_location, color: primaryColor), // 🚀 Using Theme!
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
                    onPressed: () {
                      setState(() => _isFollowingBus = false);
                      trackingProvider.stopTracking();
                      stationProvider.routePoints = [];
                      displayProvider.clearTrackingVisuals();
                    },
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

  Widget _buildFloatingSearchBar(StationProvider stationProvider, DisplayInfoProvider displayProvider, Color primaryColor) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: Autocomplete<StationModel>(
          displayStringForOption: (s) => s.nameFr,
          optionsBuilder: (TextEditingValue val) => val.text.isEmpty ? const Iterable<StationModel>.empty() : stationProvider.allStations.where((s) => s.nameFr.toLowerCase().contains(val.text.toLowerCase()) || s.nameAr.contains(val.text)),
          onSelected: (station) {
            _searchFocusNode.unfocus(); _searchController.clear();
            _mapController.move(LatLng(station.latitude, station.longitude), 16.5);
            showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => TripListSheet(stationName: station.nameFr, stationId: station.id));
            displayProvider.fetchTripsForStation(station.id);
          },
          fieldViewBuilder: (ctx, controller, focusNode, onFieldSubmitted) => TextField(
            controller: controller, focusNode: focusNode,
            decoration: InputDecoration(
                hintText: "Search stations...", border: InputBorder.none,
                prefixIcon: IconButton(icon: const Icon(Icons.menu), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
                suffixIcon: Padding(padding: const EdgeInsets.only(right: 12), child: Icon(Icons.search, color: primaryColor)), // 🚀 Using Theme!
                contentPadding: const EdgeInsets.symmetric(vertical: 15)
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(UserProvider user, Color primaryColor, Color secondaryColor) {
    final bool isRealUser = user.isRealUser;
    return Drawer(
      child: Column(
        children: [
          if (isRealUser)
            DrawerHeader(
              decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryColor, secondaryColor])), // 🚀 Using Theme!
              child: SizedBox(width: double.infinity, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                CircleAvatar(radius: 32, backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: primaryColor)),
                const SizedBox(height: 12),
                Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                Text(user.displayEmail, style: const TextStyle(fontSize: 14, color: Colors.white70)),
              ])),
            )
          else
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryColor, secondaryColor])), // 🚀 Using Theme!
              accountName: const Text("Guest Mode", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              accountEmail: const Text("Sfax Public Transport"),
              currentAccountPicture: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person_outline, size: 40, color: primaryColor)),
            ),

          ListTile(leading: Icon(Icons.map_outlined, color: primaryColor), title: const Text("Map View"), onTap: () => Navigator.pop(context)),

          if (isRealUser) ...[
            ListTile(leading: const Icon(Icons.favorite, color: Colors.redAccent), title: const Text("Favourite Trips"), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen())); }),
            const Spacer(),
            ListTile(leading: const Icon(Icons.logout, color: Colors.redAccent), title: const Text("Logout"), onTap: () { context.read<RotationProvider>().stopTracking(); context.read<StationProvider>().resetMap(); context.read<DisplayInfoProvider>().clearTrackingVisuals(); user.logout(); Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false); }),
          ] else ...[
            ListTile(leading: Icon(Icons.login, color: primaryColor), title: const Text("Login"), onTap: () => Navigator.pushNamed(context, '/login')),
            ListTile(leading: Icon(Icons.person_add, color: primaryColor), title: const Text("Sign Up"), onTap: () => Navigator.pushNamed(context, '/signup')),
            const Spacer(),
            ListTile(leading: const Icon(Icons.arrow_back, color: Colors.grey), title: const Text("Back to Welcome"), onTap: () { context.read<RotationProvider>().stopTracking(); context.read<StationProvider>().resetMap(); context.read<DisplayInfoProvider>().clearTrackingVisuals(); user.logout(); Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false); }),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRouteHeader(StationProvider stationProvider, DisplayInfoProvider displayProvider, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15)]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _buildAutocompleteInput(hint: "From Station", icon: Icons.circle_outlined, color: primaryColor, stations: stationProvider.allStations, onSelected: (s) => setState(() => _startStation = s)),
        const SizedBox(height: 8), const Divider(), const SizedBox(height: 8),
        _buildAutocompleteInput(hint: "To Station", icon: Icons.location_on, color: Colors.redAccent, stations: stationProvider.allStations, onSelected: (s) => setState(() => _endStation = s)),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton(
          // 🚀 Notice we removed style: ElevatedButton.styleFrom(...). It inherently uses AppTheme now!
            onPressed: () {
              if (_startStation != null && _endStation != null) {
                setState(() { _isRouteHeaderVisible = false; _isPlanningRoute = false; });
                showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => TripListSheet(stationName: "From ${_startStation!.nameFr} to ${_endStation!.nameFr}", stationId: _startStation!.id));
                displayProvider.fetchTripsForStation(_startStation!.id);
              } else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select stations."))); }
            },
            child: const Text("Find Trips")
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