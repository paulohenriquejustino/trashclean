import 'package:bin_shield_app/colors/colors_app.dart';
import 'package:bin_shield_app/pages/plano_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Future<Map<String, dynamic>?> _fetchUserPlan() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('clientes')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      return doc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  DateTime _calculateNextCollectionDate(DateTime startDate, String plan) {
    switch (plan) {
      case "Weekly Cleaning":
        return startDate.add(const Duration(days: 7));
      case "Biweekly Cleaning":
        return startDate.add(const Duration(days: 14));
      case "Monthly Cleaning":
        return startDate.add(const Duration(days: 30));
      default:
        return startDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsApp.background3,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: ColorsApp.background3,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserPlan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text(
                'No plan selected yet.',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          final userPlan = snapshot.data!;
          final startDate = (userPlan['dataInicio'] as Timestamp).toDate();
          final nextCollectionDate = _calculateNextCollectionDate(
              startDate, userPlan['planoSelecionado']);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Text(
                    'Detailes about your plan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  color: ColorsApp.background3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.white, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Plan: ${userPlan['planoSelecionado']}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildInfoRow('Total Bins', userPlan['numeroDeBins'].toString()),
                        _buildInfoRow('Plan Type', userPlan['tipoPlano']),
                        _buildInfoRow('Start Date', _formatDate(startDate)),
                        _buildInfoRow('Next Collection', _formatDate(nextCollectionDate)),
                        _buildInfoRow('Total Price', '\$${userPlan['valorTotal']}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PlanSelectionScreenPagePage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsApp.background3,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  child: const Text(
                    'Change Plan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Thank you for choosing BinShield!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w700),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
