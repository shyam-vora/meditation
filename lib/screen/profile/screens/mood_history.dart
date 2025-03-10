import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meditation/common/color_extension.dart';
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
      return moods;
    } catch (e) {
      debugPrint("Error fetching mood data: $e");
      throw Exception("Error fetching mood data: $e");
    }
  }

  String _formatDays(String? days) {
    if (days == null) return 'No days selected';
    final List<String> daysList = days.split(',');
    return daysList.join(' · ');
  }

  String _formatTime(String? time) {
    if (time == null) return 'No time set';
    final parts = time.split(':');
    if (parts.length != 2) return time;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour > 12 ? hour - 12 : hour;
    return '$formattedHour:${minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: TColor.primaryTextW),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Mood History',
          style: TextStyle(color: TColor.primaryTextW),
        ),
      ),
      body: FutureBuilder<List<MoodsModel>?>(
        future: _moodsList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No History"));
          }

          List<MoodsModel> moodsList = snapshot.data!;
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.history, color: TColor.primary, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      "Moods History",
                      style: TextStyle(
                        color: TColor.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: moodsList.length,
                  itemBuilder: (context, index) {
                    final mood = moodsList[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (mood.assetImagePath != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      mood.assetImagePath!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mood.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Played ${mood.count} times',
                                        style: TextStyle(
                                          color: TColor.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    if (mood.id == null) return;
                                    await appDatabase.delete(mood.id!);
                                    setState(() {
                                      _moodsList = _getMoodData();
                                    });
                                    if (mounted) {
                                      context.showSnackbar(
                                        message: 'Deleted Successfully!',
                                        type: SnackbarMessageType.success,
                                      );
                                    }
                                  },
                                  icon: Icon(Icons.delete,
                                      color: Colors.red[300]),
                                ),
                              ],
                            ),
                            if (mood.selectedTime != null ||
                                mood.selectedDays != null)
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (mood.selectedTime != null)
                                      Row(
                                        children: [
                                          Icon(Icons.access_time,
                                              size: 16, color: TColor.primary),
                                          const SizedBox(width: 8),
                                          Text(
                                            _formatTime(mood.selectedTime),
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    if (mood.selectedTime != null &&
                                        mood.selectedDays != null)
                                      const SizedBox(height: 8),
                                    if (mood.selectedDays != null)
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today,
                                              size: 16, color: TColor.primary),
                                          const SizedBox(width: 8),
                                          Text(
                                            _formatDays(mood.selectedDays),
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
