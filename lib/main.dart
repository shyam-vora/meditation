import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meditation/common/color_extension.dart';
import 'package:meditation/common/common_widget/loading_warpper.dart';
import 'package:meditation/database/app_database.dart';
import 'package:meditation/firebase_options.dart';
import 'package:meditation/screen/login/startup_screen.dart';
import 'package:meditation/screen/main_tabview/main_tabview_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.database;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoading = true;
  late bool isAuthenticated;

  @override
  void initState() {
    super.initState();
    _checkUserAuthentication();
  }

  void _checkUserAuthentication() async {
    await FirebaseAuth.instance.authStateChanges().first;
    setState(() {
      isAuthenticated = FirebaseAuth.instance.currentUser != null;
      isLoading = false;
    });
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
      home: isLoading
          ? const LoadingWrapper()
          : (isAuthenticated
              ? const MainTabViewScreen()
              : const StartUpScreen()),
    );
  }
}
