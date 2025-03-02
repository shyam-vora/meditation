import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:meditation/common/color_extension.dart';
import 'package:meditation/common/common_widget/loading_warpper.dart';
import 'package:meditation/database/app_database.dart';
import 'package:meditation/screen/login/startup_screen.dart';
import 'package:meditation/screen/main_tabview/main_tabview_screen.dart';
import 'package:meditation/services/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> continueWithLoggedInSession() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        final userEmail = await AuthService.getLoggedInUserEmail();
        final user = await AppDatabase.instance.getUserByEmail(userEmail!);
        if (user != null) {
          return true;
        }
      }
      return false;
    } catch (e) {
      log(e.toString(), name: 'MyApp');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meditation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "HelveticaNeue",
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
            elevation: 0, backgroundColor: Colors.transparent),
        colorScheme: ColorScheme.fromSeed(seedColor: TColor.primary),
        useMaterial3: false,
      ),
      home: FutureBuilder<bool>(
        future: continueWithLoggedInSession(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return snapshot.data!
                  ? const MainTabViewScreen()
                  : const StartUpScreen();
            }
          }
          return const LoadingWrapper();
        },
      ),
    );
  }
}
