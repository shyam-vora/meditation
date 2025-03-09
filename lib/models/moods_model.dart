// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class MoodsModel {
  final int? id;
  final String name;
  final String? assetImagePath;
  final int count; // New field

  MoodsModel({
    this.id,
    required this.name,
    this.assetImagePath,
    this.count = 1, // Default to 1
  });

  MoodsModel copyWith({
    int? id,
    String? name,
    String? assetImagePath,
    int? count,
  }) {
    return MoodsModel(
      id: id ?? this.id,
      name: name ?? this.name,
      assetImagePath: assetImagePath ?? this.assetImagePath,
      count: count ?? this.count,
    );
  }

  // Method to generate current timestamp when the object is created
  static String getCurrentTimestamp() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'assetImagePath': assetImagePath,
      'count': count,
    };
  }

  factory MoodsModel.fromMap(Map<String, dynamic> map) {
    return MoodsModel(
      id: map['id'] as int,
      name: map['name'] as String,
      assetImagePath: map['assetImagePath'] as String,
      count: map['count'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory MoodsModel.fromJson(String source) =>
      MoodsModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
