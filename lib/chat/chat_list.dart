import 'package:chat/chat/new_conversation.dart';
// import 'package:chat/chats_screen.dart';
import 'package:chat/chat/chat.dart';
import 'package:chat/settings/settings.dart';
import 'package:chat/utils/ads.dart';
import 'package:chat/utils/constants.dart';
import 'package:chat/utils/shared_pref.dart';
import 'package:chat/get_all_reply_messages.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chat/home_screen.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:chat/chat/conversation_data.dart';
import 'package:admob_flutter/admob_flutter.dart';

class ChatListr extends StatefulWidget {
  final Key key;

  ChatListr({
    required this.key,
  });

  @override
  _ChatListrState createState() => _ChatListrState();
}

class _ChatListrState extends State<ChatListr> {
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  List<String> conversationTopics = [];
  List<int> conversationTimestamps = [];

  List<String> replyCounts = [];
  List<ReplyMsg> replyMsgs = [];

  int statusCode = 0;
  String statusMessage = '';
  List<String> serverMsgIds = [];

  Timer? conversationTimer;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    getData();
    // _refreshChat();

    // InterstitialAdManager.initialize();

    // storedList();
  }

  // void _refreshChat() {
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     print('Refresh Chat');

  //     getData();

  //   });

  // }

  @override
  void dispose() {
    super.dispose();
//InterstitialAdManager.dispose();

    // conversationTimer?.cancel();
  }

  Future<void> storedList() async {
    List<Conversation> storedConversations = await getStoredConversations();
    for (var conversation in storedConversations) {
      print('Conversation ID: ${conversation.conversationId}');
      print('Reply Count: ${conversation.replyCount}');
      print('Is Read: ${conversation.isRead}');
      print('---------------------');
    }
  }

  Future<void> getData() async {
    await getConversationsData();

    // conversationTimer = Timer.periodic(Duration(seconds: 5), (_) async {
    //   print('Timer');
    //   // Clear the previous conversation data
    //   conversationTopics.clear();
    //   conversationTimestamps.clear();
    //   replyCounts.clear();

    //   await getConversationsData();
    // });
  }

  Future<void> getConversationsData() async {
    setState(() {
      isLoading = true;
    });
    String? userId = SharedPrefs.getString(SharedPrefsKeys.USER_ID);
    double? storedLatitude = SharedPrefs.getDouble(SharedPrefsKeys.LATITUDE);
    double? storedLongitude = SharedPrefs.getDouble(SharedPrefsKeys.LONGITUDE);

    Uri url = Uri.parse(API.CONVERSATION_LIST);
    Map<String, dynamic> requestBody = {
      API.USER_ID: userId,
      API.LATITUDE: storedLatitude.toString(),
      API.LONGITUDE: storedLongitude.toString(),
    };

    try {
      http.Response response = await http.post(
        url,
        headers: {API.CONTENT_TYPE: API.APPLICATION_JSON},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print('---------------ChatList Response---------------');
        print(response.body);
        // print('--------------------------------------');

        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        List<dynamic> serverMsgIds = jsonResponse[API.SERVER_MSG_ID];
        List<String> serverMsgIdsList =
            List<String>.from(serverMsgIds.map((e) => e.toString()));

        this.serverMsgIds = serverMsgIdsList;

        int statusCode = 0;
        String counts = '';
        int conversationTimestamp = 0;
        List<ReplyMsg> replyMsgs = [];
        String statusMessage = '';
        String conversationTopic = '';

        List<Conversation> conversations = [];
        List<Conversation> storedConversations = await getStoredConversations();

        final url = Uri.parse(API.CHAT);

        // print('Stored Conversations: $storedConversations');

        for (var serverMessageId in serverMsgIdsList) {
          Map<String, dynamic> requestBody = {
            API.SERVER_MESSAGE_ID: serverMessageId,
          };

          try {
            http.Response response = await http.post(
              url,
              headers: {API.CONTENT_TYPE: API.APPLICATION_JSON},
              body: jsonEncode(requestBody),
            );

            if (response.statusCode == 200) {
              final result = response.body;
              print('---------------Messsage Replies Response---------------');

              print(response.body);

              // print('--------------------------------------');

              try {
                final jsonResult = jsonDecode(result);

                counts = jsonResult[API.COUNTS];
                conversationTopic = jsonResult[API.ORIGINAL];
                conversationTimestamp = jsonResult[API.TIMESTAMP] ?? 0;

                conversationTopics.add(conversationTopic);
                conversationTimestamps.add(conversationTimestamp);
                replyCounts.add(counts);

                // Create a Conversation object
                Conversation conversation = Conversation(
                  conversationId: serverMessageId,
                  replyCount: counts,
                  isRead: false,
                );

                // Check if the conversation already exists in stored conversations
                Conversation existingConversation =
                    storedConversations.firstWhere(
                  (c) => c.conversationId == serverMessageId,
                  orElse: () => conversation,
                );

                // Check if the reply count matches
                if (existingConversation.replyCount != counts) {
                  // If reply count doesn't match, mark as read
                  conversation.isRead = false;
                  //  print('Marked as unread: $serverMessageId');
                  // print(
                  //    'Conversation: $serverMessageId - Stored Reply Count: ${existingConversation.replyCount}, Fetched Reply Count: $counts');
                } else {
                  // Otherwise, preserve the existing isRead status
                  conversation.isRead = existingConversation.isRead;
                }

                conversations.add(conversation);
              } catch (e) {
                // Handle JSON decoding error
              }
            } else {
              // Handle connection error
            }
          } catch (e) {
            // Handle exception
          }
        }
        // Store conversations in shared preferences
        await storeConversations(conversations);
        setState(() {
          isLoading = false; // Set isLoading to false after fetching data
        });
        // setState(() {});
      } else {
        // Handle connection error
      }
    } catch (e) {
      // Handle exception
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: FutureBuilder<List<Conversation>>(
        future: getStoredConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            List<Conversation> storedConversations = snapshot.data!;

            if (storedConversations.isEmpty) {
              return Center(
                child: Text(Constants.NO_CONVERSATION_FOUND),
              );
            }

            return ListView.builder(
              itemCount: conversationTopics.length,
              itemBuilder: (context, index) {
                final conversation = storedConversations[index];
                final topic = conversationTopics[index];
                final timestampp = conversationTimestamps[index];
                final count = replyCounts[index];
                final serverMsgID = serverMsgIds[index];

                DateTime dateTime =
                    DateTime.fromMillisecondsSinceEpoch(timestampp);
                String formattedDateTime =
                    DateFormat('MMM d, yyyy h:mm:ss a').format(dateTime);
                final timestamp = formattedDateTime;

                final isRead = conversation.isRead;

                // print('List item read status $isRead');

                return GestureDetector(
                  onTap: () async {
                    if (!isRead) {
                      // Mark conversation as read
                      conversation.isRead = true;
                      await storeConversations(storedConversations);
                      setState(() {}); // Trigger a rebuild of the widget
                    }

                    // InterstitialAdManager.showInterstitialAd();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Chat(
                          topic: topic,
                          serverMsgId: serverMsgID,
                        ),
                      ),
                    ).then((_) {
                      // Called when returning from the chat screen
                      setState(() {}); // Trigger a rebuild of the widget
                    });
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDialogOption(DialogStrings.STAR_CHAT,
                                  DialogStrings.CHATS_THAT_ARE_STARRED_WILL,
                                  () async {
                                print('Chat Starred');

                                // await markAllRead();

                                Navigator.of(context).pop();
                              }),
                              isRead
                                  ? _buildDialogOption(
                                      DialogStrings.MARK_CHAT_THIS_UNREAD,
                                      DialogStrings.MARK_CHAT_UNREAD, () async {
                                      print('Chat UnRead');
                                      conversation.isRead = false;
                                      await storeConversations(
                                          storedConversations);
                                      setState(() {});

                                      Navigator.of(context)
                                          .pop(); // Close the dialog if needed
                                    })
                                  : _buildDialogOption(
                                      DialogStrings.MARK_CHAT_READ,
                                      DialogStrings.MESSAGE_ICON_WILL,
                                      () async {
                                      print('Chat Read');
                                      conversation.isRead = true;
                                      await storeConversations(
                                          storedConversations);
                                      setState(() {});

                                      Navigator.of(context)
                                          .pop(); // Close the dialog if needed
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
                  },
                  child: Card(
                    elevation: 2,
                    color: Colors.blue[300],
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isRead
                              ? SizedBox()
                              : Row(
                                  children: [
                                    Icon(
                                      Icons.chat,
                                      size: 17,
                                    ),
                                    SizedBox(width: 8),
                                  ],
                                ),
                          Text(
                            topic,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 5, top: 8),
                            child: Text(
                              '${Constants.LAST_ACTIVE}$timestamp',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 5),
                            child: Text(
                              '${Constants.REPLIES}$count',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            // Handle error case
            return Center(
              child: Text(Constants.ERROR),
            );
          }
        },
      ),
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
}
