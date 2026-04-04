import 'package:bus1/ui/screens/auth/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/dio_client.dart';
import 'core/utils/location_helper.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/map_repository.dart';
import 'data/repositories/tracking_repository.dart';
import 'logic/providers/auth_provider.dart';
import 'logic/providers/map_provider.dart';
import 'logic/providers/tracking_provider.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/auth/signup_screen.dart'; // Ensure this is imported // Ensure this is imported
import 'ui/screens/map/bus_map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dioClient = DioClient();
  final authRepo = AuthRepository(dioClient);
  final mapRepo = MapRepository(dioClient);
  final trackingRepo = TrackingRepository(dioClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepo)),
        ChangeNotifierProvider(create: (_) => MapProvider(mapRepo)),
        ChangeNotifierProvider(create: (_) => TrackingProvider(trackingRepo)),
      ],
      child: const SfaxTransportApp(),
    ),
  );
}

class SfaxTransportApp extends StatelessWidget {
  const SfaxTransportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sfax Transport',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // SMART ROUTING LOGIC
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          // 1. If the user is logged in, go straight to the Map
          if (auth.isAuthenticated) {
            return const BusMapScreen();
          }
          // 2. Otherwise, always start at the Welcome Screen
          return const WelcomeScreen();
        },
      ),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/map': (context) => const BusMapScreen(),
      },
    );
  }
}