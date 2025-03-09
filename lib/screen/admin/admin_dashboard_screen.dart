import 'package:flutter/material.dart';
import 'package:meditation/common/color_extension.dart';
import 'package:meditation/database/app_database.dart';
import 'package:meditation/models/moods_model.dart';
import 'package:meditation/models/user_model.dart';
import 'package:meditation/screen/login/startup_screen.dart';
import 'package:meditation/services/auth.dart';
import 'package:meditation/screen/admin/users_screen.dart';
import 'package:meditation/screen/admin/admin_home_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<List<UserModel>> _usersFuture;
  late Future<List<MoodsModel?>> _moodsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _usersFuture = _loadUsers();
    _moodsFuture = AppDatabase.instance.realAllMoods();
  }

  Future<List<UserModel>> _loadUsers() async {
    final db = await AppDatabase.instance.database;
    final users =
        await db.query('users'); // Remove the where clause to get all users
    return users.map((map) => UserModel.fromMap(map)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.primary,
      appBar: AppBar(
        backgroundColor: TColor.primary,
        title: Text(
          'Admin Dashboard',
          style: TextStyle(
            color: TColor.primaryTextW,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const StartUpScreen()),
                (_) => false,
              );
            },
            icon: Icon(Icons.logout, color: TColor.primaryTextW),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Overview',
                    style: TextStyle(
                      color: TColor.primaryTextW,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildStatCard(
                        'Total Users',
                        _usersFuture.then((users) => users.length.toString()),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const UsersScreen()),
                          );
                        },
                      ),
                      const SizedBox(width: 20),
                      _buildStatCard(
                        'Total Moods',
                        _moodsFuture.then((moods) => moods.length.toString()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 200,
                    child: AdminHomeScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, Future<String> valueFuture,
      {VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: TColor.primaryTextW,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              FutureBuilder<String>(
                future: valueFuture,
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? '0',
                    style: TextStyle(
                      color: TColor.primaryTextW,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
