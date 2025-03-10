import 'dart:io';
import 'package:flutter/material.dart';
import 'package:meditation/common/color_extension.dart';
import 'package:meditation/screen/admin/terms_screen.dart';
import 'package:meditation/screen/login/startup_screen.dart';
import 'package:meditation/screen/profile/screens/mood_history.dart';
import 'package:meditation/screen/profile/screens/user_notifications_screen.dart';
import 'package:meditation/services/auth.dart';
import 'package:meditation/screen/profile/screens/edit_profile_screen.dart';
import 'package:meditation/database/app_database.dart';
import 'package:meditation/models/user_model.dart';
import 'package:meditation/screen/profile/screens/view_suggestions_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StartUpScreen()),
        );
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: TColor.primary,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            color: TColor.primaryTextW,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserNotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          FutureBuilder<UserModel?>(
            future: _userModel,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData && snapshot.data != null) {
                return _buildProfileSection(snapshot.data!);
              }
              return const Text('Failed to load profile');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.mood),
            title: const Text('Mood History'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MoodHistory()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lightbulb_outline),
            title: const Text('Meditation Suggestions'),
            subtitle: const Text('View expert suggestions'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ViewSuggestionsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('v1.0.0'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms & Conditions'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TermsScreen()),
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
