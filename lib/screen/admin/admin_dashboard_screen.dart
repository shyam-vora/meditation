import 'package:flutter/material.dart';
import 'package:meditation/common/color_extension.dart';
import 'package:meditation/database/app_database.dart';
import 'package:meditation/models/moods_model.dart';
import 'package:meditation/models/user_model.dart';
import 'package:meditation/screen/admin/terms_screen.dart';
import 'package:meditation/screen/login/startup_screen.dart';
import 'package:meditation/screens/admin/manage_suggestions_screen.dart';
import 'package:meditation/services/auth.dart';
import 'package:meditation/screen/admin/users_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:meditation/screen/admin/mood_analysis_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<List<UserModel>> _usersFuture;
  late Future<List<MoodsModel>> _moodsFuture;
  final String _version = 'v.1.0.0';
  String _adminName = '';
  String _adminEmail = '';

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadAdminInfo();
  }

  void _loadData() {
    _usersFuture = _loadUsers();
    _moodsFuture = AppDatabase.instance.realAllMoods();
  }

  Future<void> _loadAdminInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _adminName = prefs.getString('userName') ?? 'Admin User';
      _adminEmail = prefs.getString('userEmail') ?? 'admin@example.com';
    });
  }

  Future<List<UserModel>> _loadUsers() async {
    final db = await AppDatabase.instance.database;
    final users =
        await db.query('users'); // Remove the where clause to get all users
    return users.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<String> _getStatValue(Future<List<dynamic>> future) async {
    try {
      final list = await future;
      return list.length.toString();
    } catch (e) {
      debugPrint("Error getting stat value: $e");
      return '0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.primary,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: TColor.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      Icons.person,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _adminName,
                    style: TextStyle(
                      color: TColor.primaryTextW,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _adminEmail,
                    style: TextStyle(
                      color: TColor.primaryTextW,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version $_version',
                    style: TextStyle(
                      color: TColor.primaryTextW.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Manage Users'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UsersScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Terms & Conditions'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TermsScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await AuthService.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const StartUpScreen()),
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: TColor.primary,
        elevation: 0,
        title: Text(
          'Admin Dashboard',
          style: TextStyle(
            color: TColor.primaryTextW,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: AnimationLimiter(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, $_adminName',
                    style: TextStyle(
                      color: TColor.primaryTextW,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'System Overview',
                    style: TextStyle(
                      color: TColor.primaryTextW.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimationConfiguration.synchronized(
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Row(
                          children: [
                            _buildEnhancedStatCard(
                              'Total Users',
                              _getStatValue(_usersFuture),
                              Icons.people,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const UsersScreen()),
                                );
                              },
                            ),
                            const SizedBox(width: 15),
                            _buildEnhancedStatCard(
                              'Total Moods',
                              _getStatValue(_moodsFuture),
                              Icons.mood,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Quick Actions',
                        style: TextStyle(
                          color: TColor.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: AnimationLimiter(
                        child: GridView.count(
                          crossAxisCount: 2,
                          padding: const EdgeInsets.all(16),
                          children: AnimationConfiguration.toStaggeredList(
                            duration: const Duration(milliseconds: 375),
                            childAnimationBuilder: (widget) => SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: widget,
                              ),
                            ),
                            children: [
                              _buildEnhancedDashboardItem(
                                'Manage Users',
                                Icons.people_outline,
                                'Manage user accounts and permissions',
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const UsersScreen()),
                                  );
                                },
                              ),
                              _buildEnhancedDashboardItem(
                                'Manage Suggestions',
                                Icons.lightbulb_outline,
                                'Review and manage user suggestions',
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ManageSuggestionsScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildEnhancedDashboardItem(
                                'Terms & Conditions',
                                Icons.description_outlined,
                                'Update app terms and conditions',
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const TermsScreen()),
                                  );
                                },
                              ),
                              _buildEnhancedDashboardItem(
                                'Mood Analytics',
                                Icons.analytics_outlined,
                                'View detailed mood usage analytics',
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const MoodAnalysisScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedStatCard(
    String title,
    Future<String> valueFuture,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: TColor.primaryTextW,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: TColor.primaryTextW,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                FutureBuilder<String>(
                  future: valueFuture,
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? '0',
                      style: TextStyle(
                        color: TColor.primaryTextW,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedDashboardItem(
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: TColor.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
