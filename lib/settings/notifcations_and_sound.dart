import 'package:flutter/material.dart';

class NotificationsAndSoundScreen extends StatefulWidget {
  @override
  _NotificationsAndSoundScreenState createState() =>
      _NotificationsAndSoundScreenState();
}

class _NotificationsAndSoundScreenState
    extends State<NotificationsAndSoundScreen> {
  bool? chatTonesEnabled = true;
  bool? notificationsEnabled = true;
  bool? notificationToneEnabled = true;
  bool? vibrateEnabled = false;
  bool? privateChatEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications and Sound'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildListTile(
            'Chat tones',
            'Plays a sound for incoming and outgoing messages',
            chatTonesEnabled,
            (bool? value) {
              setState(() {
                chatTonesEnabled = value;
              });
            },
          ),
          _buildListTile(
            'Notifications',
            'Notifications are shown for new messages when app is not running',
            notificationsEnabled,
            (bool? value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),
          _buildListTile(
            'Notification tone',
            'Notification messages will play the default system notifications sound.',
            notificationToneEnabled,
            (bool? value) {
              setState(() {
                notificationToneEnabled = value;
              });
            },
          ),
          _buildListTile(
            'Vibrate',
            'Notifications messages will vibrate the device.',
            vibrateEnabled,
            (bool? value) {
              setState(() {
                vibrateEnabled = value;
              });
            },
          ),
          _buildListTile(
            'Private Chat',
            'Allow users to send invitations for private chat enabled.',
            privateChatEnabled,
            (bool? value) {
              setState(() {
                privateChatEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    String title,
    String description,
    bool? value,
    ValueChanged<bool?> onChanged,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          value = !value!;
        });
        onChanged(value);
      },
      child: ListTile(
        title: Text(title,  style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18
    ),),
        subtitle: Text(
          description,
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            
          ),
        ),
        trailing: Checkbox(
          value: value,
          onChanged: onChanged,
            activeColor: Colors.blue, // Set the desired color here

        ),
      ),
    );
  }
}
