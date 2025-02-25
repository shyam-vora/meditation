import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meditation/models/user_model.dart';
import 'package:meditation/screen/login/sign_up_screen.dart';
import 'package:meditation/screen/login/startup_screen.dart';
import 'package:meditation/services/auth/auth_repository.dart';

class UserDetails extends StatefulWidget {
  const UserDetails({super.key});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  late Future<UserModel> _userModel;
  @override
  void initState() {
    super.initState();
    _userModel = _getUserData();
  }

  Future<UserModel> _getUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return await AuthRepository().getUserData(user.uid);
      } else {
        throw Exception("No authenticated user");
      }
    } catch (e) {
      throw Exception("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: _userModel, // Fetch user data
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          UserModel user = snapshot.data!; // Get user data
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'Hello, ${user.name}',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                user.email,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                  onPressed: logOut,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text("Logout")),
            ],
          );
        } else {
          return const Center(child: Text('No moods history found'));
        }
      },
    );
  }

  Future logOut() async {
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const StartUpScreen(),
      ),
      // (_) => true
    );
  }
}
