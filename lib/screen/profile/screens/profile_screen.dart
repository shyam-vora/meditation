import 'package:flutter/material.dart';
import 'package:meditation/screen/profile/screens/mood_history.dart';
import 'package:meditation/screen/profile/screens/user_details.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 40, left: 20),
        child: LayoutBuilder(builder: (context, constraints) {
          final height = constraints.maxHeight;
          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 100, child: UserDetails()),
              SizedBox(
                height: height - 100,
                child: const MoodHistory(),
              ),
            ],
          );
        }),
      ),
    );
  }
}
