import 'package:flutter/material.dart';
import 'package:meditation/common/color_extension.dart';
import 'package:meditation/database/app_database.dart';
import 'package:meditation/models/notification_model.dart';

class UserNotificationsScreen extends StatelessWidget {
  const UserNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.primary,
        title: Text(
          'Notifications',
          style: TextStyle(color: TColor.primaryTextW),
        ),
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: AppDatabase.instance.getAllNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final notification = snapshot.data![index];
              return ListTile(
                leading: Icon(
                  {
                        'success': Icons.check_circle,
                        'error': Icons.error,
                        'warn': Icons.warning,
                        'info': Icons.info,
                      }[notification.type] ??
                      Icons.notifications,
                  color: {
                    'success': Colors.green,
                    'error': Colors.red,
                    'warn': Colors.orange,
                    'info': Colors.blue,
                  }[notification.type],
                ),
                title: Text(notification.message),
                subtitle: Text(notification.createdOn.toString().split('.')[0]),
              );
            },
          );
        },
      ),
    );
  }
}
