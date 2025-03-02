import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meditation/database/app_database.dart';
import 'package:meditation/models/user_model.dart';
import 'package:meditation/screen/login/startup_screen.dart';
import 'package:meditation/services/auth.dart';

class UserDetails extends StatefulWidget {
  const UserDetails({super.key});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  late Future<UserModel?> _userModel;
  @override
  void initState() {
    super.initState();
    _userModel = _getUserData();
  }

  Future<UserModel?> _getUserData() async {
    try {
      final String? loggedInUserEmail =
          await AuthService.getLoggedInUserEmail();
      if (loggedInUserEmail != null) {
        return await AppDatabase.instance.getUserByEmail(loggedInUserEmail);
      } else {
        return null;
      }
    } catch (e) {
      log(e.toString(), name: 'UserDetails');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _userModel, // Fetch user data
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data != null) {
          UserModel user = snapshot.data!; // Get user data
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // Shadow color
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(2, 4), // Position of the shadow
                ),
              ],
            ),
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 20, left: 12, right: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Hello, ${user.name}',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${user.email}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: logOut,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text("Logout"),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: Text('Error Fetching User Data'));
        }
      },
    );
  }

  Future logOut() async {
    await AuthService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const StartUpScreen(),
      ),
      // (_) => true
    );
  }
}
