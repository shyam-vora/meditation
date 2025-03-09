import 'package:flutter/material.dart';
import 'package:meditation/common/color_extension.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.primary,
        title: Text(
          'Terms & Conditions',
          style: TextStyle(color: TColor.primaryTextW),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: TColor.primaryTextW),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Terms and Conditions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Last updated: [Date]',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Please read these terms and conditions carefully before using the application.',
              style: TextStyle(fontSize: 16),
            ),
            // Add more terms and conditions content here
          ],
        ),
      ),
    );
  }
}
