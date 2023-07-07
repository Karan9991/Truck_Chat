import 'package:chat/home_screen.dart';
import 'package:chat/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:chat/reactivechat/chatlistreact.dart';
import 'package:chat/reactivechat/conversation_data.dart';
import 'package:flutter/services.dart';
import 'dart:io';

void showMarkAsReadUnreadDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogOption('Mark as read',
                "The 'New Message' icon will be removed for all current chats",
                () async {
              print('Mark as read');

              await markAllRead();

              Navigator.of(context).pop();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              );
            }),
            _buildDialogOption('Mark as unread',
                'Unread chats will appear in bold with a "New Message" icon',
                () async {
              print('Mark as unread');

              await markAllUnread();

              Navigator.of(context).pop(); // Close the dialog if needed
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void showMarkAsReadUnreadStarDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogOption('Star this chat',
                "Chats that are starred will no be removed after 1 day of inactivity.",
                () async {
              print('Chat Starred');

             // await markAllRead();

              Navigator.of(context).pop();

         
            }),
            _buildDialogOption('Mark this chat as read',
                "The 'New Message' icon will be removed.",
                () async {
              print('Chat Read');

             // await markAllUnread();

              Navigator.of(context).pop(); // Close the dialog if needed
          
            }),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Widget _buildDialogOption(String title, String subtitle, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}

Future<void> markAllRead() async {
  List<Conversation> storedConversations = await getStoredConversations();

  // Mark all conversations as read
  for (var conversation in storedConversations) {
    conversation.isRead = true;
  }

  // Store the updated conversations
  await storeConversations(storedConversations);
}

Future<void> markAllUnread() async {
  List<Conversation> storedConversations = await getStoredConversations();

  // Mark all conversations as unread
  for (var conversation in storedConversations) {
    conversation.isRead = false;
  }

  // Store the updated conversations
  await storeConversations(storedConversations);
}

// void showTermsOfServiceDialog(BuildContext context) {

//   showDialog(
//     context: context,
//         barrierDismissible: false, 

//     builder: (context) => AlertDialog(
//       title: Text('Terms of Service'),
//       content: Text(
//         'This app is provided as a free service for trucking professionals.\n\nWe want the commercial truck driving community to have a pleasant and useful experience using the free TruckChat app, so that means no posting of explicit or offensive content. More specifically: no porn, no racism, no homophobia, no threats, no abuse, no bullying, no profanity, no sexual advances, no solicitation or personal services. No advertising of your business (unless you are a paying Sponsor of the app with written permission from the developer).\n\nIf we feel you are violating these terms, we can remove your content and/or delete your profile without question. We encourage checking with drivers about weather, traffic, parking, company reviews, delivery discussions between drivers and dispatchers.\n\nBy pressing the "I Agree" button you agree to these terms.',
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             // Perform action for "I Agree"
//             SharedPrefs.setBool('termsAgreed', true);
//             print('Terms Agreed');
//             Navigator.of(context).pop();
//           },
//           child: Text('I Agree'),
//         ),
//         TextButton(
//           onPressed: () {
//             // Perform action for "Exit"
//             // This will close the app
//             SystemChannels.platform.invokeMethod('SystemNavigator.pop');
//           },
//           child: Text('Exit'),
//         ),
//       ],
//     ),
//   );
// }

// ...

void showTermsOfServiceDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Set barrierDismissible to false
    builder: (context) => AlertDialog(
      title: Text('Terms of Service'),
      content: Text(
        'This app is provided as a free service for trucking professionals.\n\nWe want the commercial truck driving community to have a pleasant and useful experience using the free TruckChat app, so that means no posting of explicit or offensive content. More specifically: no porn, no racism, no homophobia, no threats, no abuse, no bullying, no profanity, no sexual advances, no solicitation or personal services. No advertising of your business (unless you are a paying Sponsor of the app with written permission from the developer).\n\nIf we feel you are violating these terms, we can remove your content and/or delete your profile without question. We encourage checking with drivers about weather, traffic, parking, company reviews, delivery discussions between drivers and dispatchers.\n\nBy pressing the "I Agree" button you agree to these terms.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Perform action for "I Agree"
            SharedPrefs.setBool('termsAgreed', true);
            print('Terms Agreed');
            Navigator.of(context).pop();
          },
          child: Text('I Agree'),
        ),
        TextButton(
          onPressed: () {
            // Perform action for "Exit"
            // Use exit(0) for platforms other than iOS
            if (Platform.isIOS) {
              // Handle iOS-specific exit behavior (e.g., display an alert)
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Exit'),
                  content: Text('Are you sure you want to exit the app?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Exit'),
                    ),
                  ],
                ),
              ).then((exitConfirmed) {
                if (exitConfirmed ?? false) {
                  exit(0); // Exit the app
                }
              });
            } else {
              exit(0); // Exit the app directly for platforms other than iOS
            }
          },
          child: Text('Exit'),
        ),
      ],
    ),
  );
}
