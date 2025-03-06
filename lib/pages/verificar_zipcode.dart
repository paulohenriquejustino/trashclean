import 'package:bin_shield_app/colors/colors_app.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class AddressVerificationScreen extends StatefulWidget {
  const AddressVerificationScreen({Key? key}) : super(key: key);

  @override
  _AddressVerificationScreenState createState() => _AddressVerificationScreenState();
}

class _AddressVerificationScreenState extends State<AddressVerificationScreen> {
  final _streetAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();

  final double _companyLatitude = 28.415419550652842;
  final double _companyLongitude = -81.47129795370053;
  final double _radiusMiles = 20;

  String _verificationMessage = '';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorsApp.background3,
              ColorsApp.background3,
              ColorsApp.background3,
            ],
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 80.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Image.network(
                      'https://i.ibb.co/JwZXK9pK/cadastro.png',
                      width: size * 0.5,
                      height: size * 0.5,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Verify Your Address',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Enter your address details to check if we serve your area.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                
                    // Street Address Field
                    TextField(
                      controller: _streetAddressController,
                      decoration: InputDecoration(
                        labelText: 'Street Address',
                        labelStyle: const TextStyle(color: Colors.white),
                        hintText: 'Enter your street address',
                        hintStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                
                    // City Field
                    TextField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: 'City',
                        labelStyle: const TextStyle(color: Colors.white),
                        hintText: 'Enter your city',
                        hintStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                
                    // State Field
                    TextField(
                      controller: _stateController,
                      decoration: InputDecoration(
                        labelText: 'State',
                        labelStyle: const TextStyle(color: Colors.white),
                        hintText: 'Enter your state',
                        hintStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                
                    // ZIP Code Field
                    TextField(
                      controller: _zipCodeController,
                      decoration: InputDecoration(
                        labelText: 'ZIP Code',
                        labelStyle: const TextStyle(color: Colors.white),
                        hintText: 'Enter your ZIP Code',
                        hintStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                
                    // Verify Address Button
                    ElevatedButton(
                      onPressed: _verifyAddress,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: const Color(0xFF094230),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                      ),
                      child: const Text(
                        'Verify Address',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 20),
                
                    // Verification Message
                    Text(
                      _verificationMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verifyAddress() async {
    final streetAddress = _streetAddressController.text.trim();
    final city = _cityController.text.trim();
    final state = _stateController.text.trim();
    final zipCode = _zipCodeController.text.trim();

    if (streetAddress.isEmpty || city.isEmpty || state.isEmpty || zipCode.isEmpty) {
      setState(() {
        _verificationMessage = 'Please fill all required fields.';
      });
      return;
    }

    // Obter a localização atual do usuário
    final position = await _getCurrentLocation();

    if (position == null) {
      setState(() {
        _verificationMessage = 'Unable to get your current location. Please try again.';
      });
      return;
    }

    // Calcular a distância entre a sede da empresa e a localização atual
    final distance = Geolocator.distanceBetween(
      _companyLatitude,
      _companyLongitude,
      position.latitude,
      position.longitude,
    );

    final distanceMiles = distance * 0.000621371; // Converter metros para milhas

    if (distanceMiles <= _radiusMiles) {
      setState(() {
        _verificationMessage = 'Your address is within our service area!';
      });
    } else {
      setState(() {
        _verificationMessage = 'Sorry, your address is outside our service area.';
      });
    }
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }
}