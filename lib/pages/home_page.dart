import 'package:bin_shield_app/pages/plano_page.dart';
import 'package:bin_shield_app/pages/verificar_zipcode.dart';
import 'package:flutter/material.dart';
import 'cart_page.dart';
import 'rewards.dart';


class HomePage extends StatefulWidget {
  final String? email;

  const HomePage({Key? key, this.email}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const CartPage(

          )),
    );
  }

  void _navigateToReferral() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReferralPage()),
    );
  }

  void _navigateToSchedule() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PlanSelectionScreenPagePage(


      )),
    );
  }

  void _navigateToAddressVerification() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const AddressVerificationScreen()),
    );
  }

  void _navigateToPlanSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlanSelectionScreenPagePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.green[700],
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              'Welcome to Bin Shield',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 20),
            // Grid de Funções
            _buildFunctionGrid(),
          ],
        ),
      ),
    );
  }

  /// Menu lateral (Drawer)
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green[700]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.green[700]),
                ),
                const SizedBox(height: 10),
                FittedBox( // Wrapped with FittedBox
                  fit: BoxFit.scaleDown, // Scale down to fit
                  child: Text(
                    widget.email ?? 'Guest',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Schedule Services'),
            onTap: _navigateToSchedule,
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('View Cart'),
            onTap: _navigateToCart,
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Refer & Earn'),
            onTap: _navigateToReferral,
          ),
        ],
      ),
    );
  }

  /// Grade de cards com as funções
  Widget _buildFunctionGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildFunctionCard(
          title: 'Schedule Cleaning',
          icon: Icons.cleaning_services,
          onTap: _navigateToSchedule,
        ),
        _buildFunctionCard(
          title: 'Verify Your Address',
          icon: Icons.location_on,
          onTap: _navigateToAddressVerification,
        ),
        _buildFunctionCard(
          title: 'View Cart',
          icon: Icons.shopping_cart,
          onTap: _navigateToCart,
        ),
        _buildFunctionCard(
          title: 'Refer & Earn',
          icon: Icons.share,
          onTap: _navigateToReferral,
        ),
      ],
    );
  }

  /// Método para construir cada card de funcionalidade
  Widget _buildFunctionCard(
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.green[700]),
              const SizedBox(height: 10),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}