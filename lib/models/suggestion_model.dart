class Suggestion {
  final int? id;
  final String name;
  final String description;
  final String? imagePath;
  final String type;

  Suggestion({
    this.id,
    required this.name,
    required this.description,
    this.imagePath,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_path': imagePath,
      'type': type,
    };
  }

  factory Suggestion.fromMap(Map<String, dynamic> map) {
    return Suggestion(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      imagePath: map['image_path'],
      type: map['type'],
    );
  }
}
