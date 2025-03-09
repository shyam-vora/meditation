import 'package:flutter/material.dart';
import 'package:meditation/common/color_extension.dart';
import 'package:meditation/database/app_database.dart';
import 'package:meditation/models/moods_model.dart';
import 'package:fl_chart/fl_chart.dart';

class MoodAnalysisScreen extends StatefulWidget {
  const MoodAnalysisScreen({super.key});

  @override
  State<MoodAnalysisScreen> createState() => _MoodAnalysisScreenState();
}

class _MoodAnalysisScreenState extends State<MoodAnalysisScreen> {
  List<MoodsModel> _moodStats = [];
  int _totalPlays = 0;

  @override
  void initState() {
    super.initState();
    _loadMoodStats();
  }

  Future<void> _loadMoodStats() async {
    final moodStats = await AppDatabase.instance.getMoodsByUsage();
    final totalPlays = await AppDatabase.instance.getTotalMoodsPlayed();
    setState(() {
      _moodStats = moodStats;
      _totalPlays = totalPlays;
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
          'Mood Analysis',
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
      body: RefreshIndicator(
        onRefresh: _loadMoodStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Total Plays',
                          style: TextStyle(
                            color: TColor.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _totalPlays.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_moodStats.isNotEmpty)
                SizedBox(
                  height: 300,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _moodStats
                            .map((e) => e.count)
                            .reduce((a, b) => a > b ? a : b)
                            .toDouble(),
                        barGroups: _moodStats.asMap().entries.map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.count.toDouble(),
                                color: TColor.primary,
                                width: 16,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Rotated(
                                  child: Text(
                                    _moodStats[value.toInt()].name,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                      ),
                    ),
                  ),
                ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _moodStats.length,
                itemBuilder: (context, index) {
                  final mood = _moodStats[index];
                  final percentage = (_totalPlays > 0)
                      ? (mood.count / _totalPlays * 100).toStringAsFixed(1)
                      : '0';
                  return ListTile(
                    leading: mood.assetImagePath != null
                        ? Image.asset(mood.assetImagePath!,
                            width: 40, height: 40)
                        : CircleAvatar(
                            backgroundColor: TColor.primary,
                            child: Text(mood.name[0]),
                          ),
                    title: Text(mood.name),
                    subtitle: Text('Played ${mood.count} times'),
                    trailing: Text('$percentage%'),
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

class Rotated extends StatelessWidget {
  final Widget child;
  const Rotated({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.5,
      child: SizedBox(
        width: 40,
        height: 20,
        child: Center(child: child),
      ),
    );
  }
}
