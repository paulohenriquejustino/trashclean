import 'package:flutter/material.dart';

class BiWeeklyCleaningPage extends StatelessWidget {
  const BiWeeklyCleaningPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bi-Weekly Cleaning'),
        backgroundColor: Colors.green[700],
      ),
      body: const Center(
        child: Text(
          'Details about Bi-Weekly Cleaning Service',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}