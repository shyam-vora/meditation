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
  Map<String, int> _timeDistribution = {};
  Map<String, int> _dayDistribution = {};

  @override
  void initState() {
    super.initState();
    _loadMoodStats();
  }

  Future<void> _loadMoodStats() async {
    final moodStats = await AppDatabase.instance.getMoodsByUsage();
    final totalPlays = await AppDatabase.instance.getTotalMoodsPlayed();

    Map<String, int> timeMap = {};
    Map<String, int> dayMap = {};

    for (var mood in moodStats) {
      if (mood.selectedTime != null) {
        final hour = _formatTimeToHour(mood.selectedTime!);
        timeMap[hour] = (timeMap[hour] ?? 0) + mood.count;
      }

      if (mood.selectedDays != null) {
        final days = mood.selectedDays!.split(',');
        for (var day in days) {
          dayMap[day] = (dayMap[day] ?? 0) + mood.count;
        }
      }
    }

    setState(() {
      _moodStats = moodStats;
      _totalPlays = totalPlays;
      _timeDistribution = timeMap;
      _dayDistribution = dayMap;
    });
  }

  String _formatTimeToHour(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : hour;
    return '$displayHour $period';
  }

  String _getFullDayName(String shortDay) {
    switch (shortDay.toUpperCase()) {
      case 'SU':
        return 'Sunday';
      case 'M':
        return 'Monday';
      case 'T':
        return 'Tuesday';
      case 'W':
        return 'Wednesday';
      case 'TH':
        return 'Thursday';
      case 'F':
        return 'Friday';
      case 'S':
        return 'Saturday';
      default:
        return shortDay;
    }
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTotalPlaysCard(),
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
              _buildDetailedMoodList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalPlaysCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Total Mood Sessions',
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
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedMoodList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Detailed Mood Analysis',
            style: TextStyle(
              color: TColor.primary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _moodStats.length,
          itemBuilder: (context, index) {
            final mood = _moodStats[index];
            final percentage = _totalPlays > 0
                ? (mood.count / _totalPlays * 100).toStringAsFixed(1)
                : '0';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ExpansionTile(
                leading: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    mood.assetImagePath != null
                        ? Image.asset(mood.assetImagePath!,
                            width: 50, height: 50)
                        : CircleAvatar(
                            radius: 25,
                            backgroundColor: TColor.primary,
                            child: Text(
                              mood.name[0],
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            ),
                          ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: TColor.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$percentage%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text(
                  mood.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'Played ${mood.count} times',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                    child: Column(
                      children: [
                        if (mood.selectedTime != null)
                          _buildDetailRow(
                            icon: Icons.access_time,
                            title: 'Preferred Time',
                            value: mood.selectedTime!,
                          ),
                        if (mood.selectedDays != null) ...[
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            icon: Icons.calendar_today,
                            title: 'Selected Days',
                            value: mood.selectedDays!,
                            wrap: true, // Add this parameter
                          ),
                        ],
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          icon: Icons.bar_chart,
                          title: 'Usage Statistics',
                          value: '$percentage% of total plays',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    bool wrap = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: TColor.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              if (wrap)
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: value.split(',').length > 1
                      ? value.split(',').map((day) {
                          return Chip(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            label: Text(
                              _getFullDayName(day.trim()),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: TColor.primary,
                            padding: const EdgeInsets.all(4),
                          );
                        }).toList()
                      : [
                          Chip(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            label: Text(
                              _getFullDayName("Not Selected"),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: TColor.primary,
                            padding: const EdgeInsets.all(4),
                          )
                        ],
                )
              else
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
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
