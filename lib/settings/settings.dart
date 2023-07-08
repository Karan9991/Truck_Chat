import 'package:chat/settings/about.dart';
import 'package:chat/settings/messages.dart';
import 'package:chat/settings/notifcations_and_sound.dart';
import 'package:chat/settings/terms_of_services.dart';
import 'package:chat/utils/constants.dart';
import 'package:flutter/material.dart';
import 'about.dart';
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Constants.SETTINGS),
      ),
      body: ListView(
        children: [
                  Divider(), // Add a divider after the first list item

          ListTile(
            title: Text(Constants.MESSAGES),
            onTap: () {
 Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MessagesScreen()),
              );            },
          ),
                  Divider(), // Add a divider after the first list item

          ListTile(
            title: Text(Constants.NOTIFICATIONS_AND_SOUND),
            onTap: () {
   Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsAndSoundScreen()),
              );            },
          ),
                  Divider(), // Add a divider after the first list item

          ListTile(
            title: Text(Constants.ABOUT),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => About()),
              );
            },
          ),
                  Divider(), // Add a divider after the first list item

          ListTile(
            title: Text(Constants.TERMS_AND_CONDITIONS),
            onTap: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TermsOfServiceScreen()),
              );
            },
          ),
                  Divider(), // Add a divider after the first list item

        ],
      ),
    );
  }
}
