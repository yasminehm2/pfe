import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/station_provider.dart';
import '../../../providers/displayInfo_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final userProvider = context.read<UserProvider>();
      final LatLng? location = await userProvider.signup(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Email already exists or network error."),
                backgroundColor: Colors.redAccent
            )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<UserProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person)),
                validator: (val) => val!.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
                validator: (val) => !val!.contains("@") ? "Invalid email" : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (val) => val!.length < 6 ? "Minimum 6 chars" : null,
              ),
              const SizedBox(height: 40),

              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: _handleSignup,
                  child: const Text("Register", style: TextStyle(fontSize: 18))
              ),
            ],
          ),
        ),
      ),
    );
  }
}