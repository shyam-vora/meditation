import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meditation/common/color_extension.dart';
import 'package:meditation/screen/profile/screens/mood_history.dart';
import 'package:meditation/services/auth.dart';
import 'package:meditation/screen/profile/screens/edit_profile_screen.dart';
import 'package:meditation/database/app_database.dart';
import 'package:meditation/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sign out')),
        );
      }
    }
  }

  void _navigateToEditProfile() async {
    final user = await _userModel;
    if (user != null && mounted) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfileScreen(user: user),
        ),
      );
      if (result == true) {
        // Refresh profile data
        setState(() {
          _userModel = _getUserData();
        });
      }
    }
  }

  Widget _buildProfileSection(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: TColor.primary,
            backgroundImage: user.profilePicture != null
                ? FileImage(File(user.profilePicture!))
                : null,
            child: user.profilePicture == null
                ? Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 32, color: Colors.white),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _navigateToEditProfile,
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _handleSignOut,
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[100],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double gap = screenSize.height * 0.15;

    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenSize.height,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: screenSize.height * 0.1),
              FutureBuilder<UserModel?>(
                future: _userModel,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    return _buildProfileSection(snapshot.data!);
                  }
                  return const Text('Failed to load profile');
                },
              ),
              SizedBox(
                height: screenSize.height * 0.7 - gap,
                child: const MoodHistory(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
