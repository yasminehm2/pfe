import 'package:bus1/ui/screens/auth/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/dio_client.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/map_repository.dart';
import 'data/repositories/rotation_repository.dart';
import 'logic/providers/auth_provider.dart';
import 'logic/providers/map_provider.dart';
import 'logic/providers/rotation_provider.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/auth/signup_screen.dart';
import 'ui/screens/map/bus_map_screen.dart';

/**
 * 🚀 THE ENTRY POINT:
 * This is where the app "wakes up."
 */
void main() async {
  // ⚙️ INITIALIZATION: Ensures Flutter services are ready before we start the app.
  WidgetsFlutterBinding.ensureInitialized();

  // 📡 SETUP NETWORK & DATA LAYERS:
  // We create one instance of each to share across the whole app.
  final dioClient = DioClient();
  final authRepo = AuthRepository(dioClient);
  final mapRepo = MapRepository(dioClient);
  final trackingRepo = RotationRepository(dioClient);

  runApp(
    /**
     * 🏗️ THE MULTIPROVIDER:
     * This "wraps" the entire app. It injects our three main logic controllers
     * (Auth, Map, Tracking) so any screen can access them at any time.
     */
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepo)),
        ChangeNotifierProvider(create: (_) => MapProvider(mapRepo)),
        ChangeNotifierProvider(create: (_) => RotationProvider(trackingRepo)),
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
      debugShowCheckedModeBanner: false, // Removes the red "Debug" ribbon
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true, // Uses the modern Google design system
      ),

      /**
       * 🧠 SMART ROUTING LOGIC:
       * The 'home' property uses a Consumer to watch the AuthProvider.
       */
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          // 1. If the user session is active (Login/Guest), send them to the Map.
          if (auth.isAuthenticated) {
            return const BusMapScreen();
          }
          // 2. If no one is logged in, start at the Welcome/Branding Screen.
          return const WelcomeScreen();
        },
      ),

      // 🗺️ NAVIGATION ROUTES:
      // These are "shortcuts" used for moving between screens.
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/map': (context) => const BusMapScreen(),
      },
    );
  }
}