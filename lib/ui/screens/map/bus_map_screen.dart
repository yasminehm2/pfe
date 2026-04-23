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

  bool _isPlanningRoute = false;
  bool _isRouteHeaderVisible = false;
  double _mapRotation = 0.0;

  StationModel? _startStation;
  StationModel? _endStation;
  bool _useCurrentLocationAsStart = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MapProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      provider.resetMap();
      provider.fetchNearbyStations(
        provider.currentViewCenter.latitude,
        provider.currentViewCenter.longitude,
      );
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _animatedMapRotation(double destRotation) {
    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    final animation = Tween<double>(begin: _mapController.camera.rotation, end: destRotation)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    animation.addListener(() {
      _mapController.rotate(animation.value);
    });

    controller.forward().then((_) {
      setState(() {
        _mapRotation = destRotation;
      });
      controller.dispose();
    });
  }

  void _onMapMoved(MapCamera camera) {
    if ((camera.rotation - _mapRotation).abs() > 0.1) {
      setState(() {
        _mapRotation = camera.rotation;
      });
    }

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

    mapProvider.onStationSelected = (stationId, stationName) {
      if (!mounted) return;
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
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                ),
                if (mapProvider.routePoints.isNotEmpty &&
                    (trackingProvider.isTracking || trackingProvider.isLoading || _isPlanningRoute))
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: mapProvider.routePoints,
                        color: Colors.blueAccent.withOpacity(0.8),
                        strokeWidth: 6.0,
                      ),
                    ],
                  ),
                const CurrentLocationLayer(),
                MarkerLayer(
                  markers: [
                    ...mapProvider.allMarkers,
                    if (mapProvider.liveBusLocation != null && trackingProvider.isTracking)
                      Marker(
                        point: mapProvider.liveBusLocation!,
                        width: 65,
                        height: 65,
                        child: OverflowBox(
                          maxWidth: 80,
                          maxHeight: 80,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                ),
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

            if (mapProvider.isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),

            if (_mapRotation.abs() > 1.0)
              Positioned(
                top: MediaQuery.of(context).padding.top + 80,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    _animatedMapRotation(0.0);
                  },
                  child: Container(
                    height: 48, width: 48,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)]
                    ),
                    child: Transform.rotate(
                      angle: -_mapRotation * (math.pi / 180),
                      child: const Icon(Icons.explore, color: Colors.redAccent, size: 32),
                    ),
                  ),
                ),
              ),

            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 15,
              right: 15,
              child: _isRouteHeaderVisible
                  ? _buildRouteHeader(mapProvider)
                  : _buildFloatingSearchBar(mapProvider),
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
                      _searchFocusNode.unfocus();
                      setState(() {
                        if (_isPlanningRoute) {
                          _isPlanningRoute = false;
                          _isRouteHeaderVisible = false;
                          mapProvider.routePoints = [];
                        } else {
                          _isPlanningRoute = true;
                          _isRouteHeaderVisible = true;
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
                      _searchFocusNode.unfocus();
                      try {
                        Position pos = await Geolocator.getCurrentPosition();
                        _mapController.move(LatLng(pos.latitude, pos.longitude), 15.5);
                      } catch (e) { debugPrint("GPS Error: $e"); }
                    },
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
                    onPressed: () {
                      trackingProvider.stopTracking();
                      mapProvider.clearTrackingVisuals();
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

  Widget _buildFloatingSearchBar(MapProvider provider) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]
        ),
        child: Autocomplete<StationModel>(
          displayStringForOption: (s) => s.nameFr,
          optionsBuilder: (TextEditingValue textValue) {
            if (textValue.text.isEmpty) return const Iterable<StationModel>.empty();
            return provider.allStations.where((s) =>
            s.nameFr.toLowerCase().contains(textValue.text.toLowerCase()) ||
                s.nameAr.contains(textValue.text)
            );
          },
          onSelected: (station) {
            _searchFocusNode.unfocus();
            _searchController.clear();
            _mapController.move(LatLng(station.latitude, station.longitude), 16.5);
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 30,
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder: (ctx, idx) => const Divider(height: 1),
                      itemBuilder: (ctx, idx) {
                        final StationModel option = options.elementAt(idx);
                        return ListTile(
                          leading: const Icon(Icons.location_on_outlined, color: Colors.blue),
                          title: Text(option.nameFr),
                          subtitle: Text(option.nameAr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
          fieldViewBuilder: (ctx, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                  hintText: "Search stations...",
                  border: InputBorder.none,
                  prefixIcon: IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer()
                  ),
                  suffixIcon: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.search, color: Colors.blueAccent)
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15)
              ),
            );
          },
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
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CircleAvatar(radius: 32, backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: Colors.blueAccent)),
                    const SizedBox(height: 12),
                    Text(auth.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(auth.displayEmail, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                  ],
                ),
              ),
            )
          else
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1976D2), Color(0xFF64B5F6)])),
              accountName: Text("Guest", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              accountEmail: Text("Sfax Public Transport"),
              currentAccountPicture: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person_outline, size: 40, color: Colors.blueAccent)),
            ),

          if (isRealUser) ...[
            ListTile(leading: const Icon(Icons.map_outlined, color: Colors.blueAccent), title: const Text("Map View"), onTap: () => Navigator.pop(context)),
            // 🚀 ONLY REAL USERS SEE THIS BUTTON (No Guest access to Favorites)
            ListTile(leading: const Icon(Icons.favorite, color: Colors.redAccent), title: const Text("Favourite Trips"), onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()));
            }),
            const Spacer(),
            ListTile(leading: const Icon(Icons.logout, color: Colors.redAccent), title: const Text("Logout"), onTap: () {
              context.read<TrackingProvider>().stopTracking();
              context.read<MapProvider>().resetMap();
              auth.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
            }),
          ] else ...[
            ListTile(leading: const Icon(Icons.login, color: Colors.green), title: const Text("Login"), onTap: () {
              context.read<TrackingProvider>().stopTracking();
              context.read<MapProvider>().resetMap();
              Navigator.pushNamed(context, '/login');
            }),
            ListTile(leading: const Icon(Icons.person_add, color: Colors.blue), title: const Text("Sign Up"), onTap: () {
              context.read<TrackingProvider>().stopTracking();
              context.read<MapProvider>().resetMap();
              Navigator.pushNamed(context, '/signup');
            }),
            const Spacer(),
            ListTile(leading: const Icon(Icons.exit_to_app, color: Colors.grey), title: const Text("Exit Guest Mode"), onTap: () {
              context.read<TrackingProvider>().stopTracking();
              context.read<MapProvider>().resetMap();
              auth.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
            }),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAutocompleteInput(
              hint: _useCurrentLocationAsStart ? "My Location" : "From",
              icon: Icons.circle_outlined,
              color: Colors.green,
              isEnabled: !_useCurrentLocationAsStart,
              stations: provider.allStations,
              onSelected: (s) {
                FocusScope.of(context).unfocus();
                setState(() => _startStation = s);
              }
          ),
          CheckboxListTile(
              value: _useCurrentLocationAsStart,
              onChanged: (val) {
                FocusScope.of(context).unfocus();
                setState(() => _useCurrentLocationAsStart = val!);
              },
              title: const Text("Current Location", style: TextStyle(fontSize: 13)),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true
          ),
          const Divider(),
          _buildAutocompleteInput(
              hint: "To",
              icon: Icons.location_on,
              color: Colors.redAccent,
              stations: provider.allStations,
              onSelected: (s) {
                FocusScope.of(context).unfocus();
                setState(() => _endStation = s);
              }
          ),
          const SizedBox(height: 16),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    LatLng? start;
                    if (_useCurrentLocationAsStart) {
                      Position pos = await Geolocator.getCurrentPosition();
                      start = LatLng(pos.latitude, pos.longitude);
                    } else if (_startStation != null) {
                      start = LatLng(_startStation!.latitude, _startStation!.longitude);
                    }
                    if (start != null && _endStation != null) {
                      await provider.getRoute(start, LatLng(_endStation!.latitude, _endStation!.longitude));
                      setState(() => _isRouteHeaderVisible = false);
                    }
                  },
                  child: const Text("Show Road Path")
              )
          ),
        ],
      ),
    );
  }

  Widget _buildAutocompleteInput({
    required String hint, required IconData icon, required Color color, required List<StationModel> stations, required Function(StationModel) onSelected, bool isEnabled = true
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
          decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: color, size: 20), border: InputBorder.none, isDense: true)
      ),
    );
  }
}