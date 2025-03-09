import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:meditation/common/color_extension.dart';
import 'package:meditation/common/common_widget/loading_warpper.dart';
import 'package:meditation/database/app_database.dart';
import 'package:meditation/models/user_model.dart';
import 'package:meditation/screen/admin/admin_dashboard_screen.dart';
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

  Future<String> continueWithLoggedInSession() async {
    try {
      //TODO: remove me
      // await AppDatabase.instance.insertUser(
      //   UserModel(
      //     name: "krupal",
      //     email: "admin@system.com1",
      //     password: "admin123",
      //     isAdmin: false,
      //   ),
      // );

      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        final userEmail = await AuthService.getLoggedInUserEmail();
        final user = await AppDatabase.instance.getUserByEmail(userEmail!);
        if (user != null) {
          final isAdmin = user.isAdmin;
          if (isAdmin) {
            return 'admin';
          } else {
            return 'user';
          }
        }
      }
      return 'not-logged-in';
    } catch (e) {
      log(e.toString(), name: 'MyApp');
      return 'not-logged-in';
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
      home: FutureBuilder<String>(
        future: continueWithLoggedInSession(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return {
                    'user': const MainTabViewScreen(),
                    'admin': const AdminDashboardScreen(),
                    'not-logged-in': const StartUpScreen(),
                  }[snapshot.data] ??
                  const StartUpScreen();
            }
          }
          return const LoadingWrapper();
        },
      ),
    );
  }
}
