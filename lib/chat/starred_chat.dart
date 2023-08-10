// // import 'dart:html';

// import 'package:chat/chat/new_conversation.dart';
// import 'package:chat/chat/starred_chat_list.dart';
// import 'package:chat/home_screen.dart';
// import 'package:chat/settings/settings.dart';
// import 'package:chat/utils/ads.dart';
// import 'package:chat/utils/avatar.dart';
// import 'package:chat/utils/constants.dart';
// import 'package:chat/utils/lat_lng.dart';
// import 'package:chat/utils/shared_pref.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_chat_bubble/bubble_type.dart';
// import 'package:flutter_chat_bubble/chat_bubble.dart';
// import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_6.dart';
// import 'package:intl/intl.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:chat/get_all_reply_messages.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'dart:async';
// import 'package:admob_flutter/admob_flutter.dart';
// import 'package:chat/utils/alert_dialog.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:provider/provider.dart';

// class StarredChat extends StatefulWidget {
//   final String topic;
//   //  final List<ReplyMsg> replyMsgs;
//   final String serverMsgId;

//   StarredChat({
//     required this.topic,
//     //  required this.replyMsgs,
//     required this.serverMsgId,
//   });

//   @override
//   _StarredChatState createState() => _StarredChatState();
// }

// class _StarredChatState extends State<StarredChat> {
//   stt.SpeechToText _speechToText = stt.SpeechToText();
//   bool _isListening = false;
//   String _typedText = '';
//   bool isStar = false;

//   TextEditingController messageController = TextEditingController();
//   List<ReplyMsg> filteredReplyMsgs = [];
//   List<ReplyMsgg> sentMessages = [];
//   int rid = 0;
//   String emoji_id = '';
//   int timestam = 0;
//   String status_message = '';
//   int statusCode = 0;
//   List<ReplyMsg> replyMsgs = [];
//   bool sendingMessage = false; // Added variable to track sending state
//   String? shareprefuserId = SharedPrefs.getString('userId');
//   int userId = 0;
//   // double? storedLatitude = 1.0;
//   // double? storedLongitude = 1.0;
//   // late Timer refreshTimer;
//   ScrollController _scrollController = ScrollController();
//   String? currentUserHandle;
//   String? emojiId;
//   String? driverName;
//   double? latitude;
//   double? longitude;
//   FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   List<String> starredConversationList = [];

//   @override
//   void initState() {
//     super.initState();

//     _firebaseMessaging.subscribeToTopic('all');

//     //InterstitialAdManager.initialize();

//     userId = int.parse(shareprefuserId!);
//     // storedLatitude = SharedPrefs.getDouble('latitude');
//     // storedLongitude = SharedPrefs.getDouble('longitude');

//     currentUserHandle =
//         SharedPrefs.getString(SharedPrefsKeys.CURRENT_USER_CHAT_HANDLE);

//     print('init state');
//     mm(widget.serverMsgId);
//     _refreshChat();

//     checkChatStarredStatus();

//     // await getAllMessages(widget.serverMsgId);

//     // Scroll to the bottom when messages are loaded initially
//     // WidgetsBinding.instance!.addPostFrameCallback((_) {
//     //   _scrollToBottom();
//     // });
//     // _scrollToBottom();

//     // refreshTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
//     //   getAllMessages(widget.serverMsgId);
//     // });

//     // WidgetsBinding.instance?.addPostFrameCallback((_) =>
//     //     scrollToBottom()); // Call scrollToBottom() after the first frame is rendered

//     // filterReplyMsgs();
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();

//     // refreshTimer.cancel();
//     //InterstitialAdManager.dispose();
//     super.dispose();
//   }

//   void _refreshChat() {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('Refresh ChatList');

//       getAllMessages(widget.serverMsgId);
//     });
//   }

//   void scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 100),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   void filterReplyMsgs() {
//     // print('reply messges in fliter replymsf');
//     // print(replyMsgs);
//     filteredReplyMsgs =
//         replyMsgs.where((reply) => reply.topic == widget.topic).toList();
//   }

//   Future<void> mm(dynamic conversationId) async {
//     Map<String, double> locationData = await getLocation();
//     latitude = locationData[Constants.LATITUDE]!;
//     longitude = locationData[Constants.LONGITUDE]!;
//     await getAllMessages(conversationId);

//     WidgetsBinding.instance?.addPostFrameCallback((_) =>
//         scrollToBottom()); // Call scrollToBottom() after the first frame is rendered

//     //   WidgetsBinding.instance!.addPostFrameCallback((_) {
//     //   _scrollController.animateTo(
//     //     _scrollController.position.maxScrollExtent,
//     //     duration: Duration(milliseconds: 500),
//     //     curve: Curves.ease,
//     //   );
//     // });
//   }

//   Future<void> sendFCMNotification(String topic, String message) async {
//     final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
//     final serverKey =
//         'AAAAeR6Pnuo:APA91bHiasD4BKzgcY04ZiQ8oNi0L3HdOBeLBtUrxPfemCHHlxY0SGRP9VQ4kowDqRtOacdN8HUjmDTTMOgV1IzActxqGbKCT2W6dRm3Om5baCfJjDlBWnOm5vNqO-goLJRJV0UG1XgL'; // Replace with your FCM server key

//     final headers = {
//       'Content-Type': 'application/json',
//       'Authorization': 'key=$serverKey',
//     };

//     final body = {
//       'to': '/topics/$topic',
//       'notification': {
//         'body': 'message',
//         'title': 'New Message',
//       },
//       'data': {
//         'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//         'senderId': '1111', // Include the senderId in the data payload
//       },
//     };

//     try {
//       final response =
//           await http.post(url, headers: headers, body: jsonEncode(body));
//       if (response.statusCode == 200) {
//         print('FCM notification sent successfully');
//       } else {
//         print('Failed to send FCM notification');
//       }
//     } catch (e) {
//       print('Error sending FCM notification: $e');
//     }
//   }

//   Future<bool> getAllMessages(dynamic conversationId) async {
//     print('getAllMessages method called');
//     print('Conversation Id  $conversationId');
//     int statusCode = 0;
//     String counts = '';

//     String statusMessage = '';

//     final url = Uri.parse(API.CHAT);

//     Map<String, dynamic> requestBody = {
//       API.SERVER_MESSAGE_ID: conversationId,
//     };

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: {API.CONTENT_TYPE: API.APPLICATION_JSON},
//         body: jsonEncode(requestBody),
//       );
//       if (response.statusCode == 200) {
//         // print('200');
//         final result = response.body;

//         print('---------------Chat Response---------------');
//         print(result);

//         //print('response body $result');

//         try {
//           final jsonResult = jsonDecode(result);

//           counts = jsonResult[API.COUNTS];

//           final jsonReplyList = jsonResult[API.MESSAGE_REPLY_LIST];

//           // print('jsonreplylist');
//           // print(jsonReplyList);

//           int countValue = int.parse(counts);

//           // print(jsonReplyList.length);
//           // Clear the replyMsgs list before adding new messages
//           replyMsgs.clear();

//           //if (counts == jsonReplyList.length) {
//           for (var i = 0; i < countValue; ++i) {
//             final jsonReply = jsonReplyList[i];
//             final rid = jsonReply[API.SERVER_MSG_REPLY_ID];
//             final replyMsg = jsonReply[API.REPLY_MSG];
//             final uid = jsonReply[API.USER_ID];
//             final emojiId = jsonReply[API.EMOJI_ID];
//             final driverName = jsonReply['driver_name'];
//             final privateChat = jsonReply['private_chat'];

//             print("server_msg_reply_id  $rid");
//             print("reply_msg $replyMsg");
//             print("user id  $uid");
//             print("emoji_id $emojiId");
//             print("driver_name $driverName");

//             print('--------------------------');
//             int timestamp;
//             try {
//               //  timestamp = int.tryParse(jsonReply['timestamp']) ?? 0;
//               timestamp = jsonReply[API.TIMESTAMP] ?? 0;
//               // print('try in for $timestamp');
//             } catch (e) {
//               timestamp = 0;
//               //print('catch $timestamp');
//             }

//             replyMsgs.add(ReplyMsg(rid, uid, replyMsg, timestamp, emojiId,
//                 widget.topic, driverName, privateChat));
//           }
//           // } else {
//           //   print('elsee');
//           // }

//           setState(() {
//             // Update the conversation data
//             // conversationTopics.add(conversationTopic);
//             // conversationTimestamps.add(conversationTimestamp);
//             // replyCounts.add(counts);
//             this.replyMsgs = replyMsgs;

//             filterReplyMsgs();
//             // scrollToBottom();
//             WidgetsBinding.instance
//                 ?.addPostFrameCallback((_) => scrollToBottom());
//           });
//         } catch (e) {
//           print('catch 2 $e');
//           statusMessage = e.toString();
//         }
//       } else {
//         statusMessage = 'Connection Error';
//       }
//     } catch (e) {
//       print('${Constants.ERROR} $e');
//     }
//     //  }

//     return false;
//   }

//   Future<bool> sendMessage(
//     String message,
//     String serverMsgId,
//     int userId,
//   ) async {
//     setState(() {
//       sendingMessage = true; // Set sending state to true
//     });

//     if (SharedPrefs.getInt(SharedPrefsKeys.CURRENT_USER_AVATAR_ID) != null) {
//       emojiId =
//           SharedPrefs.getInt(SharedPrefsKeys.CURRENT_USER_AVATAR_ID).toString();
//       // print('new conversation emoji id $emojiId');
//     } else {
//       emojiId = '0';
//       // print('new conversation emoji id $emojiId');
//     }

//     driverName =
//         SharedPrefs.getString(SharedPrefsKeys.CURRENT_USER_CHAT_HANDLE) ?? '';

//     // print('send message');
//     // print('message $message');
//     // print('sermsgid $serverMsgId');
//     // print('userid $userId');
//     // print('emojiid $emojiId');

// //concat username/chathandle with message
//     // if (currentUserHandle != null) {
//     //   message = '$currentUserHandle $message';
//     // }

//     //  int servermsgid = int.parse(serverMsgId);
//     final url = API.SEND_MESSAGE; // Replace with your API endpoint
//     final headers = {API.CONTENT_TYPE: API.APPLICATION_JSON};
//     final body = jsonEncode({
//       API.MESSAGE: message,
//       API.SERVER_MSG_ID: serverMsgId,
//       API.USER_ID: userId,
//       API.LATITUDE: latitude.toString(),
//       API.LONGITUDE: longitude.toString(),
//       API.EMOJI_ID: emojiId,
//       'driver_name': driverName,
//     });

//     try {
//       final response =
//           await http.post(Uri.parse(url), headers: headers, body: body);

//       print(response.body);

//       if (response.statusCode == 200) {
//         print('Message Sent');
//         setState(() {
//           sendingMessage = false; // Set sending state to false
//           WidgetsBinding.instance
//               ?.addPostFrameCallback((_) => scrollToBottom());
//         });

//         final jsonResult = jsonDecode(response.body);
//         print('---------------Send Message Response---------------');

//         print(response.body);
//         int statusCode = jsonResult[API.STATUS] as int;

//         /// print('status code $statusCode');

//         if (jsonResult.containsKey(API.MESSAGE)) {
//           String status_message = jsonResult[API.MESSAGE] as String;
//           // print('status_message $status_message');

//           // Add the sent message to the list
//           // sentMessages.add(ReplyMsgg(serverMsgId, userId, message,
//           //     DateTime.now().millisecondsSinceEpoch));
//         } else {
//           String status_message = '';
//         }

//         return true;
//       } else {
//         setState(() {
//           sendingMessage = false; // Set sending state to false
//         });
//         status_message = 'Error: ${response.statusCode}';
//       }
//     } catch (e) {
//       status_message = e.toString();
//       setState(() {
//         sendingMessage = false; // Set sending state to false
//       });
//     }

//     return false;
//   }

//   Future<void> saveStarredConversations(
//       List<String> starredConversationList) async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       List<String>? storedStarredConversations =
//           prefs.getStringList('starredConversationList');

//       if (storedStarredConversations != null) {
//         if (storedStarredConversations.contains(widget.serverMsgId)) {
//           // Conversation is already starred, remove it
//           storedStarredConversations.remove(widget.serverMsgId);
//         } else {
//           // Conversation is not starred, add it
//           storedStarredConversations.add(widget.serverMsgId);
//         }
//       } else {
//         // No stored starred conversations, initialize the list
//         storedStarredConversations = [widget.serverMsgId];
//       }

//       await prefs.setStringList(
//         'starredConversationList',
//         storedStarredConversations,
//       );

//       print('Starred conversations saved successfully');
//     } catch (e) {
//       print('Failed to save starred conversations: $e');
//     }
//   }

//   // Retrieve starred conversations from SharedPreferences and check if the current chat is starred
//   void checkChatStarredStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String>? starredConversationList =
//         prefs.getStringList('starredConversationList');
//     if (starredConversationList != null) {
//       if (starredConversationList.contains(widget.serverMsgId)) {
//         setState(() {
//           isStar = true;
//         });
//       } else {
//         setState(() {
//           isStar = false;
//         });
//       }
//     } else {
//       setState(() {
//         isStar = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//         bool isPrivateChatEnabled =
//         SharedPrefs.getBool(SharedPrefsKeys.PRIVATE_CHAT) ?? false;

//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => StarredChatList(
//                       key: UniqueKey(),
//                     )));

//         //showExitConversationDialog(context);
//         return true; // Prevent the default back button behavior
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.blue,
//           iconTheme: IconThemeData(
//             color: Colors.white, // Set the color of the back arrow here
//           ),
//           title: Text(
//             Constants.APP_BAR_TITLE,
//             style: TextStyle(color: Colors.white),
//           ),
//           actions: [
//             IconButton(
//               icon: isStar
//                   ? Icon(
//                       Icons.star,
//                       color: Colors.yellow,
//                     )
//                   : Icon(Icons.star_border), // Toggle between the star icons
//               onPressed: () {
//                 setState(() {
//                   isStar = !isStar; // Toggle the starred status
//                 });
//                 saveStarredConversations(starredConversationList);
//               },
//             ),
//               IconButton(
//               icon: Image.asset(
//                 'assets/doublechat.png', // Replace 'doublechat_disabled.png' with the path to your disabled icon asset
//                 width: 30,
//                 height: 30,
//                 color: isPrivateChatEnabled ? null : Colors.grey,
//               ),
//               onPressed: () {
//                 setState(() {
//                   isPrivateChatEnabled =
//                       !isPrivateChatEnabled; // Toggle the state
//                   SharedPrefs.setBool(SharedPrefsKeys.PRIVATE_CHAT,
//                       isPrivateChatEnabled); // Save the state in shared preferences
//                 });
//                 showPrivateChatDialog(context, isPrivateChatEnabled);
//               },
//             ),
//             PopupMenuButton(
//               itemBuilder: (BuildContext context) {
//                 return [
//                   PopupMenuItem(
//                     child: Text(Constants.SETTINGS),
//                     value: 'settings',
//                   ),
//                   PopupMenuItem(
//                     child: Text(Constants.TELL_A_FRIEND),
//                     value: 'tell a friend',
//                   ),
//                   PopupMenuItem(
//                     child: Text(Constants.HELP),
//                     value: 'help',
//                   ),
//                   PopupMenuItem(
//                     child: Text(Constants.STARRED_CHAT),
//                     value: 'starred chat',
//                   ),
//                   PopupMenuItem(
//                     child: Text(Constants.REPORT_ABUSE),
//                     value: 'report abuse',
//                   ),
//                 ];
//               },
//               onSelected: (value) {
//                 // Perform action when a pop-up menu item is selected
//                 switch (value) {
//                   case 'settings':
//                     //InterstitialAdManager.showInterstitialAd();
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => SettingsScreen()),
//                     );
//                     break;
//                   case 'tell a friend':
//                     String email = Uri.encodeComponent("");
//                     String subject =
//                         Uri.encodeComponent(Constants.CHECK_OUT_TRUCKCHAT);
//                     String body =
//                         Uri.encodeComponent(Constants.I_AM_USING_TRUCKCHAT);
//                     print(subject);
//                     Uri mail =
//                         Uri.parse("mailto:$email?subject=$subject&body=$body");
//                     launchUrl(mail);
//                     break;
//                   case 'help':
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => Help()),
//                     );
//                     break;
//                   case 'starred chat':
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => StarredChatList(key: UniqueKey()),
//                       ),
//                     );
//                     break;
//                   case 'report abuse':
//                     _showReportAbuseDialog(context);
//                     break;
//                 }
//               },
//             ),
//           ],
//         ),
//         body: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Padding(
//               padding: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 8),
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[300],
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 child: Text(
//                   widget.topic,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 controller: _scrollController,
//                 itemCount: filteredReplyMsgs.length + sentMessages.length,
//                 itemBuilder: (context, index) {
//                   if (index < filteredReplyMsgs.length) {
//                     final reply = filteredReplyMsgs[index];
//                     final replyMsg = reply.replyMsg;
//                     final timestampp = reply.timestamp;
//                     final driverName = reply.driverName;
//                     final privateChat = reply.privateChat;

//                     DateTime dateTime =
//                         DateTime.fromMillisecondsSinceEpoch(timestampp);
//                     String formattedDateTime =
//                         DateFormat('MMM d, yyyy h:mm:ss a').format(dateTime);
//                     final timestamp = formattedDateTime;

//                     rid = reply.rid;
//                     emoji_id = reply.emojiId;
//                     timestam = timestampp;

//                     bool isCurrentUser = reply.uid ==
//                         userId; // Check if the user_id is equal to currentUserId

//                     // Find the corresponding Avatar for the emoji_id
//                     Avatar? matchingAvatar = avatars.firstWhere(
//                       (avatar) => avatar.id == int.parse(reply.emojiId),
//                       orElse: () => Avatar(id: 0, imagePath: ''),
//                     );
//                     // print('emoji id $emoji_id');
//                     // print('matching avatar id ${matchingAvatar.id}');

//                     return Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: ChatBubble(
//                         clipper: ChatBubbleClipper6(
//                             type: isCurrentUser
//                                 ? BubbleType.sendBubble
//                                 : BubbleType.receiverBubble),
//                         alignment: isCurrentUser
//                             ? Alignment.topRight
//                             : Alignment.topLeft,
//                         margin: EdgeInsets.only(bottom: 16.0),
//                         backGroundColor:
//                             isCurrentUser ? Colors.blue[100] : Colors.blue[300],
//                         child: isCurrentUser
//                             ? Container(
//                                 constraints: BoxConstraints(maxWidth: 250.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         if (SharedPrefs.getString(SharedPrefsKeys
//                                                 .CURRENT_USER_AVATAR_IMAGE_PATH) !=
//                                             null)
//                                           Image.asset(
//                                             SharedPrefs.getString(SharedPrefsKeys
//                                                 .CURRENT_USER_AVATAR_IMAGE_PATH)!,
//                                             width: 30,
//                                             height: 30,
//                                           ),
//                                         SizedBox(width: 8.0),
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 driverName + replyMsg,
//                                                 style: TextStyle(
//                                                     color: Colors.black,
//                                                     fontSize: 20),
//                                               ),
//                                               SizedBox(height: 4.0),
//                                               Text(
//                                                 timestamp,
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               )
//                             : Container(
//                                 constraints: BoxConstraints(maxWidth: 250.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         if (matchingAvatar.id != 0)
//                                           Image.asset(
//                                             matchingAvatar.imagePath,
//                                             width: 30,
//                                             height: 30,
//                                           ),
//                                         SizedBox(width: 8.0),
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 replyMsg,
//                                                 style: TextStyle(
//                                                     color: Colors.black,
//                                                     fontSize: 20),
//                                               ),
//                                               SizedBox(height: 4.0),
//                                               Text(
//                                                 timestamp,
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                       ),
//                     );
//                   } else {
//                     final sentIndex = index - filteredReplyMsgs.length;
//                     final sentMessage = sentMessages[sentIndex];
//                     final timestampp = sentMessage.timestamp;

//                     DateTime dateTime =
//                         DateTime.fromMillisecondsSinceEpoch(timestampp);
//                     String formattedDateTime =
//                         DateFormat('MMM d, yyyy h:mm:ss a').format(dateTime);
//                     final timestamp = formattedDateTime;

//                     bool isCurrentUser = sentMessage.uid ==
//                         userId; // Check if the user_id is equal to 69979

//                     return Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: ChatBubble(
//                         clipper: ChatBubbleClipper6(
//                             type: isCurrentUser
//                                 ? BubbleType.sendBubble
//                                 : BubbleType.receiverBubble),
//                         alignment: isCurrentUser
//                             ? Alignment.topRight
//                             : Alignment.topLeft,
//                         margin: EdgeInsets.only(bottom: 16.0),
//                         backGroundColor: Colors.blue[300],
//                         child: Container(
//                           constraints: BoxConstraints(maxWidth: 250.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 sentMessage.replyMsg,
//                                 style: TextStyle(
//                                     color: Colors.black, fontSize: 20),
//                               ),
//                               SizedBox(height: 4.0),
//                               Text(
//                                 timestamp,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   }
//                 },
//               ),
//             ),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(24.0),
//               ),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: Icon(Icons.mic),
//                     onPressed: () {
//                       _toggleListening();
//                     },
//                   ),
//                   Expanded(
//                     child: TextField(
//                       controller: messageController,
//                       decoration: InputDecoration(
//                         hintText: Constants.COMPOSE_MESSAGE,
//                         border: InputBorder.none,
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 8.0),
//                   FloatingActionButton(
//                     onPressed: () async {
//                       String message = messageController.text.trim();
//                       if (!message.isEmpty) {
//                         bool messageSent = await sendMessage(
//                           messageController.text,
//                           widget.serverMsgId,
//                           userId,
//                         );
//                         if (messageSent) {
//                           print('message sent');

//                           sendFCMNotification('all', 'message');

//                           setState(() {
//                             WidgetsBinding.instance
//                                 ?.addPostFrameCallback((_) => scrollToBottom());
//                           });

//                           // Message sent successfully, handle any UI updates if needed
//                         } else {
//                           print('message failed');
//                           // Failed to send the message, handle any UI updates if needed
//                         }
//                         setState(() {
//                           messageController.clear();
//                         });
//                       }
//                     },
//                     backgroundColor: Colors.blue,
//                     child: sendingMessage // Check sending state
//                         ? CircularProgressIndicator(
//                             valueColor:
//                                 AlwaysStoppedAnimation<Color>(Colors.white),
//                           ) // Show progress indicator
//                         : Icon(Icons.send),
//                   ),
//                 ],
//               ),
//             ),
//             AdmobBanner(
//               adUnitId: AdHelper.bannerAdUnitId,
//               adSize: AdmobBannerSize.ADAPTIVE_BANNER(
//                   width: MediaQuery.of(context).size.width.toInt()),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   void _showReportAbuseDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(Constants.REPORT_ABUSE),
//           content: Text(DialogStrings.TO_REPORT_ABUSE),
//           actions: [
//             TextButton(
//               child: Text(DialogStrings.GOT_IT),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _toggleListening() {
//     _startListening();
//   }

//   void _startListening() async {
//     bool available = await _speechToText.initialize();
//     if (available) {
//       _speechToText.listen(
//         onResult: (result) {
//           setState(() {
//             messageController.text = result.recognizedWords;
//             _typedText = result.recognizedWords;
//           });
//         },
//         listenMode: stt.ListenMode.dictation,
//         pauseFor: Duration(seconds: 2),
//       );
//       setState(() {
//         _isListening = true;
//       });
//     }
//   }

//   void _stopListening() {
//     _speechToText.stop();
//     setState(() {
//       _isListening = false;
//     });
//   }
// }

//testing 1
// import 'dart:html';

import 'package:chat/chat/new_conversation.dart';
import 'package:chat/chat/starred_chat_list.dart';
import 'package:chat/home_screen.dart';
import 'package:chat/settings/settings.dart';
import 'package:chat/utils/ads.dart';
import 'package:chat/utils/avatar.dart';
import 'package:chat/utils/constants.dart';
import 'package:chat/utils/device_type.dart';
import 'package:chat/utils/lat_lng.dart';
import 'package:chat/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_6.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chat/get_all_reply_messages.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:chat/utils/alert_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';

class StarredChat extends StatefulWidget {
  final String topic;
  //  final List<ReplyMsg> replyMsgs;
  final String serverMsgId;

  StarredChat({
    required this.topic,
    //  required this.replyMsgs,
    required this.serverMsgId,
  });

  @override
  _StarredChatState createState() => _StarredChatState();
}

class _StarredChatState extends State<StarredChat> {
  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _typedText = '';
  bool isStar = false;

  TextEditingController messageController = TextEditingController();
  List<ReplyMsg> filteredReplyMsgs = [];
  List<ReplyMsgg> sentMessages = [];
  int rid = 0;
  String emoji_id = '';
  int timestam = 0;
  String status_message = '';
  int statusCode = 0;
  List<ReplyMsg> replyMsgs = [];
  bool sendingMessage = false; // Added variable to track sending state
  String? shareprefuserId = SharedPrefs.getString('userId');
  int userId = 0;
  ScrollController _scrollController = ScrollController();
  String? currentUserHandle;
  String? emojiId;
  String? driverName;
  double? latitude;
  double? longitude;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  List<String> starredConversationList = [];
  String? currentUserEmojiId;
  bool isLoading = true;
  String? currentUserId;
  String? privateChatStatus;
  bool? privateChat;

  @override
  void initState() {
    super.initState();

    _firebaseMessaging.subscribeToTopic('all');

    //InterstitialAdManager.initialize();

    userId = int.parse(shareprefuserId!);
    // storedLatitude = SharedPrefs.getDouble('latitude');
    // storedLongitude = SharedPrefs.getDouble('longitude');
    currentUserEmojiId =
        SharedPrefs.getInt(SharedPrefsKeys.CURRENT_USER_AVATAR_ID).toString();

    currentUserHandle =
        SharedPrefs.getString(SharedPrefsKeys.CURRENT_USER_CHAT_HANDLE);

    currentUserId = SharedPrefs.getString(SharedPrefsKeys.USER_ID);

    print('init state');
    getData(widget.serverMsgId).then((_) {
      setState(() {
        isLoading = false;
      });
    });
    ;
    _refreshChat();

    checkChatStarredStatus();

    // await getAllMessages(widget.serverMsgId);

    // Scroll to the bottom when messages are loaded initially
    // WidgetsBinding.instance!.addPostFrameCallback((_) {
    //   _scrollToBottom();
    // });
    // _scrollToBottom();

    // refreshTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
    //   getAllMessages(widget.serverMsgId);
    // });

    // WidgetsBinding.instance?.addPostFrameCallback((_) =>
    //     scrollToBottom()); // Call scrollToBottom() after the first frame is rendered

    // filterReplyMsgs();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    // refreshTimer.cancel();
    //InterstitialAdManager.dispose();
    super.dispose();
  }

  void _refreshChat() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Refresh ChatList');

      getAllMessages(widget.serverMsgId);
    });
  }

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    }
  }

  void filterReplyMsgs() {
    // print('reply messges in fliter replymsf');
    // print(replyMsgs);
    filteredReplyMsgs =
        replyMsgs.where((reply) => reply.topic == widget.topic).toList();
  }

  Future<void> getData(dynamic conversationId) async {
    Map<String, double> locationData = await getLocation();
    latitude = locationData[Constants.LATITUDE]!;
    longitude = locationData[Constants.LONGITUDE]!;
    await getAllMessages(conversationId);

    WidgetsBinding.instance?.addPostFrameCallback((_) =>
        scrollToBottom()); // Call scrollToBottom() after the first frame is rendered

    //   WidgetsBinding.instance!.addPostFrameCallback((_) {
    //   _scrollController.animateTo(
    //     _scrollController.position.maxScrollExtent,
    //     duration: Duration(milliseconds: 500),
    //     curve: Curves.ease,
    //   );
    // });
  }

  Future<void> sendFCMNotification(String topic, String message) async {
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
    final serverKey =
        'AAAAeR6Pnuo:APA91bHiasD4BKzgcY04ZiQ8oNi0L3HdOBeLBtUrxPfemCHHlxY0SGRP9VQ4kowDqRtOacdN8HUjmDTTMOgV1IzActxqGbKCT2W6dRm3Om5baCfJjDlBWnOm5vNqO-goLJRJV0UG1XgL'; // Replace with your FCM server key

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final body = {
      'to': '/topics/$topic',
      'notification': {
        'body': 'Tap here to open TruckChat',
        'title': 'There are new messages!',
      },
      'data': {
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'type': 'public',
        'senderUserId':
            currentUserId, // Include the senderId in the data payload
      },
    };

    try {
      final response =
          await http.post(url, headers: headers, body: jsonEncode(body));
      if (response.statusCode == 200) {
        print('FCM notification sent successfully');
      } else {
        print('Failed to send FCM notification');
      }
    } catch (e) {
      print('Error sending FCM notification: $e');
    }
  }

  Future<bool> getAllMessages(dynamic conversationId) async {
    print('getAllMessages method called');
    print('Conversation Id  $conversationId');
    int statusCode = 0;
    String counts = '';

    String statusMessage = '';

    final url = Uri.parse(API.CHAT);

    Map<String, dynamic> requestBody = {
      API.SERVER_MESSAGE_ID: conversationId,
    };

    try {
      http.Response response = await http.post(
        url,
        headers: {API.CONTENT_TYPE: API.APPLICATION_JSON},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        // print('200');
        final result = response.body;

        print('---------------Chat Response---------------');
        print(result);

        //print('response body $result');

        try {
          final jsonResult = jsonDecode(result);

          counts = jsonResult[API.COUNTS];

          final jsonReplyList = jsonResult[API.MESSAGE_REPLY_LIST];

          // print('jsonreplylist');
          // print(jsonReplyList);

          int countValue = int.parse(counts);

          // print(jsonReplyList.length);
          // Clear the replyMsgs list before adding new messages
          replyMsgs.clear();

          //if (counts == jsonReplyList.length) {
          for (var i = 0; i < countValue; ++i) {
            final jsonReply = jsonReplyList[i];
            final rid = jsonReply[API.SERVER_MSG_REPLY_ID];
            final replyMsg = jsonReply[API.REPLY_MSG];
            final uid = jsonReply[API.USER_ID];
            final emojiId = jsonReply[API.EMOJI_ID];
            final driverName = jsonReply['driver_name'];
            final privateChat = jsonReply['private_chat'];

            print("server_msg_reply_id  $rid");
            print("reply_msg $replyMsg");
            print("user id  $uid");
            print("emoji_id $emojiId");
            print("driver_name $driverName");

            print('--------------------------');
            int timestamp;
            try {
              //  timestamp = int.tryParse(jsonReply['timestamp']) ?? 0;
              timestamp = jsonReply[API.TIMESTAMP] ?? 0;
              // print('try in for $timestamp');
            } catch (e) {
              timestamp = 0;
              //print('catch $timestamp');
            }

            replyMsgs.add(ReplyMsg(rid, uid, replyMsg, timestamp, emojiId,
                widget.topic, driverName, privateChat));
          }
          // } else {
          //   print('elsee');
          // }

          setState(() {
            // Update the conversation data
            // conversationTopics.add(conversationTopic);
            // conversationTimestamps.add(conversationTimestamp);
            // replyCounts.add(counts);
            this.replyMsgs = replyMsgs;

            filterReplyMsgs();
            // scrollToBottom();
            WidgetsBinding.instance
                ?.addPostFrameCallback((_) => scrollToBottom());
          });
        } catch (e) {
          print('catch 2 $e');
          statusMessage = e.toString();
        }
      } else {
        statusMessage = 'Connection Error';
      }
    } catch (e) {
      print('${Constants.ERROR} $e');
    }
    //  }

    return false;
  }

  Future<bool> sendMessage(
    String message,
    String serverMsgId,
    int userId,
  ) async {
    setState(() {
      sendingMessage = true; // Set sending state to true
    });

    if (SharedPrefs.getInt(SharedPrefsKeys.CURRENT_USER_AVATAR_ID) != null) {
      emojiId =
          SharedPrefs.getInt(SharedPrefsKeys.CURRENT_USER_AVATAR_ID).toString();
      // print('new conversation emoji id $emojiId');
    } else {
      emojiId = '0';
      // print('new conversation emoji id $emojiId');
    }

    driverName =
        SharedPrefs.getString(SharedPrefsKeys.CURRENT_USER_CHAT_HANDLE) ?? '';
    privateChat = SharedPrefs.getBool(SharedPrefsKeys.PRIVATE_CHAT) ?? false;

    privateChatStatus = privateChat! ? '1' : '0';

    // print('send message');
    // print('message $message');
    // print('sermsgid $serverMsgId');
    // print('userid $userId');
    // print('emojiid $emojiId');

//concat username/chathandle with message
    // if (currentUserHandle != null) {
    //   message = '$currentUserHandle $message';
    // }

    //  int servermsgid = int.parse(serverMsgId);
    final url = API.SEND_MESSAGE; // Replace with your API endpoint
    final headers = {API.CONTENT_TYPE: API.APPLICATION_JSON};
    final body = jsonEncode({
      API.MESSAGE: message,
      API.SERVER_MSG_ID: serverMsgId,
      API.USER_ID: userId,
      API.LATITUDE: latitude.toString(),
      API.LONGITUDE: longitude.toString(),
      API.EMOJI_ID: emojiId,
      'driver_name': driverName,
      'private_chat': privateChatStatus,
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      print(response.body);

      if (response.statusCode == 200) {
        print('Message Sent');
        // setState(() {
        //   sendingMessage = false; // Set sending state to false
        //   WidgetsBinding.instance
        //       ?.addPostFrameCallback((_) => scrollToBottom());
        // });

        final jsonResult = jsonDecode(response.body);
        print('---------------Send Message Response---------------');

        print(response.body);
        int statusCode = jsonResult[API.STATUS] as int;

        /// print('status code $statusCode');
        await sendFCMNotification('all', 'message');

        setState(() {
          sendingMessage = false; // Set sending state to false

          WidgetsBinding.instance
              ?.addPostFrameCallback((_) => scrollToBottom());
        });
        if (jsonResult.containsKey(API.MESSAGE)) {
          String status_message = jsonResult[API.MESSAGE] as String;
          // print('status_message $status_message');

          // Add the sent message to the list
          // sentMessages.add(ReplyMsgg(serverMsgId, userId, message,
          //     DateTime.now().millisecondsSinceEpoch));
        } else {
          String status_message = '';
        }

        return true;
      } else {
        setState(() {
          sendingMessage = false; // Set sending state to false
        });
        status_message = 'Error: ${response.statusCode}';
      }
    } catch (e) {
      status_message = e.toString();
      setState(() {
        sendingMessage = false; // Set sending state to false
      });
    }

    return false;
  }

  Future<void> saveStarredConversations(
      List<String> starredConversationList) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? storedStarredConversations =
          prefs.getStringList('starredConversationList');

      if (storedStarredConversations != null) {
        if (storedStarredConversations.contains(widget.serverMsgId)) {
          // Conversation is already starred, remove it
          storedStarredConversations.remove(widget.serverMsgId);
        } else {
          // Conversation is not starred, add it
          storedStarredConversations.add(widget.serverMsgId);
        }
      } else {
        // No stored starred conversations, initialize the list
        storedStarredConversations = [widget.serverMsgId];
      }

      await prefs.setStringList(
        'starredConversationList',
        storedStarredConversations,
      );

      print('Starred conversations saved successfully');
    } catch (e) {
      print('Failed to save starred conversations: $e');
    }
  }

  // Retrieve starred conversations from SharedPreferences and check if the current chat is starred
  void checkChatStarredStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? starredConversationList =
        prefs.getStringList('starredConversationList');
    if (starredConversationList != null) {
      if (starredConversationList.contains(widget.serverMsgId)) {
        setState(() {
          isStar = true;
        });
      } else {
        setState(() {
          isStar = false;
        });
      }
    } else {
      setState(() {
        isStar = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPrivateChatEnabled =
        SharedPrefs.getBool(SharedPrefsKeys.PRIVATE_CHAT) ?? false;
    Color brightGreen = Color.fromRGBO(0, 255, 0, 1.0);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => StarredChatList(
                      key: UniqueKey(),
                    )));

        //showExitConversationDialog(context);
        return true; // Prevent the default back button behavior
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          iconTheme: IconThemeData(
            color: Colors.white, // Set the color of the back arrow here
          ),
          title: Text(
            Constants.APP_BAR_TITLE,
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: isStar
                  ? Icon(
                      Icons.star,
                      color: Colors.yellow,
                    )
                  : Icon(Icons.star_border), // Toggle between the star icons
              onPressed: () {
                setState(() {
                  isStar = !isStar; // Toggle the starred status
                });
                saveStarredConversations(starredConversationList);
              },
            ),
            IconButton(
              icon: Image.asset(
                'assets/doublechat.png', // Replace 'doublechat_disabled.png' with the path to your disabled icon asset
                width: 30,
                height: 30,
                color: isPrivateChatEnabled ? null : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  isPrivateChatEnabled =
                      !isPrivateChatEnabled; // Toggle the state
                  SharedPrefs.setBool(SharedPrefsKeys.PRIVATE_CHAT,
                      isPrivateChatEnabled); // Save the state in shared preferences
                });
                showPrivateChatDialog(context, isPrivateChatEnabled);
              },
            ),
            PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    child: Text(Constants.SETTINGS),
                    value: 'settings',
                  ),
                  PopupMenuItem(
                    child: Text(Constants.TELL_A_FRIEND),
                    value: 'tell a friend',
                  ),
                  PopupMenuItem(
                    child: Text(Constants.HELP),
                    value: 'help',
                  ),
                  PopupMenuItem(
                    child: Text(Constants.STARRED_CHAT),
                    value: 'starred chat',
                  ),
                  PopupMenuItem(
                    child: Text(Constants.REPORT_ABUSE),
                    value: 'report abuse',
                  ),
                ];
              },
              onSelected: (value) {
                // Perform action when a pop-up menu item is selected
                switch (value) {
                  case 'settings':
                    //InterstitialAdManager.showInterstitialAd();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                    break;
                  case 'tell a friend':
                    String email = Uri.encodeComponent("");
                    String subject =
                        Uri.encodeComponent(Constants.CHECK_OUT_TRUCKCHAT);
                    String body =
                        Uri.encodeComponent(Constants.I_AM_USING_TRUCKCHAT);
                    print(subject);
                    Uri mail =
                        Uri.parse("mailto:$email?subject=$subject&body=$body");
                    launchUrl(mail);
                    break;
                  case 'help':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Help()),
                    );
                    break;
                  case 'starred chat':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StarredChatList(key: UniqueKey()),
                      ),
                    );
                    break;
                  case 'report abuse':
                    _showReportAbuseDialog(context);
                    break;
                }
              },
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 8),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.blue[300],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  widget.topic,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: filteredReplyMsgs.length + sentMessages.length,
                      itemBuilder: (context, index) {
                        if (index < filteredReplyMsgs.length) {
                          final reply = filteredReplyMsgs[index];
                          final replyMsg = reply.replyMsg;
                          final timestampp = reply.timestamp;
                          final driverName = reply.driverName;
                          final privateChat = reply.privateChat;

                          DateTime dateTime =
                              DateTime.fromMillisecondsSinceEpoch(timestampp);
                          String formattedDateTime =
                              DateFormat('MMM d, yyyy h:mm:ss a')
                                  .format(dateTime);
                          final timestamp = formattedDateTime;

                          rid = reply.rid;
                          emoji_id = reply.emojiId;
                          timestam = timestampp;

                          bool isCurrentUser = reply.uid ==
                              userId; // Check if the user_id is equal to currentUserId

                          // Find the corresponding Avatar for the emoji_id
                          Avatar? matchingAvatar = avatars.firstWhere(
                            (avatar) => avatar.id == int.parse(reply.emojiId),
                            orElse: () => Avatar(id: 0, imagePath: ''),
                          );
                          // print('emoji id $emoji_id');
                          // print('matching avatar id ${matchingAvatar.id}');

                          return Padding(
                            padding: EdgeInsets.all(8.0),
                            child: isCurrentUser
                                ? ChatBubble(
                                    clipper: ChatBubbleClipper6(
                                        type: isCurrentUser
                                            ? BubbleType.sendBubble
                                            : BubbleType.receiverBubble),
                                    alignment: isCurrentUser
                                        ? Alignment.topRight
                                        : Alignment.topLeft,
                                    margin: EdgeInsets.only(bottom: 16.0),
                                    backGroundColor: isCurrentUser
                                        ? Colors.blue[100]
                                        : Colors.blue[300],
                                    child: isCurrentUser
                                        ? Container(
                                            constraints:
                                                BoxConstraints(maxWidth: 250.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (SharedPrefs.getString(
                                                            SharedPrefsKeys
                                                                .CURRENT_USER_AVATAR_IMAGE_PATH) !=
                                                        null)
                                                      Image.asset(
                                                        SharedPrefs.getString(
                                                            SharedPrefsKeys
                                                                .CURRENT_USER_AVATAR_IMAGE_PATH)!,
                                                        width: 30,
                                                        height: 30,
                                                      ),
                                                    SizedBox(width: 8.0),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            driverName +
                                                                replyMsg,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 20),
                                                          ),
                                                          SizedBox(height: 4.0),
                                                          Text(
                                                            timestamp,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(
                                            constraints:
                                                BoxConstraints(maxWidth: 250.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (matchingAvatar.id != 0)
                                                      Stack(
                                                        alignment: Alignment(
                                                            2.6,
                                                            -2.4), // Adjust the alignment here

                                                        children: [
                                                          Image.asset(
                                                            matchingAvatar
                                                                .imagePath,
                                                            width: 30,
                                                            height: 30,
                                                          ),
                                                          // if (privateChat ==
                                                          //     '1') // Check if privateChat is 1 to show the indicator
                                                          //   Padding(
                                                          //     padding: EdgeInsets.only(
                                                          //         top: 0.0,
                                                          //         right: 0.0,
                                                          //         left: 10,
                                                          //         bottom:
                                                          //             10), // Add padding here
                                                          //     child: Container(
                                                          //       width: 10,
                                                          //       height: 10,
                                                          //       decoration: BoxDecoration(
                                                          //         color: brightGreen,
                                                          //         shape: BoxShape.circle,
                                                          //       ),
                                                          //     ),
                                                          //   ),
                                                        ],
                                                      ),
                                                    if (privateChat ==
                                                        '1') // Check if privateChat is 1 to show the indicator
                                                      Padding(
                                                        padding: EdgeInsets.only(
                                                            top: 0.0,
                                                            right: 0.0,
                                                            left: 0,
                                                            bottom:
                                                                0), // Add padding here
                                                        child: Container(
                                                          width: 10,
                                                          height: 10,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: brightGreen,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                        ),
                                                      ),
                                                    SizedBox(width: 8.0),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            replyMsg,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 20),
                                                          ),
                                                          SizedBox(height: 4.0),
                                                          Text(
                                                            timestamp,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                  )
                                : GestureDetector(
                                    onLongPress: () {
                                      // Show the custom dialog when the message is long-pressed
                                      if (privateChat == '1') {
                                        messageLongPressDialog(
                                          context,
                                          () {
                                            // Handle Report Abuse action

                                            reportUser(
                                                reply.uid.toString(),
                                                reply.rid.toString(),
                                                reply.replyMsg);
                                          },
                                          () {
                                            // Handle Ignore User action
                                            ignoreUser(getDeviceType(),
                                                reply.uid.toString());
                                          },
                                          () {
                                            // // Handle Start Private Chat action
                                            // // Implement the logic for starting a private chat here

                                            // List<String> userName =
                                            //     replyMsg.split(" ");

                                            // print('private chat ${userName[0]}');

                                            // //sendPrivateChatInvite();
                                            // // sendRequest(
                                            // //     '1', '2', reply.emojiId, userName[0]);
                                            // sendRequest(
                                            //     '1',
                                            //     '2',
                                            //     currentUserEmojiId!,
                                            //     currentUserHandle!,
                                            //     reply.emojiId,
                                            //     userName[0]);

                                            print(
                                                '##################################################');

                                            print(
                                                'dddddddddddddddddriver name $driverName ');

                                            String receiverUserName = '';
                                            if (driverName == '') {
                                              List<String> userName =
                                                  replyMsg.split(" ");
                                              receiverUserName = userName[0];
                                            } else {
                                              receiverUserName = driverName;
                                            }

                                            print(
                                                'private chat $receiverUserName');

                                            //sendPrivateChatInvite();
                                            // sendRequest(
                                            //     '1', '2', reply.emojiId, userName[0]);

                                            String? chatHandle = SharedPrefs
                                                .getString(SharedPrefsKeys
                                                    .CURRENT_USER_CHAT_HANDLE);
                                            print('chat handle $chatHandle');
                                            int? avatarId = SharedPrefs.getInt(
                                                SharedPrefsKeys
                                                    .CURRENT_USER_AVATAR_ID);
                                            if (chatHandle == null) {
                                              showChatHandleDialog(context);
                                            } else if (avatarId == null) {
                                              showAvatarSelectionDialog(
                                                  context);
                                            } else {
                                              sendRequest(
                                                  currentUserId!,
                                                  reply.uid.toString(),
                                                  currentUserEmojiId ??
                                                      avatarId.toString(),
                                                  currentUserHandle ??
                                                      chatHandle,
                                                  reply.emojiId,
                                                  capitalizeFirstLetter(
                                                      receiverUserName));
                                            }
                                          },
                                        );
                                      } else {
                                        messageLongPressDialogWithoutPrivateChat(
                                          context,
                                          () {
                                            // Handle Report Abuse action
                                            reportUser(
                                                reply.uid.toString(),
                                                reply.rid.toString(),
                                                reply.replyMsg);
                                          },
                                          () {
                                            // Handle Ignore User action
                                            ignoreUser(getDeviceType(),
                                                reply.uid.toString());
                                          },
                                        );
                                      }
                                    },
                                    child: ChatBubble(
                                      clipper: ChatBubbleClipper6(
                                          type: isCurrentUser
                                              ? BubbleType.sendBubble
                                              : BubbleType.receiverBubble),
                                      alignment: isCurrentUser
                                          ? Alignment.topRight
                                          : Alignment.topLeft,
                                      margin: EdgeInsets.only(bottom: 16.0),
                                      backGroundColor: isCurrentUser
                                          ? Colors.blue[100]
                                          : Colors.blue[300],
                                      child: isCurrentUser
                                          ? Container(
                                              constraints: BoxConstraints(
                                                  maxWidth: 250.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (SharedPrefs.getString(
                                                              SharedPrefsKeys
                                                                  .CURRENT_USER_AVATAR_IMAGE_PATH) !=
                                                          null)
                                                        Image.asset(
                                                          SharedPrefs.getString(
                                                              SharedPrefsKeys
                                                                  .CURRENT_USER_AVATAR_IMAGE_PATH)!,
                                                          width: 30,
                                                          height: 30,
                                                        ),
                                                      SizedBox(width: 8.0),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              driverName +
                                                                  replyMsg,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 20),
                                                            ),
                                                            SizedBox(
                                                                height: 4.0),
                                                            Text(
                                                              timestamp,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(
                                              constraints: BoxConstraints(
                                                  maxWidth: 250.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (matchingAvatar.id !=
                                                          0)
                                                        Stack(
                                                          alignment: Alignment(
                                                              2.6,
                                                              -2.4), // Adjust the alignment here

                                                          children: [
                                                            Image.asset(
                                                              matchingAvatar
                                                                  .imagePath,
                                                              width: 30,
                                                              height: 30,
                                                            ),
                                                            // if (privateChat ==
                                                            //     '1') // Check if privateChat is 1 to show the indicator
                                                            //   Padding(
                                                            //     padding: EdgeInsets.only(
                                                            //         top: 0.0,
                                                            //         right: 0.0,
                                                            //         left: 10,
                                                            //         bottom:
                                                            //             10), // Add padding here
                                                            //     child: Container(
                                                            //       width: 10,
                                                            //       height: 10,
                                                            //       decoration:
                                                            //           BoxDecoration(
                                                            //         color:
                                                            //             brightGreen,
                                                            //         shape: BoxShape
                                                            //             .circle,
                                                            //       ),
                                                            //     ),
                                                            //   ),
                                                          ],
                                                        ),
                                                      if (privateChat ==
                                                          '1') // Check if privateChat is 1 to show the indicator
                                                        Padding(
                                                          padding: EdgeInsets.only(
                                                              top: 0.0,
                                                              right: 0.0,
                                                              left: 0,
                                                              bottom:
                                                                  0), // Add padding here
                                                          child: Container(
                                                            width: 10,
                                                            height: 10,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  brightGreen,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                          ),
                                                        ),
                                                      SizedBox(width: 8.0),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              replyMsg,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 20,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 4.0),
                                                            Text(timestamp),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ),
                                  ),
                          );
                        } else {
                          final sentIndex = index - filteredReplyMsgs.length;
                          final sentMessage = sentMessages[sentIndex];
                          final timestampp = sentMessage.timestamp;

                          DateTime dateTime =
                              DateTime.fromMillisecondsSinceEpoch(timestampp);
                          String formattedDateTime =
                              DateFormat('MMM d, yyyy h:mm:ss a')
                                  .format(dateTime);
                          final timestamp = formattedDateTime;

                          bool isCurrentUser = sentMessage.uid ==
                              userId; // Check if the user_id is equal to 69979

                          return Padding(
                            padding: EdgeInsets.all(8.0),
                            child: ChatBubble(
                              clipper: ChatBubbleClipper6(
                                  type: isCurrentUser
                                      ? BubbleType.sendBubble
                                      : BubbleType.receiverBubble),
                              alignment: isCurrentUser
                                  ? Alignment.topRight
                                  : Alignment.topLeft,
                              margin: EdgeInsets.only(bottom: 16.0),
                              backGroundColor: Colors.blue[300],
                              child: Container(
                                constraints: BoxConstraints(maxWidth: 250.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sentMessage.replyMsg,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      timestamp,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.mic),
                    onPressed: () {
                      _toggleListening();
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: Constants.COMPOSE_MESSAGE,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  FloatingActionButton(
                    onPressed: () async {
                      String message = messageController.text.trim();
                      if (!message.isEmpty) {
                        String? chatHandle = SharedPrefs.getString(
                            SharedPrefsKeys.CURRENT_USER_CHAT_HANDLE);
                        int? avatarId = SharedPrefs.getInt(
                            SharedPrefsKeys.CURRENT_USER_AVATAR_ID);
                        if (chatHandle == null) {
                          showChatHandleDialog(context);
                        } else if (avatarId == null) {
                          showAvatarSelectionDialog(context);
                        } else {
                          await sendMessage(
                            messageController.text,
                            widget.serverMsgId,
                            userId,
                          );
                          // if (messageSent) {
                          //   print('message sent');

                          //   // sendFCMNotification('all', 'message');

                          //   // setState(() {
                          //   //   WidgetsBinding.instance?.addPostFrameCallback(
                          //   //       (_) => scrollToBottom());
                          //   // });

                          //   // Message sent successfully, handle any UI updates if needed
                          // } else {
                          //   print('message failed');
                          //   // Failed to send the message, handle any UI updates if needed
                          // }
                          setState(() {
                            messageController.clear();
                          });
                        }
                      }
                    },
                    backgroundColor: Colors.blue,
                    child: sendingMessage // Check sending state
                        ? CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ) // Show progress indicator
                        : Icon(Icons.send),
                  ),
                ],
              ),
            ),
            AdmobBanner(
              adUnitId: AdHelper.bannerAdUnitId,
              adSize: AdmobBannerSize.ADAPTIVE_BANNER(
                  width: MediaQuery.of(context).size.width.toInt()),
            )
          ],
        ),
      ),
    );
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void sendRequest(String senderId, String receiverId, String emojiId,
      String userName, String receiverEmojiId, String receiverUserName) {
    DatabaseReference requestsRef =
        FirebaseDatabase.instance.ref().child('requests');

    Request request = Request(
      senderId: senderId,
      receiverId: receiverId,
      status: 'pending',
      senderEmojiId: receiverEmojiId,
      senderUserName: receiverUserName,
      receiverEmojiId: emojiId,
      receiverUserName: userName,
    );
    requestsRef.push().set(request.toJson());

    sendPrivateChatRequest(context, 'Your request has been sent.',
        'Once user accepted your request chat list will appear in private chat tab');
  }

  Future<bool> reportUser(
    String flagger_user_id,
    String post_id,
    String user_notes,
  ) async {
    print('flagger_user_id $flagger_user_id');
    print('post_id $post_id');
    print('user_notes $user_notes');

    int status_code = 0;
    final url = Uri.parse(API.REPORT_ABUSE);
    final headers = {'Content-Type': 'application/json'};
    // final ignoredUserArray = [flagger_user_id];

    try {
      final entity = {
        'user_id': userId,
        'post_id': post_id,
        'flagger_user_id': flagger_user_id,
        'user_notes': user_notes,
      };

      final response =
          await http.post(url, headers: headers, body: jsonEncode(entity));

      if (response.statusCode == 200) {
        final jsonResult = json.decode(response.body);
        print('json body ${response.body}');
        status_code = jsonResult['status'];
        print('status_code $status_code');

        if (status_code == 200) {
          showReportAbuseSuccessDialog(
              context, 'User Reported', 'Reported Message: ', user_notes);
        } else if (status_code == 501) {
          showReportAbuseSuccessDialog(context, 'User Already Reported',
              'Reported Message: ', user_notes);
        }

        if (jsonResult.containsKey('message')) {
          status_message = jsonResult['message'];
          print('status_message $status_message');
        } else {
          status_message = '';
        }

        return true;
      } else {
        status_message =
            'Server Error'; // Or handle other status codes appropriately
      }
    } catch (e) {
      status_message = e.toString();
    }

    return false;
  }

  Future<bool> ignoreUser(String deviceType, String ignoredUserId) async {
    final url = Uri.parse(API.IGNORE_USER);
    final headers = {'Content-Type': 'application/json'};

    print('deviceType $deviceType');
    print('ignoredUserId $ignoredUserId');

    int status_code = 0;

    try {
      //  final jsonArray = [ignoredUserId];

      final entity = {
        'user_id': userId,
        'device_type': deviceType,
        'ignore_user_id': ignoredUserId,
      };

      final response =
          await http.post(url, headers: headers, body: jsonEncode(entity));

      if (response.statusCode == 200) {
        final jsonResult = json.decode(response.body);
        print('json body ${response.body}');

        status_code = jsonResult['status'];
        print('status_code $status_code');

        if (status_code == 200) {
          showIgnoreUserSuccessDialog(context, 'User added in ignored list.');
        } else if (status_code == 500) {
          showIgnoreUserSuccessDialog(context, 'User already ignored');
        }

        if (jsonResult.containsKey('message')) {
          status_message = jsonResult['message'];
          print('status_message $status_message');
        } else {
          status_message = '';
        }

        return true;
      } else {
        status_message =
            'Server Error'; // Or handle other status codes appropriately
      }
    } catch (e) {
      status_message = e.toString();
    }

    return false;
  }

  void _showReportAbuseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Constants.REPORT_ABUSE),
          content: Text(DialogStrings.TO_REPORT_ABUSE),
          actions: [
            TextButton(
              child: Text(DialogStrings.GOT_IT),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleListening() {
    _startListening();
  }

  void _startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            messageController.text = result.recognizedWords;
            _typedText = result.recognizedWords;
          });
        },
        listenMode: stt.ListenMode.dictation,
        pauseFor: Duration(seconds: 2),
      );
      setState(() {
        _isListening = true;
      });
    }
  }

  void _stopListening() {
    _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }
}

class Request {
  final String senderId;
  final String receiverId;
  final String status;
  final String senderEmojiId;
  final String senderUserName;
  final String receiverEmojiId;
  final String receiverUserName;

  Request({
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.senderEmojiId,
    required this.senderUserName,
    required this.receiverEmojiId,
    required this.receiverUserName,
  });

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status,
      'senderEmojiId': senderEmojiId,
      'senderUserName': senderUserName,
      'receiverEmojiId': receiverEmojiId,
      'receiverUserName': receiverUserName,
    };
  }
}
