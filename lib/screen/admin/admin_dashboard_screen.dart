import 'package:flutter/material.dart';
import 'package:meditation/common/color_extension.dart';
import 'package:meditation/common/common_widget/round_button.dart';
import 'package:meditation/database/app_database.dart';
import 'package:meditation/models/moods_model.dart';
import 'package:meditation/models/user_model.dart';
import 'package:meditation/screen/login/startup_screen.dart';
import 'package:meditation/services/auth.dart';

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
    final users = await db.query('users', where: 'is_admin != 1');
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
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Recent Users',
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  FutureBuilder<List<UserModel>>(
                    future: _usersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No users found'));
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final user = snapshot.data![index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: TColor.primary,
                              child: Text(
                                user.name[0].toUpperCase(),
                                style: TextStyle(color: TColor.primaryTextW),
                              ),
                            ),
                            title: Text(user.name),
                            subtitle: Text(user.email),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, Future<String> valueFuture) {
    return Expanded(
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
    );
  }
}
