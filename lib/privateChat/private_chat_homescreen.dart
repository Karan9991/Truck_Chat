// import 'package:chat/privateChat/pendingrequests.dart';
import 'package:chat/privateChat/pending_requests.dart';
import 'package:chat/privateChat/chat.dart';
import 'package:chat/privateChat/chatlist.dart';
import 'package:chat/utils/constants.dart';
import 'package:chat/utils/shared_pref.dart';
import 'package:flutter/material.dart';

class PrivateChatTab extends StatelessWidget {
  final Key key;

  PrivateChatTab({
    required this.key,
  });

  @override
  Widget build(BuildContext context) {
    String? currentUserId = SharedPrefs.getString(SharedPrefsKeys.USER_ID);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            TabBar(
              dividerColor: Colors.blue,
              labelColor: Colors.blue,
              tabs: [
                Tab(text: 'Chats'),
                Tab(text: 'Pending Requests'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ChatListScreen(),
                  // so in below line provided currentUserId 0 if no userId exist. Because app crashes when user doesn't allow
                  //location permission which doesn't allow to register device to get user id.
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
