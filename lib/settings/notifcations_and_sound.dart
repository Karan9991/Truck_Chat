import 'package:chat/utils/constants.dart';
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
        title: Text(Constants.NOTIFICATIONS_AND_SOUND),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildListTile(
           Constants.CHAT_TONES,
           Constants.PLAY_A_SOUND,
            chatTonesEnabled,
            (bool? value) {
              setState(() {
                chatTonesEnabled = value;
              });
            },
          ),
          _buildListTile(
           Constants.NOTIFICATIONS,
           Constants.NOTIFICATIONS_ARE_SHOWN,
            notificationsEnabled,
            (bool? value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),
          _buildListTile(
           Constants.NOTIFICATION_TONE,
            Constants.NOTIFICATION_MESSAGES_WILL_PLAY,
            notificationToneEnabled,
            (bool? value) {
              setState(() {
                notificationToneEnabled = value;
              });
            },
          ),
          _buildListTile(
           Constants.VIBRATE,
            Constants.NOTIFICATION_MESSAGES_WILL_VIBRATE,
            vibrateEnabled,
            (bool? value) {
              setState(() {
                vibrateEnabled = value;
              });
            },
          ),
          _buildListTile(
            Constants.PRIVATE_CHAT,
            Constants.ALLOW_USERS_TO,
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
