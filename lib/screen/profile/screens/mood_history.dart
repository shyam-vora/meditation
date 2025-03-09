import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meditation/common/show_snackbar_extension.dart';
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
                padding: EdgeInsets.symmetric(vertical: 40, horizontal: 10),
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  moodsList[index].name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Played ${moodsList[index].count} times',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                                onPressed: () async {
                                  if (moodsList[index].id == null) return;
                                  await appDatabase
                                      .delete(moodsList[index].id!);
                                  setState(() {
                                    _moodsList = _getMoodData();
                                  });

                                  context.showSnackbar(
                                    message: 'Deleted Successfully!',
                                    type: SnackbarMessageType.success,
                                  );
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
          return const Center(
              child: Text(
            'No moods history found.',
          ));
        }
      },
    );
  }
}
