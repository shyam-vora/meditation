class NotificationModel {
  final int? id;
  final String message;
  final String type; // success, warn, info, error
  final DateTime createdOn;

  NotificationModel({
    this.id,
    required this.message,
    required this.type,
    required this.createdOn,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'type': type,
      'created_on': createdOn.toIso8601String(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      message: map['message'],
      type: map['type'],
      createdOn: DateTime.parse(map['created_on']),
    );
  }
}
