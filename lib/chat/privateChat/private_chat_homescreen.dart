// import 'package:chat/privateChat/pendingrequests.dart';
import 'package:chat/chat/privateChat/pending_requests.dart';
import 'package:chat/chatdemo2/chat.dart';
import 'package:chat/chatdemo2/chatlist.dart';
import 'package:flutter/material.dart';

class PrivateChatTab extends StatelessWidget {
  final Key key;

  PrivateChatTab({
    required this.key,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            TabBar(
              dividerColor: Colors.blue,
              labelColor: Colors.blue,
              tabs: [
                Tab(text: 'Chat List'),
                Tab(text: 'Pending Requests'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ChatListScreen(),
               // ChatScreen(userId: '1', receiverId: '2', receiverName: 'b',),
                  // Center(
                  //   child: Text('Chat List Content'),
                  // ),
                 PendingRequestsScreen(currentUserId: '1'),
           
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
