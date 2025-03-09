import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
    const double gap = 125;
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final double height = constraints.maxHeight;
        return Column(
          mainAxisSize: MainAxisSize.min,
          // children: List.generate(150, (index) => Text("Hello $index")),
          children: [
            const SizedBox(child: UserDetails()),
            SizedBox(
              height: height - gap,
              child: const MoodHistory(),
            ),
          ],
        );
      }),
    );
  }
}
