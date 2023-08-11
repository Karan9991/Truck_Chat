// // import 'package:chat/privateChat/pendingrequests.dart';
// import 'package:chat/privateChat/pending_requests.dart';
// import 'package:chat/privateChat/chat.dart';
// import 'package:chat/privateChat/chatlist.dart';
// import 'package:chat/utils/constants.dart';
// import 'package:chat/utils/shared_pref.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// class PrivateChatTab extends StatelessWidget {
//   final Key key;
//   final TabController? tabController;
//   final int initialTabIndex; // Add this line

//   PrivateChatTab({
//     required this.key,
//      this.tabController,
//      this.initialTabIndex = 0,
//   });

//   void setupFirebaseMessaging(BuildContext context) {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     String? currentUserId = SharedPrefs.getString(SharedPrefsKeys.USER_ID);

//     return DefaultTabController(
//             initialIndex: initialTabIndex, // Use the provided initialTabIndex

//       length: 2,
//       child: Scaffold(
//         body: Column(
//           children: [
//             TabBar(
//               dividerColor: Colors.blue,
//               labelColor: Colors.blue,
//               tabs: [
//                 Tab(text: 'Chats'),
//                 Tab(text: 'Pending Requests'),
//               ],
//             ),
//             Expanded(
//               child: TabBarView(
//                 children: [
//                   ChatListScreen(),
//                   // so in below line provided currentUserId 0 if no userId exist. Because app crashes when user doesn't allow
//                   //location permission which doesn't allow to register device to get user id.
//                   PendingRequestsScreen(currentUserId: currentUserId ?? '0'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:chat/privateChat/pendingrequests.dart';
import 'package:chat/privateChat/pending_requests.dart';
import 'package:chat/privateChat/chat.dart';
import 'package:chat/privateChat/chatlist.dart';
import 'package:chat/utils/constants.dart';
import 'package:chat/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PrivateChatTab extends StatefulWidget {
  final Key key;

  PrivateChatTab({
    required this.key,
  });

  @override
  _PrivateChatTabState createState() => _PrivateChatTabState();
}

class _PrivateChatTabState extends State<PrivateChatTab> with SingleTickerProviderStateMixin{
 // int _currentIndex = 0; // Store the current index here
late TabController _tabController;

  @override
  void initState() {
    super.initState();
      _tabController = TabController(length: 2, vsync: this);

    //setupFirebaseMessaging();
  }

  @override
  void dispose() {
      _tabController.dispose();

    // TODO: implement dispose
    super.dispose();
  }

  // void setupFirebaseMessaging() {
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     print('-------------fcm fcm');
  //     setState(() {
  //       //_currentIndex = 1; // Change this to the index you want
  //           _tabController.index = 1; // Change this to the index you want

  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    String? currentUserId = SharedPrefs.getString(SharedPrefsKeys.USER_ID);

    return DefaultTabController(
      // initialIndex: _currentIndex,
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            TabBar(
                        controller: _tabController, // Add this line

              dividerColor: Colors.blue,
              labelColor: Colors.blue,
              tabs: [
                Tab(text: 'Chats'),
                Tab(text: 'Pending Requests'),
              ],
            ),
            Expanded(
              child: TabBarView(
                                        controller: _tabController, // Add this line

                children: [
                  ChatListScreen(),
                  PendingRequestsScreen(currentUserId: currentUserId ?? '0'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
