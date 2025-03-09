import 'package:flutter/material.dart';
import 'package:meditation/common/color_extension.dart';
import 'package:meditation/database/app_database.dart';
import 'package:meditation/models/user_model.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late List<UserModel> _users = [];
  late List<UserModel> _filteredUsers = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final db = await AppDatabase.instance.database;
    final users = await db.query('users');
    setState(() {
      _users = users.map((map) => UserModel.fromMap(map)).toList();
      _filteredUsers = _users;
    });
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _users
          .where((user) =>
              user.name.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: TColor.primary,
        elevation: 0,
        title: Text(
          'All Users',
          style: TextStyle(
            color: TColor.primaryTextW,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: TColor.primaryTextW),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterUsers,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: TColor.primary,
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: TextStyle(color: TColor.primaryTextW),
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(user.email),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
