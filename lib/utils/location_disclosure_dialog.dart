// import 'package:flutter/material.dart';

// class LocationDisclosureDialog extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text('Location Access'),
//       content: Text(
//         'This app collects location data to provide city and province information related to chat messages, '
//         'while you are using it. This '
//         'data is not used for any other purposes and is not shared with third '
//         'parties.',
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           child: Text('OK'),
//         ),
//       ],
//     );
//   }
// }

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
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);

             
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
