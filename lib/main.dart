import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 📡 Network & Theme
import 'core/network/dio_client.dart';
import 'core/theme/app_theme.dart';

// 🗄️ Repositories
import 'data/repositories/user_repository.dart';
import 'data/repositories/station_repository.dart';
import 'data/repositories/displayInfo_repository.dart';
import 'data/repositories/rotation_repository.dart';

// ⚙️ Providers
import 'providers/user_provider.dart';
import 'providers/station_provider.dart';
import 'providers/displayInfo_provider.dart';
import 'providers/rotation_provider.dart';

// 📱 Screens
import 'ui/screens/auth/welcome_screen.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/auth/signup_screen.dart';
import 'ui/screens/map/bus_map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 📡 SETUP NETWORK & DATA LAYERS:
  final dioClient = DioClient();
  final userRepo = UserRepository(dioClient);
  final stationRepo = StationRepository(dioClient);
  final displayRepo = DisplayInfoRepository(dioClient);
  final trackingRepo = RotationRepository(dioClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider(userRepo)),
        // 🚀 The split providers
        ChangeNotifierProvider(create: (_) => StationProvider(stationRepo)),
        ChangeNotifierProvider(create: (_) => DisplayInfoProvider(displayRepo, stationRepo)),
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
      debugShowCheckedModeBanner: false,

      // 🚀 THE FIX: Applied your custom SORETRAS green theme here!
      theme: AppTheme.lightTheme,

      home: Consumer<UserProvider>(
        builder: (context, user, _) {
          if (user.isAuthenticated) {
            return const BusMapScreen();
          }
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