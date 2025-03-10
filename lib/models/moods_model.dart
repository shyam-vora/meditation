// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class MoodsModel {
  final int? id;
  final String name;
  final String? assetImagePath;
  final int count;
  final String? selectedTime; // Store time as string "HH:mm"
  final String? selectedDays; // Store days as comma separated string

  MoodsModel({
    this.id,
    required this.name,
    this.assetImagePath,
    this.count = 1,
    this.selectedTime,
    this.selectedDays,
  });

  MoodsModel copyWith({
    int? id,
    String? name,
    String? assetImagePath,
    int? count,
    String? selectedTime,
    String? selectedDays,
  }) {
    return MoodsModel(
      id: id ?? this.id,
      name: name ?? this.name,
      assetImagePath: assetImagePath ?? this.assetImagePath,
      count: count ?? this.count,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedDays: selectedDays ?? this.selectedDays,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'assetImagePath': assetImagePath,
      'count': count,
      'selectedTime': selectedTime,
      'selectedDays': selectedDays,
    };
  }

  factory MoodsModel.fromMap(Map<String, dynamic> map) {
    return MoodsModel(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      assetImagePath: map['assetImagePath'] as String?,
      count: (map['count'] as int?) ?? 1,
      selectedTime: map['selectedTime'] as String?,
      selectedDays: map['selectedDays'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory MoodsModel.fromJson(String source) =>
      MoodsModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
