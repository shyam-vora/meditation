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
          children: [
            const Text(
              'Terms and Conditions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Last updated: ${DateTime.now().toString().split(' ')[0]}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Welcome to Meditation App',
              'By accessing or using our meditation application, you agree to be bound by these Terms and Conditions. If you disagree with any part of these terms, you may not access the application.',
            ),
            _buildSection(
              'User Account',
              'To use certain features of the app, you must register for an account. You agree to provide accurate information and keep it updated. You are responsible for maintaining the confidentiality of your account.',
            ),
            _buildSection(
              'Privacy Policy',
              'Your privacy is important to us. Our Privacy Policy explains how we collect, use, and protect your personal information. By using the app, you agree to our Privacy Policy.',
            ),
            _buildSection(
              'Content Usage',
              'All meditation content, including audio, video, and text, is protected by copyright. You may not distribute, modify, or use the content for commercial purposes without our permission.',
            ),
            _buildSection(
              'Subscription Terms',
              'Premium features require a subscription. Subscriptions automatically renew unless cancelled. Prices are subject to change with notice. Refunds are handled according to platform policies.',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
