import 'package:flutter/material.dart';
import 'package:meditation/common/color_extension.dart';
import 'package:meditation/database/app_database.dart';
import 'package:meditation/models/notification_model.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  String _selectedType = 'info';
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    _notifications = await AppDatabase.instance.getAllNotifications();
    setState(() {});
  }

  void _showAddEditDialog([NotificationModel? notification]) {
    if (notification != null) {
      _messageController.text = notification.message;
      _selectedType = notification.type;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: SingleChildScrollView(
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              contentPadding: EdgeInsets.all(16),
              title: Text(
                notification == null ? 'Add Notification' : 'Edit Notification',
                style: TextStyle(
                    color: TColor.primary, fontWeight: FontWeight.bold),
              ),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _messageController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Message',
                            labelStyle: TextStyle(color: TColor.primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: TColor.primary, width: 2),
                            ),
                          ),
                          validator: (value) =>
                              value?.isEmpty == true ? 'Required' : null,
                        ),
                        const SizedBox(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notification Type',
                              style: TextStyle(color: TColor.primary),
                            ),
                            const SizedBox(height: 8),
                            Column(
                              children: ['info', 'success', 'warn', 'error']
                                  .map((type) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: InkWell(
                                          onTap: () {
                                            setState(
                                                () => _selectedType = type);
                                            this.setState(() {});
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            decoration: BoxDecoration(
                                              color: _selectedType == type
                                                  ? _getTypeColor(type)
                                                  : Colors.grey
                                                      .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: _getTypeColor(type),
                                                width: _selectedType == type
                                                    ? 2
                                                    : 1,
                                              ),
                                            ),
                                            child: Text(
                                              type.toUpperCase(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: _selectedType == type
                                                    ? Colors.white
                                                    : _getTypeColor(type),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final notif = NotificationModel(
                        id: notification?.id,
                        message: _messageController.text,
                        type: _selectedType,
                        createdOn: DateTime.now(),
                      );

                      if (notification == null) {
                        await AppDatabase.instance.createNotification(notif);
                      } else {
                        await AppDatabase.instance.updateNotification(notif);
                      }

                      if (mounted) {
                        Navigator.pop(context);
                        _loadNotifications();
                        _messageController.clear();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'info':
        return Colors.blue;
      case 'success':
        return Colors.green;
      case 'warn':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.primary,
        title: Text(
          'Manage Notifications',
          style: TextStyle(color: TColor.primaryTextW),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: TColor.primaryTextW),
            onPressed: () => _showAddEditDialog(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return ListTile(
            title: Text(notification.message),
            subtitle: Text(
              '${notification.type.toUpperCase()} - ${notification.createdOn.toString().split('.')[0]}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showAddEditDialog(notification),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await AppDatabase.instance
                        .deleteNotification(notification.id!);
                    _loadNotifications();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
