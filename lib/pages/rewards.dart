import 'package:bin_shield_app/colors/colors_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReferralPage extends StatelessWidget {
  const ReferralPage({Key? key}) : super(key: key);

  // Function to copy the referral link
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link copied to clipboard!')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    // Fictitious referral link
    const String referralLink = 'https://yoursite.com/invite/123456';

    return Scaffold(
      backgroundColor: ColorsApp.background3,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: ColorsApp.background3,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image at the top
              Image.network(
                'https://i.ibb.co/JwZXK9pK/cadastro.png',
                width: size * 0.5,
                height: size * 0.5,
              ),
              const SizedBox(height: 20),
              const Text(
                'Refer your friends and earn discounts!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ColorsApp.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Share your referral link:',
                style: TextStyle(
                  fontSize: 16,
                  color: ColorsApp.textColor,
                ),
              ),
              const SizedBox(height: 10),
              // Container with the referral link
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorsApp.background3,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ColorsApp.textColor, width: 2),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        referralLink,
                        style: TextStyle(
                          fontSize: 16,
                          color: ColorsApp.textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: ColorsApp.background3),
                      onPressed: () => _copyToClipboard(context, referralLink),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Accumulated discounts section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorsApp.background3,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ColorsApp.textColor, width: 2),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Accumulated discounts:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColorsApp.textColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '\$50.00',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'For every friend who signs up using your link, you earn \$10.00 in discounts!',
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorsApp.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}