import 'package:bin_shield_app/colors/colors_app.dart';
import 'package:bin_shield_app/pages/payment_square.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlanSelectionScreenPagePage extends StatefulWidget {
  const PlanSelectionScreenPagePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PlanSelectionScreenPagePageState createState() =>
      _PlanSelectionScreenPagePageState();
}

class _PlanSelectionScreenPagePageState
    extends State<PlanSelectionScreenPagePage> {
  bool isRecurring = true;
  int selectedBins = 2;
  String? selectedPlan = "Weekly Cleaning";
  DateTime? selectedDate;

  int blueBinCount = 0;
  int brownBinCount = 0;
  int greenBinCount = 0;

  // Updated prices for testing (0.50 USD for the base plan)
  final Map<String, double> recurringPlanPrices = {
    "Weekly Cleaning": 0.10,
    "Biweekly Cleaning": 0.10,
    "Monthly Cleaning": 0.10,
  };

  final Map<String, double> oneTimePlanPrices = {
    "Weekly Cleaning": 0.50,
    "Biweekly Cleaning": 0.50,
    "Monthly Cleaning": 0.50,
  };

  Map<String, double> get planPrices =>
      isRecurring ? recurringPlanPrices : oneTimePlanPrices;

    double get totalPrice {
    double basePrice = planPrices[selectedPlan] ?? 0.0; // Use double for price
    int additionalBins = blueBinCount + brownBinCount + greenBinCount - 2;
    return basePrice + (additionalBins > 0 ? additionalBins * 0.10 : 0.0); //Additional bins are $0.10
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _sendDataToFirestore() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Usuário não autenticado. Faça login para continuar.')));
        return;
      }

      await firestore.collection('clientes').doc(user.uid).set({
        'planoSelecionado': selectedPlan,
        'valorTotal': totalPrice, // Storing as double
        'dataInicio': selectedDate ?? DateTime.now(),
        'ultimaLimpeza': null,
        'numeroDeBins': blueBinCount + brownBinCount + greenBinCount,
        'tipoPlano': isRecurring ? 'Recurring' : 'One-Time',
        'dataCadastro': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados enviados com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar dados: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsApp.background3,
        iconTheme: const IconThemeData(color: ColorsApp.textColor),
      ),
      backgroundColor: ColorsApp.background3,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Choose Your Plan",
                style: TextStyle(
                  fontSize: screenWidth * 0.07, // Font size adjusted
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                "Select your cleaning frequency and bin count. Recurring plans ensure regular cleanings.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: screenWidth * 0.035, // Font size adjusted
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.02),

              // Botões de Recurring/One-Time
                ToggleButtons(
                  borderWidth: 1,
                  selectedBorderColor: ColorsApp.buttonColor,
                  borderRadius: BorderRadius.circular(8),
                  fillColor: ColorsApp.buttonColor,
                  selectedColor: Colors.white,
                  color: Colors.white,
                  isSelected: [isRecurring, !isRecurring],
                  onPressed: (index) {
                    setState(() {
                      isRecurring = index == 0;
                      selectedPlan = planPrices.keys.first;
                    });
                  },
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.07,
                        vertical: screenWidth * 0.02,
                      ),
                      child: Text(
                        "Recurring",
                        style: TextStyle(fontSize: screenWidth * 0.035),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenWidth * 0.02,
                      ),
                      child: Text(
                        "One-Time",
                        style: TextStyle(fontSize: screenWidth * 0.035),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: screenHeight * 0.02),

              // Cards de Planos
              ...planPrices.keys.map((plan) => GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPlan = plan;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: selectedPlan == plan
                            ? ColorsApp.buttonColor
                            : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: selectedPlan == plan
                                ? ColorsApp.buttonColor.withOpacity(0.6)
                                : Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      margin:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              plan,
                              style: TextStyle(
                                fontSize:
                                    screenWidth * 0.045, // Font size adjusted
                                fontWeight: FontWeight.bold,
                                color: selectedPlan == plan
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              "\$${planPrices[plan]} for 2 bins", // Display the correct price
                              style: TextStyle(
                                fontSize:
                                    screenWidth * 0.035, // Font size adjusted
                                fontWeight: FontWeight.bold,
                                color: selectedPlan == plan
                                    ? Colors.white70
                                    : Colors.green[700],
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              isRecurring
                                  ? "Billed automatically every ${plan.split(' ')[0].toLowerCase()}"
                                  : "One-time payment for immediate service",
                              style: TextStyle(
                                fontSize:
                                    screenWidth * 0.03, // Font size adjusted
                                color: selectedPlan == plan
                                    ? Colors.white70
                                    : Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
              SizedBox(height: screenHeight * 0.02),

              // Seleção de Lixeiras
              Text(
                "Select Bins",
                style: TextStyle(
                  fontSize: screenWidth * 0.05, // Font size adjusted
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildBinSelection("Blue Bin", "For recycling", Icons.delete,
                  Colors.blue, blueBinCount, (value) {
                setState(() {
                  blueBinCount = value;
                });
              }),
              _buildBinSelection(
                  "Brown Bin",
                  "Organic waste (food scraps, etc.)",
                  Icons.delete,
                  Colors.brown,
                  brownBinCount, (value) {
                setState(() {
                  brownBinCount = value;
                });
              }),
              _buildBinSelection(
                  "Green Bin",
                  "For grass, branches, and gardening waste",
                  Icons.delete,
                  Colors.green,
                  greenBinCount, (value) {
                setState(() {
                  greenBinCount = value;
                });
              }),
              SizedBox(height: screenHeight * 0.02),

              // Preço Total
              Text(
                "Total Price: \$${totalPrice < 0 ? 0 : totalPrice.toStringAsFixed(2)}", //Format to 2 decimal places.
                style: TextStyle(
                  fontSize: screenWidth * 0.05, // Font size adjusted
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Botão "Next"
              ElevatedButton(
                onPressed: (blueBinCount + brownBinCount + greenBinCount) < 1
                    ? null
                    : () async {
                        await _sendDataToFirestore();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentScreen(
                              selectedPlan: selectedPlan!,
                              selectedBins:
                                  blueBinCount + brownBinCount + greenBinCount,
                              totalPrice: totalPrice,  //Pass as double
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsApp.buttonColor,
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.015, // Padding adjusted
                    horizontal: screenWidth * 0.08, // Padding adjusted
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Next",
                  style: TextStyle(
                    fontSize: screenWidth * 0.045, // Font size adjusted
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBinSelection(String title, String description, IconData icon,
      Color color, int count, Function(int) onCountChanged) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.01),
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: Row(
          children: [
            Icon(icon,
                color: color, size: MediaQuery.of(context).size.width * 0.07),
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove,
                      size: MediaQuery.of(context).size.width * 0.05),
                  onPressed: () {
                    if (count > 0) {
                      onCountChanged(count - 1);
                    }
                  },
                ),
                Text(
                  "$count",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.045,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add,
                      size: MediaQuery.of(context).size.width * 0.05),
                  onPressed: () {
                    onCountChanged(count + 1);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}