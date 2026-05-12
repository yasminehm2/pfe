import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/station_provider.dart';
import '../../../providers/displayInfo_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final userProvider = context.read<UserProvider>();
      final LatLng? location = await userProvider.login(
          _emailController.text.trim(),
          _passwordController.text.trim()
      );

      if (location != null && mounted) {
        final stationProvider = context.read<StationProvider>();
        final displayProvider = context.read<DisplayInfoProvider>();

        stationProvider.resetMap();
        displayProvider.clearTrackingVisuals();
        stationProvider.updateCenter(location);

        if (userProvider.currentUser != null) {
          await displayProvider.loadFavorites(userProvider.currentUser!.id);
        }

        Navigator.pushNamedAndRemoveUntil(context, '/map', (route) => false);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login failed."), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<UserProvider>().isLoading;
    final primaryColor = Theme.of(context).colorScheme.primary; // 🚀 Extracting theme!

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Icon(Icons.account_circle, size: 80, color: primaryColor), // 🚀 Using Theme!
              const SizedBox(height: 10),
              const Text("Welcome Back", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email", prefixIcon: const Icon(Icons.email)),
                validator: (val) => val!.isEmpty ? "Enter email" : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
                validator: (val) => val!.length < 6 ? "Minimum 6 chars" : null,
              ),
              const SizedBox(height: 40),

              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                // 🚀 All manual styling removed! AppTheme takes over completely!
                  onPressed: _handleLogin,
                  child: const Text("Sign In")
              ),
            ],
          ),
        ),
      ),
    );
  }
}