import 'package:chat/privateChat/chat.dart';
import 'package:chat/utils/ads.dart';
import 'package:chat/utils/alert_dialog.dart';
import 'package:chat/utils/avatar.dart';
import 'package:chat/utils/constants.dart';
import 'package:chat/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:admob_flutter/admob_flutter.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with AutomaticKeepAliveClientMixin {
  DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  List<Map<dynamic, dynamic>> _chatList = [];
  int _selectedChatIndex = -1;

  String? currentUserId;
  //String userId = '1';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    currentUserId = SharedPrefs.getString(SharedPrefsKeys.USER_ID);

    _loadChatList(currentUserId!);
    InterstitialAdManager.initialize();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    InterstitialAdManager.dispose();
  }

  void _loadChatList(String userId) {
    print("Fetching chat lists for user: $userId");

    _databaseReference.child('chatList').child(userId).onValue.listen((event) {
      DataSnapshot snapshot = event.snapshot;
      print('chatList ${snapshot.value}');
      if (snapshot.value != null) {
        if (snapshot.value is Map) {
          Map<dynamic, dynamic> chatListData =
              snapshot.value as Map<dynamic, dynamic>;
          List<Map<dynamic, dynamic>> chatLists = [];

          chatListData.forEach((key, value) {
            if (value != null && value is Map) {
              chatLists.add(Map<dynamic, dynamic>.from(value));
            }
          });

          setState(() {
            _chatList = chatLists;
          });

          print("Chat list loaded. Total chat lists: ${_chatList.length}");
          print("Chat list content: $_chatList");
        } else if (snapshot.value is List) {
          List<dynamic> chatListData = snapshot.value as List<dynamic>;
          List<Map<dynamic, dynamic>> chatLists = [];

          chatListData.forEach((value) {
            if (value != null && value is Map) {
              chatLists.add(Map<dynamic, dynamic>.from(value));
            }
          });

          setState(() {
            _chatList = chatLists;
          });

          print("Chat list loaded. Total chat lists: ${_chatList.length}");
          print("Chat list content: $_chatList");
        } else {
          print("Invalid chat list data format for user: $userId");
          setState(() {
            _chatList = [];
          });
        }
      } else {
        print("No chat lists found for user: $userId");
        setState(() {
          _chatList = [];
        });
      }
    });
  }

  void _deleteChat(int index) {
    print('deleteChat');
    // Assuming the user is already authenticated with Firebase Authentication
    // Replace 'userId' with the authenticated user's ID
   // String userId = '70240'; // Change this to the authenticated user's ID

    // Get the chat item corresponding to the selected index
    Map<dynamic, dynamic> chatItem = _chatList[index];
    String receiverId = chatItem['receiverId'];

    // Remove the chat list entry for the selected user from the current user's chat list
    _databaseReference
        .child('chatList')
        .child(currentUserId!)
        .child(receiverId)
        .remove();

    setState(() {
      _selectedChatIndex = -1;
    });

    // If needed, you can also remove the chat list entry for the current user from the selected user's chat list
    // _databaseReference.child('chatList').child(receiverId).child(userId).remove();
  }

  @override
  Widget build(BuildContext context) {
    _chatList.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

    return Scaffold(
      body: _chatList.isEmpty
          ? Center(
              child: Text("No Private Chats"),
            )
          : ListView.builder(
              itemCount: _chatList.length,
              itemBuilder: (context, index) {
                Map<dynamic, dynamic> chatItem = _chatList[index];

                Avatar? matchingAvatar = avatars.firstWhere(
                  (avatar) => avatar.id == int.tryParse(chatItem['emojiId']),
                  orElse: () => Avatar(id: 0, imagePath: ''),
                );

                String messages = chatItem['lastMessage'] ?? '';
                String image = messages.startsWith('https') ? messages : '';
                bool isImageMessage = image.isNotEmpty;
                String formattedDateTime =
                    _formatTimestamp(chatItem['timestamp']);

                return Card(
                  color:
                      _selectedChatIndex == index ? Colors.red : Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(matchingAvatar.imagePath),
                    ),
                    title: Text(chatItem['userName']),
                    subtitle: Text(
                      isImageMessage ? 'Image' : chatItem['lastMessage'],
                      style: TextStyle(
                          fontWeight: chatItem['newMessages']
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: chatItem['newMessages']
                              ? Colors.blue
                              : Colors.grey),
                      overflow: TextOverflow
                          .ellipsis, // Show ellipsis if the text overflows
                      maxLines: 2,
                    ),
                    trailing: chatItem['newMessages']
                        ? Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.green[400],
                                  borderRadius: BorderRadius.circular(
                                      20), // Adjust the border radius as needed
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8), // Adjust padding as needed
                                child: Text(
                                  'New Messages',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(
                                  height:
                                      6), // Add space between the two Text widgets

                              Text(
                                formattedDateTime,
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            formattedDateTime ?? '',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                    onTap: () {
                      // Open the chat screen with the selected user
                    //  InterstitialAdManager.showInterstitialAd();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            userId:
                                currentUserId!, // Change this to the authenticated user's ID
                            receiverId: chatItem['receiverId'],
                            receiverUserName: chatItem['userName'],
                            receiverEmojiId: chatItem['emojiId'],
                          ),
                        ),
                      );
                    },
                    onLongPress: () {
                      // Delete the chat on long press
                      setState(() {
                        _selectedChatIndex = index;
                      });
                      deletePrivateChatDialog(
                          context,
                          () => _deleteChat(index),
                          () => setState(() {
                                _selectedChatIndex = -1;
                              }));
                    },
                  ),
                );
              },
            ),
    );
  }
}

String _formatTimestamp(int timestamp) {
  if (timestamp == 0) {
    return ''; // Handle invalid or missing timestamps
  }

  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  String formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
  String formattedTime = DateFormat('hh:mm a').format(dateTime);

  return '$formattedDate at $formattedTime';
}
