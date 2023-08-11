import 'package:chat/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat/utils/navigator_key.dart';

class GlobalNavigator {
  static showAlertDialog(String title, String content) {
    showDialog(
      barrierDismissible: false,
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
  // title:
  //             Text('New Private Chat Request!', style: TextStyle(fontSize: 20)),
  //         content: SingleChildScrollView(
  //           child: Text(
  //               "You've received a private chat request. Open your Private Chat and view pending requests to see who wants to connect.",
  //               style: TextStyle(fontSize: 16)),
  //         ),     
               actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //              // Navigator.pop(context, true);
  //               navigatorKey.currentState?.popUntil((route) {
  //   return route.settings.name == '/';
  // });
  //             },
  //             child: Text('Cancel'),
  //           ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);

            Navigator.push(
              context,
              MaterialPageRoute(

                builder: (context) => HomeScreen(initialTabIndex: 4,),
              ),
            );
              },
              child: const Text('View Requests'),
            ),
          ],
        );
      },
    );
  }
}
