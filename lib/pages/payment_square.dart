import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:square_in_app_payments/in_app_payments.dart';
import 'package:square_in_app_payments/models.dart';
import 'package:http/http.dart' as http;
import 'package:bin_shield_app/pages/home_page.dart';
import 'package:bin_shield_app/colors/colors_app.dart';
import 'package:flutter/services.dart'; // Import for PlatformException

class PaymentScreen extends StatefulWidget {
  final String selectedPlan;
  final int selectedBins;
  final double totalPrice;

  const PaymentScreen({
    Key? key,
    required this.selectedPlan,
    required this.selectedBins,
    required this.totalPrice,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  // IMPORTANT: Use environment variables or a configuration file for these.
  //  For testing, you can use the Sandbox values.
  final String squareApplicationId = "sq0idp-2USic0pNLgpPjEO8W89eFQ"; // Replace with your actual application ID
  final String squareAccessToken = "EAAAl5TAZRTbCN27reS7UQNmiHNt0dn9Qo3Cx7Fya7K0IGXyhC8Sn-2UKoS2Pcdy"; // Replace with your actual access token - Secure this in production!
  final String squareLocationId = "LSB0H89DCVKPH"; // Replace with your actual location ID

  //  Replace with your backend URL.  This is where you'll send the nonce.
  final String backendUrl = "http://localhost:3001"; // Example: your Node.js server

  @override
  void initState() {
    super.initState();
    _initSquare();
  }

  void _initSquare() async {
    // Use async here
    try {
      await InAppPayments
          .setSquareApplicationId(squareApplicationId); // await the initialization
      print("✅ Square SDK inicializado em PRODUÇÃO!");
    } catch (e) {
      print("❌ Error initializing Square SDK: $e");
      _showError(
          "Falha ao inicializar o sistema de pagamento. Tente novamente mais tarde."); // User-friendly message
    }
  }


  Future<void> _startCardPayment() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await InAppPayments.startCardEntryFlow(
        onCardNonceRequestSuccess: _paymentSuccess,
        onCardEntryCancel: _paymentCanceled,
      );
    } on PlatformException catch (ex) {
      //Specific Square error handling
      if (ex.code == "USAGE_ERROR") {
        String? message = ex.message;
        if (message != null) {
          if (message.contains("Already in progress")) {
            _showError("Um pagamento já está em andamento.");
            return;  // Stop execution here.  Very important!
          } else if (message.contains("Not initialized")) {
            _showError("O sistema de pagamento não foi inicializado corretamente.");
          } else {
            _showError("Erro ao iniciar o fluxo de pagamento: $message");
          }
        } else {
            _showError("Erro desconhecido ao iniciar pagamento."); // Fallback
        }
      } else {
        _showError(
            "Erro ao iniciar o pagamento com cartão: ${ex.message ?? ex.code}");
      }
    } catch (e) {
      print("❌ Error starting card payment flow: $e");
      _showError(
          "Erro ao iniciar o pagamento com cartão. Verifique sua conexão e tente novamente."); // User-friendly message
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }



  void _paymentSuccess(CardDetails result) {
    InAppPayments.completeCardEntry(
      onCardEntryComplete: () {
        _sendPaymentToServer(result.nonce);  // Send nonce to *your* server
      },
    );
  }

  Future<void> _sendPaymentToServer(String nonce) async {
      // Now call YOUR backend, not Square directly
     await _processPayment(nonce);
  }

    Future<void> _processPayment(String nonce) async {
    final url = Uri.parse("$backendUrl/process-payment"); // Use your backend endpoint
    final headers = {
      "Content-Type": "application/json",
    };

    final body = jsonEncode({
      "nonce": nonce,
      "amount": (widget.totalPrice * 100).toInt(), // Amount in cents/smallest unit
      "currency": "USD",  // Or BRL, make sure it's consistent with your Square account.
      // Add any other data you need on the backend, like customer info
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);

      print("Backend API Response: ${responseData}"); //Log response from YOUR backend

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        _showSuccess("Pagamento processado com sucesso!");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const HomePage())); // Use pushReplacement
      } else {
          //Handle errors from YOUR BACKEND
          String errorMessage = responseData['message'] ?? 'Erro desconhecido ao processar o pagamento.';
          throw Exception(errorMessage);
      }

    } catch (e) {
      print("❌ Error processing payment: $e"); // Log the detailed error
      String userErrorMessage =
          "Erro ao processar pagamento: ${e is Exception ? e.toString().split(':')[0] : 'Tente novamente.'}"; // Extract general error type
      if (e is http.ClientException || e is SocketException) {
        userErrorMessage =
            "Falha na conexão com o servidor de pagamento. Verifique sua internet e tente novamente.";
      } else if (e is FormatException) {
        userErrorMessage =
            "Erro ao processar resposta do pagamento. Tente novamente mais tarde.";
      }
      _showError(userErrorMessage); // Show user-friendly error message
    } finally {
      if(mounted) {
          setState(() {
            _isLoading = false;
          });
      }
    }
  }



  void _paymentCanceled() {
    if (mounted) { // Check if the widget is still in the tree
        setState(() {
            _isLoading = false; // Ensure loading indicator is off.
        });
    }
    _showError("Pagamento cancelado pelo usuário.");
  }


   void _showError(String message) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = message;
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Erro no Pagamento",
                style: TextStyle(color: Colors.redAccent)),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the AlertDialog
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsApp.background2,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: ColorsApp.background2,
        title: const Text('Pagamento', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text("Plano: ${widget.selectedPlan}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const Divider(),
                      Text("Quantidade de Bins: ${widget.selectedBins}",
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 10),
                      Text("Preço Total: R\$${widget.totalPrice}",
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _startCardPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Pagar com Cartão',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}