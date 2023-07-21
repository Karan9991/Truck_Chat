import 'package:chat/home_screen.dart';
import 'package:chat/utils/constants.dart';
import 'package:chat/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:chat/chat/chat_list.dart';
import 'package:chat/chat/conversation_data.dart';
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
            _buildDialogOption(
                DialogStrings.MARK_AS_READ, DialogStrings.THE_NEW_MESSAGE_ICON,
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
            _buildDialogOption(
                DialogStrings.MARK_AS_UNREAD, DialogStrings.UNREAD_CHATS_WILL,
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
            child: Text(DialogStrings.CANCEL),
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
            _buildDialogOption(DialogStrings.STAR_CHAT,
                DialogStrings.CHATS_THAT_ARE_STARRED_WILL, () async {
              print('Chat Starred');

              // await markAllRead();

              Navigator.of(context).pop();
            }),
            _buildDialogOption(DialogStrings.MARK_CHAT_READ,
                DialogStrings.THE_NEW_MESSAGE_ICON_WILL, () async {
              print('Chat Read');

              // await markAllUnread();

              Navigator.of(context).pop(); // Close the dialog if needed
            }),
          ],
        ),
        actions: [
          TextButton(
            child: Text(DialogStrings.CANCEL),
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
      title: Text(DialogStrings.TERMS_OF_SERVICE),
      content: Text(
        DialogStrings.THIS_APP_IS_PROVIDED_I_AGREED,
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Perform action for "Exit"
            // Use exit(0) for platforms other than iOS
            if (Platform.isIOS) {
              // Handle iOS-specific exit behavior (e.g., display an alert)
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(DialogStrings.EXIT),
                  content: Text(DialogStrings.ARE_YOU_SURE),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(DialogStrings.CANCEL),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(DialogStrings.EXIT),
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
          child: Text(DialogStrings.EXIT),
        ),
        TextButton(
          onPressed: () {
            // Perform action for "I Agree"
            SharedPrefs.setBool(SharedPrefsKeys.TERMS_AGREED, true);
            print('Terms Agreed');
            Navigator.of(context).pop();
          },
          child: Text(DialogStrings.I_AGREE),
        ),
      ],
    ),
  );
}

void showExitConversationDialog(BuildContext context) async {
  bool exitConfirmed = await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(DialogStrings.ALERT),
      content: Text(DialogStrings.DO_YOU_WANT_EXIT_CONVERSATION),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true); // Exit button pressed, return true
          },
          child: Text(DialogStrings.EXIT),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context)
                .pop(false); // Cancel button pressed, return false
          },
          child: Text(DialogStrings.CANCEL),
        ),
      ],
    ),
  );

  if (exitConfirmed == true) {
    // Perform the exit action or navigate to the previous screen
    Navigator.of(context).pop(); // Go back to the previous screen
  }
}

void showPrivateChatDialog(BuildContext context, bool isPrivateChatEnabled) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(isPrivateChatEnabled
            ? DialogStrings.PRIVATE_CHAT_ENABLED
            : DialogStrings.PRIVATE_CHAT_DISABLED),
        content: Text(isPrivateChatEnabled
            ? DialogStrings.PRIVATE_CHAT_YOU_REQUESTED
            : DialogStrings.PRIVATE_CHAT_YOU_NO_LONGER),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text(DialogStrings.GOT_IT),
          ),
        ],
      );
    },
  );
}

void messageLongPressDialog(BuildContext context, Function() onReportAbuse,
    Function() onIgnoreUser, Function() onStartPrivateChat) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                onReportAbuse(); // Call the callback for Report Abuse action
              },
              child: Text(DialogStrings.REPORT_ABUSE),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                onIgnoreUser(); // Call the callback for Ignore User action
              },
              child: Text(DialogStrings.IGNORE_USER),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                onStartPrivateChat(); // Call the callback for Start Private Chat action
              },
              child: Text(DialogStrings.SEND_PRIVATE_CHAT_REQUEST),
            ),
          ],
        ),
      );
    },
  );
}

void messageLongPressDialogWithoutPrivateChat(
    BuildContext context, Function() onReportAbuse, Function() onIgnoreUser) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                onReportAbuse(); // Call the callback for Report Abuse action
              },
              child: Text(DialogStrings.REPORT_ABUSE),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                onIgnoreUser(); // Call the callback for Ignore User action
              },
              child: Text(DialogStrings.IGNORE_USER),
            ),
          ],
        ),
      );
    },
  );
}

void showReportAbuseSuccessDialog(
    BuildContext context, String title, String subtitle1, String subtitle2) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              subtitle1,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

void showIgnoreUserSuccessDialog(BuildContext context, String title) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

void sendPrivateChatRequest(BuildContext context, String title, String subtitle) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(subtitle),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

