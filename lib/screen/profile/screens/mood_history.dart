import 'package:flutter/material.dart';
import 'package:meditation/database/app_database.dart';
import 'package:meditation/models/moods_model.dart';

class MoodHistory extends StatefulWidget {
  const MoodHistory({super.key});

  @override
  State<MoodHistory> createState() => _MoodHistoryState();
}

class _MoodHistoryState extends State<MoodHistory> {
  late Future<List<MoodsModel>?> _moodsList;
  final AppDatabase appDatabase = AppDatabase.instance;

  @override
  void initState() {
    super.initState();
    _moodsList = _getMoodData();
  }

  Future<List<MoodsModel>?> _getMoodData() async {
    try {
      final moods = await AppDatabase.instance.realAllMoods();
      if (moods.isEmpty) {
        return null;
      }
      if (moods.isNotEmpty && moods.first != null) {
        return moods.where((mood) => mood != null).toList() as List<MoodsModel>;
      } else {
        throw Exception("No mood data available");
      }
    } catch (e) {
      throw Exception("Error fetching mood data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _moodsList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (snapshot.hasData) {
          if (snapshot.data == null) {
            return const Text("No History");
          }
          List<MoodsModel> moodsList = snapshot.data!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 30, left: 10, bottom: 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Moods History",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  // shrinkWrap: true,
                  itemCount: moodsList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: moodsList[index].assetImagePath != null
                            ? Image.asset(moodsList[index].assetImagePath!)
                            : null,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              moodsList[index].name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                                onPressed: () async {
                                  if (moodsList[index].id == null) return;
                                  await appDatabase
                                      .delete(moodsList[index].id!);
                                  setState(() {
                                    _moodsList = _getMoodData();
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Deleted Successfully!')));
                                },
                                icon: const Icon(Icons.delete)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        } else {
          return const Center(child: Text('No user data available'));
        }
      },
    );
  }
}
