import 'package:chat/settings/about.dart';
import 'package:chat/settings/messages.dart';
import 'package:chat/settings/notifcations_and_sound.dart';
import 'package:chat/settings/terms_of_services.dart';
import 'package:flutter/material.dart';
import 'about.dart';
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
                  Divider(), // Add a divider after the first list item

          ListTile(
            title: Text('Messages'),
            onTap: () {
 Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MessagesScreen()),
              );            },
          ),
                  Divider(), // Add a divider after the first list item

          ListTile(
            title: Text('Notifications & Sound'),
            onTap: () {
   Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsAndSoundScreen()),
              );            },
          ),
                  Divider(), // Add a divider after the first list item

          ListTile(
            title: Text('About'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => About()),
              );
            },
          ),
                  Divider(), // Add a divider after the first list item

          ListTile(
            title: Text('Terms and Conditions'),
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
