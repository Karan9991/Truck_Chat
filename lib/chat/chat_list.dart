// import 'package:chat/chat/new_conversation.dart';
// import 'package:chat/chat/chat.dart';
// import 'package:chat/settings/settings.dart';
// import 'package:chat/utils/ads.dart';
// import 'package:chat/utils/alert_dialog.dart';
// import 'package:chat/utils/constants.dart';
// import 'package:chat/utils/register_user.dart';
// import 'package:chat/utils/shared_pref.dart';
// import 'package:chat/get_all_reply_messages.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:chat/home_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'dart:async';
// import 'package:chat/chat/conversation_data.dart';
// import 'package:admob_flutter/admob_flutter.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:app_settings/app_settings.dart';
// import 'package:location/location.dart';
// import 'package:url_launcher/url_launcher.dart';

// class ChatListr extends StatefulWidget {
//   final Key key;

//   ChatListr({
//     required this.key,
//   });

//   @override
//   _ChatListrState createState() => _ChatListrState();
// }

// class _ChatListrState extends State<ChatListr>
//     with AutomaticKeepAliveClientMixin {
//   final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

//   List<String> conversationTopics = [];
//   List<int> conversationTimestamps = [];

//   List<String> replyCounts = [];
//   List<ReplyMsg> replyMsgs = [];

//   int statusCode = 0;
//   String statusMessage = '';
//   List<String> serverMsgIds = [];

//   bool isLoading = true;

//   Location location = Location();
//   late PermissionStatus _permissionGranted;

//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();

//     getData().then((_) {
//       setState(() {
//         isLoading = false;
//       });
//     });

//     InterstitialAdManager.initialize();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     InterstitialAdManager.dispose();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     // Call getData() when dependencies change (e.g., user returns to screen)
//     getData();
//   }

//   Future<void> storedList() async {
//     List<Conversation> storedConversations = await getStoredConversations();
//     for (var conversation in storedConversations) {
//       print('Conversation ID: ${conversation.conversationId}');
//       print('Reply Count: ${conversation.replyCount}');
//       print('Is Read: ${conversation.isRead}');
//       print('---------------------');
//     }
//   }

//   Future<void> getData() async {
//     _permissionGranted = await location.hasPermission();

//     if (_permissionGranted == PermissionStatus.granted ||
//         _permissionGranted == PermissionStatus.grantedLimited) {
//       await getConversationsData();
//     } else {
//       registerDevice();
//       await getConversationsData();
//     }
//   }

//   Future<void> getConversationsData() async {
//     String? userId = SharedPrefs.getString(SharedPrefsKeys.USER_ID);
//     double? storedLatitude = SharedPrefs.getDouble(SharedPrefsKeys.LATITUDE);
//     double? storedLongitude = SharedPrefs.getDouble(SharedPrefsKeys.LONGITUDE);

//     Uri url = Uri.parse(API.CONVERSATION_LIST);
//     Map<String, dynamic> requestBody = {
//       API.USER_ID: userId,
//       API.LATITUDE: storedLatitude.toString(),
//       API.LONGITUDE: storedLongitude.toString(),
//     };

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: {API.CONTENT_TYPE: API.APPLICATION_JSON},
//         body: jsonEncode(requestBody),
//       );

//       if (response.statusCode == 200) {
//         print('---------------ChatList Response---------------');
//         print(response.body);
//         // print('--------------------------------------');

//         Map<String, dynamic> jsonResponse = jsonDecode(response.body);

//         List<dynamic> serverMsgIds = jsonResponse[API.SERVER_MSG_ID];
//         List<String> serverMsgIdsList =
//             List<String>.from(serverMsgIds.map((e) => e.toString()));

//         this.serverMsgIds = serverMsgIdsList;

//         int statusCode = 0;
//         String counts = '';
//         int conversationTimestamp = 0;
//         List<ReplyMsg> replyMsgs = [];
//         String statusMessage = '';
//         String conversationTopic = '';

//         List<Conversation> conversations = [];
//         List<Conversation> storedConversations = await getStoredConversations();

//         final url = Uri.parse(API.CHAT);

//         // print('Stored Conversations: $storedConversations');

//         for (var serverMessageId in serverMsgIdsList) {
//           Map<String, dynamic> requestBody = {
//             API.SERVER_MESSAGE_ID: serverMessageId,
//           };

//           try {
//             http.Response response = await http.post(
//               url,
//               headers: {API.CONTENT_TYPE: API.APPLICATION_JSON},
//               body: jsonEncode(requestBody),
//             );

//             if (response.statusCode == 200) {
//               final result = response.body;
//               print('---------------Messsage Replies Response---------------');

//               //   print(response.body);

//               // print('--------------------------------------');

//               try {
//                 final jsonResult = jsonDecode(result);

//                 counts = jsonResult[API.COUNTS];
//                 conversationTopic = jsonResult[API.ORIGINAL];
//                 conversationTimestamp = jsonResult[API.TIMESTAMP] ?? 0;

//                 conversationTopics.add(conversationTopic);
//                 conversationTimestamps.add(conversationTimestamp);
//                 replyCounts.add(counts);

//                 // Create a Conversation object
//                 Conversation conversation = Conversation(
//                   conversationId: serverMessageId,
//                   replyCount: counts,
//                   isRead: false,
//                 );

//                 // Check if the conversation already exists in stored conversations
//                 Conversation existingConversation =
//                     storedConversations.firstWhere(
//                   (c) => c.conversationId == serverMessageId,
//                   orElse: () => conversation,
//                 );

//                 // Check if the reply count matches
//                 if (existingConversation.replyCount != counts) {
//                   // If reply count doesn't match, mark as read
//                   conversation.isRead = false;
//                   //  print('Marked as unread: $serverMessageId');
//                   // print(
//                   //    'Conversation: $serverMessageId - Stored Reply Count: ${existingConversation.replyCount}, Fetched Reply Count: $counts');
//                 } else {
//                   // Otherwise, preserve the existing isRead status
//                   conversation.isRead = existingConversation.isRead;
//                 }

//                 conversations.add(conversation);
//               } catch (e) {
//                 // Handle JSON decoding error
//               }
//             } else {
//               // Handle connection error
//             }
//           } catch (e) {
//             // Handle exception
//           }
//         }
//         // Store conversations in shared preferences
//         await storeConversations(conversations);
//       } else {
//         // Handle connection error
//       }
//     } catch (e) {
//       // Handle exception
//     }
//   }

//   Future<void> _openAppSettings() async {
//    await AppSettings.openAppSettings(type: AppSettingsType.location);

//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: null,
//       body: FutureBuilder<List<Conversation>>(
//         future: getStoredConversations(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting ||
//               isLoading) {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//           if (_permissionGranted == PermissionStatus.denied ||
//               _permissionGranted == PermissionStatus.deniedForever) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'Location Permission required',
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 14), // Add
//                   Text(
//                     'to enable chat feature.',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   SizedBox(height: 14), // Add
//                   Text(
//                     'Open Settings to turn on location.',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   SizedBox(height: 16),
//                   TextButton(
//                     onPressed: () {
//                       _openAppSettings();
//                     },
//                     style: TextButton.styleFrom(
//                       foregroundColor: Colors.white,
//                       backgroundColor: Colors.blue,
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(24),
//                       ),
//                     ),
//                     child: Text(
//                       'Open Settings',
//                       style: TextStyle(fontSize: 18),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           } else if (snapshot.hasData) {
//             List<Conversation> storedConversations = snapshot.data!;

//             if (storedConversations.isEmpty) {
//               return Center(
//                 child: Text(''),
//               );
//             }

//             return ListView.builder(
//                 // itemCount: conversationTopics.length,
//                 itemCount: conversationTopics.length +
//                     (conversationTopics.length ~/ 5),
//                 itemBuilder: (context, index) {
//                   if (index % 6 == 5) {
//                     // Check if it's the ad banner index
//                     // The ad banner should be shown after every 5 items (0-based index)
//                     return AdBannerWidget();
//                   } else {
//                     // Calculate the actual index in the conversation topics list
//                     final conversationIndex = index - (index ~/ 6);
//                     final conversation = storedConversations[conversationIndex];
//                     final topic = conversationTopics[conversationIndex];
//                     final timestampp =
//                         conversationTimestamps[conversationIndex];
//                     final count = replyCounts[conversationIndex];
//                     final serverMsgID = serverMsgIds[conversationIndex];

//                     DateTime dateTime =
//                         DateTime.fromMillisecondsSinceEpoch(timestampp);
//                     String formattedDateTime =
//                         DateFormat('MMM d, yyyy h:mm:ss a').format(dateTime);
//                     final timestamp = formattedDateTime;

//                     final isRead = conversation.isRead;

//                     // print('List item read status $isRead');

//                     return GestureDetector(
//                       onTap: () async {
//                         if (!isRead) {
//                           // Mark conversation as read
//                           conversation.isRead = true;
//                           await storeConversations(storedConversations);
//                           setState(() {}); // Trigger a rebuild of the widget
//                         }

//                         InterstitialAdManager.showInterstitialAd();

//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => Chat(
//                               topic: topic,
//                               serverMsgId: serverMsgID,
//                             ),
//                           ),
//                         ).then((_) {
//                           // Called when returning from the chat screen
//                           setState(() {}); // Trigger a rebuild of the widget
//                         });
//                       },
//                       onLongPress: () {
//                         showDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             return AlertDialog(
//                               content: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   isRead
//                                       ? _buildDialogOption(
//                                           DialogStrings.MARK_CHAT_THIS_UNREAD,
//                                           DialogStrings.MARK_CHAT_UNREAD,
//                                           () async {
//                                           print('Chat UnRead');
//                                           conversation.isRead = false;
//                                           await storeConversations(
//                                               storedConversations);
//                                           setState(() {});

//                                           Navigator.of(context)
//                                               .pop(); // Close the dialog if needed
//                                         })
//                                       : _buildDialogOption(
//                                           DialogStrings.MARK_CHAT_READ,
//                                           DialogStrings.MESSAGE_ICON_WILL,
//                                           () async {
//                                           print('Chat Read');
//                                           conversation.isRead = true;
//                                           await storeConversations(
//                                               storedConversations);
//                                           setState(() {});

//                                           Navigator.of(context)
//                                               .pop(); // Close the dialog if needed
//                                         }),
//                                 ],
//                               ),
//                               actions: [
//                                 TextButton(
//                                   child: Text(DialogStrings.CANCEL),
//                                   onPressed: () {
//                                     Navigator.of(context).pop();
//                                   },
//                                 ),
//                               ],
//                             );
//                           },
//                         );
//                       },
//                       child: Card(
//                         elevation: 2,
//                         color: Colors.blue[300],
//                         margin:
//                             EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         child: ListTile(
//                           title: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               isRead
//                                   ? SizedBox()
//                                   : Row(
//                                       children: [
//                                         Icon(
//                                           Icons.chat,
//                                           size: 17,
//                                         ),
//                                         SizedBox(width: 8),
//                                       ],
//                                     ),
//                               Text(
//                                 topic,
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: isRead
//                                       ? FontWeight.normal
//                                       : FontWeight.bold,
//                                 ),
//                                 overflow: TextOverflow
//                                     .ellipsis, // Show ellipsis if the text overflows
//                                 maxLines: 3, // Show only one line of text
//                               ),
//                             ],
//                           ),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Padding(
//                                 padding: EdgeInsets.only(bottom: 5, top: 8),
//                                 child: Text(
//                                   '${Constants.LAST_ACTIVE}$timestamp',
//                                   style: TextStyle(fontSize: 14),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: EdgeInsets.only(bottom: 5),
//                                 child: Text(
//                                   '${Constants.REPLIES}$count',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: isRead
//                                         ? FontWeight.normal
//                                         : FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           trailing: Icon(
//                             Icons.arrow_forward_ios,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     );
//                   }
//                 });
//           } else {
//             // Handle error case
//             return Center(
//               child: Text(''),
//             );
//           }
//         },
//       ),
//     );
//   }

//   Widget _buildDialogOption(String title, String subtitle, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.only(bottom: 16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//               ),
//             ),
//             SizedBox(height: 4),
//             Text(
//               subtitle,
//               style: TextStyle(color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//testing 1 for put add in 5 entries

// import 'package:chat/chat/new_conversation.dart';
// import 'package:chat/chat/chat.dart';
// import 'package:chat/main.dart';
// import 'package:chat/settings/settings.dart';
// import 'package:chat/utils/ads.dart';
// import 'package:chat/utils/alert_dialog.dart';
// import 'package:chat/utils/constants.dart';
// import 'package:chat/utils/register_user.dart';
// import 'package:chat/utils/shared_pref.dart';
// import 'package:chat/get_all_reply_messages.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:chat/home_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'dart:async';
// import 'package:chat/chat/conversation_data.dart';
// import 'package:admob_flutter/admob_flutter.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:app_settings/app_settings.dart';
// import 'package:location/location.dart';

// class ChatListr extends StatefulWidget {
//   final Key key;

//   ChatListr({
//     required this.key,
//   });

//   @override
//   _ChatListrState createState() => _ChatListrState();
// }

// class _ChatListrState extends State<ChatListr>
//     with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
//   final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

//   List<String> conversationTopics = [];
//   List<int> conversationTimestamps = [];

//   List<String> replyCounts = [];
//   List<ReplyMsg> replyMsgs = [];

//   int statusCode = 0;
//   String statusMessage = '';
//   List<String> serverMsgIds = [];

//   bool isLoading = true;

//   Location location = Location();
//   late PermissionStatus _permissionGranted;
//   //bool isAppSettingsOpen = false;
//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();
//     InterstitialAdManager.initialize();

//     print('iiiiiiiiiiiiiiiinit called');

//     WidgetsBinding.instance.addObserver(this);

//     getData().then((_) {
//       setState(() {
//         isLoading = false;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);

//     super.dispose();
//     InterstitialAdManager.dispose();
//   }

//   Future<void> storedList() async {
//     List<Conversation> storedConversations = await getStoredConversations();
//     for (var conversation in storedConversations) {
//       print('Conversation ID: ${conversation.conversationId}');
//       print('Reply Count: ${conversation.replyCount}');
//       print('Is Read: ${conversation.isRead}');
//       print('---------------------');
//     }
//   }

//   Future<void> getData() async {
//     _permissionGranted = await location.hasPermission();

//     if (_permissionGranted == PermissionStatus.granted ||
//         _permissionGranted == PermissionStatus.grantedLimited) {
//       await getConversationsData();
//     } else {
//       // await registerDevice();
//       // await getConversationsData();
//     }
//   }

//   // Future<void> getData() async {
//   //   _permissionGranted = await location.hasPermission();

//   //   if (_permissionGranted == PermissionStatus.denied ||
//   //       _permissionGranted == PermissionStatus.deniedForever) {
//   //     print('get data permission denied');
//   //   } else {
//   //     print('get data else');
//   //     await registerDevice();
//   //     await getConversationsData();
//   //   }
//   // }

//   Future<void> getConversationsData() async {
//     String? userId = SharedPrefs.getString(SharedPrefsKeys.USER_ID);
//     double? storedLatitude = SharedPrefs.getDouble(SharedPrefsKeys.LATITUDE);
//     double? storedLongitude = SharedPrefs.getDouble(SharedPrefsKeys.LONGITUDE);

//     Uri url = Uri.parse(API.CONVERSATION_LIST);
//     Map<String, dynamic> requestBody = {
//       API.USER_ID: userId,
//       API.LATITUDE: storedLatitude.toString(),
//       API.LONGITUDE: storedLongitude.toString(),
//     };

//     try {
//       http.Response response = await http.post(
//         url,
//         headers: {API.CONTENT_TYPE: API.APPLICATION_JSON},
//         body: jsonEncode(requestBody),
//       );

//       if (response.statusCode == 200) {
//         print('---------------ChatList Response---------------');
//         print(response.body);
//         // print('--------------------------------------');

//         Map<String, dynamic> jsonResponse = jsonDecode(response.body);

//         List<dynamic> serverMsgIds = jsonResponse[API.SERVER_MSG_ID];
//         List<String> serverMsgIdsList =
//             List<String>.from(serverMsgIds.map((e) => e.toString()));

//         this.serverMsgIds = serverMsgIdsList;

//         int statusCode = 0;
//         String counts = '';
//         int conversationTimestamp = 0;
//         List<ReplyMsg> replyMsgs = [];
//         String statusMessage = '';
//         String conversationTopic = '';

//         List<Conversation> conversations = [];
//         List<Conversation> storedConversations = await getStoredConversations();

//         final url = Uri.parse(API.CHAT);

//         // print('Stored Conversations: $storedConversations');

//         for (var serverMessageId in serverMsgIdsList) {
//           Map<String, dynamic> requestBody = {
//             API.SERVER_MESSAGE_ID: serverMessageId,
//           };

//           try {
//             http.Response response = await http.post(
//               url,
//               headers: {API.CONTENT_TYPE: API.APPLICATION_JSON},
//               body: jsonEncode(requestBody),
//             );

//             if (response.statusCode == 200) {
//               final result = response.body;
//               print('---------------Messsage Replies Response---------------');

//               //   print(response.body);

//               // print('--------------------------------------');

//               try {
//                 final jsonResult = jsonDecode(result);

//                 counts = jsonResult[API.COUNTS];
//                 conversationTopic = jsonResult[API.ORIGINAL];
//                 conversationTimestamp = jsonResult[API.TIMESTAMP] ?? 0;

//                 conversationTopics.add(conversationTopic);
//                 conversationTimestamps.add(conversationTimestamp);
//                 replyCounts.add(counts);

//                 // Create a Conversation object
//                 Conversation conversation = Conversation(
//                   conversationId: serverMessageId,
//                   replyCount: counts,
//                   isRead: false,
//                 );

//                 // Check if the conversation already exists in stored conversations
//                 Conversation existingConversation =
//                     storedConversations.firstWhere(
//                   (c) => c.conversationId == serverMessageId,
//                   orElse: () => conversation,
//                 );

//                 // Check if the reply count matches
//                 if (existingConversation.replyCount != counts) {
//                   // If reply count doesn't match, mark as read
//                   conversation.isRead = false;
//                   //  print('Marked as unread: $serverMessageId');
//                   // print(
//                   //    'Conversation: $serverMessageId - Stored Reply Count: ${existingConversation.replyCount}, Fetched Reply Count: $counts');
//                 } else {
//                   // Otherwise, preserve the existing isRead status
//                   conversation.isRead = existingConversation.isRead;
//                 }

//                 conversations.add(conversation);

//                 //  setState(() {});
//               } catch (e) {
//                 // Handle JSON decoding error
//               }
//             } else {
//               // Handle connection error
//             }
//           } catch (e) {
//             // Handle exception
//           }
//         }
//         // Store conversations in shared preferences
//         await storeConversations(conversations);
//       } else {
//         // Handle connection error
//       }
//     } catch (e) {
//       // Handle exception
//     }
//   }

//   Future<void> _openAppSettings(BuildContext context) async {
//     SharedPrefs.setBool('isAppSettingsOpen', true);
//     setState(() {
//       //isAppSettingsOpen = true;

//       isLoading = true;
//     });
//     await AppSettings.openAppSettings(type: AppSettingsType.location);
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) async {
//     Location location = Location();
//     late PermissionStatus _permissionGranted;
//     bool isAppOpenSettings = SharedPrefs.getBool('isAppSettingsOpen') ?? false;

//     print('-----------start-------------');
//     print('AppLifecycleState: $state'); // Add this line

//     print('iiiiiiiiiiiiisloading $isLoading');
//     print('iiiiiiiiiiiiiappopen $isAppOpenSettings');

//     if (state == AppLifecycleState.resumed && isAppOpenSettings) {
//       setState(() {
//         isLoading = true;
//       });
//       SharedPrefs.setBool('isAppSettingsOpen', false);

//       print('iiiiiiiiiiiiisiffloading $isLoading');

//       _permissionGranted = await location.hasPermission();

//       print('ppppppppppermission $_permissionGranted');

//       if (_permissionGranted == PermissionStatus.granted ||
//           _permissionGranted == PermissionStatus.grantedLimited) {
//         print('if Screen refreshed after returning from settings');

//         await registerDevice();
//         await getData();
//         setState(() {
//           isLoading = false;
//         });
//       } else {
//         print('eeelllssee');
//       }

//       setState(() {
//         isLoading = false;
//       });
//       // }
//       print('iiiiiiiiiiiiisendloading $isLoading');
//     } else {
//       print('main else');
//     }
//     print('------------end-------------');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: null,
//       body: FutureBuilder<List<Conversation>>(
//         future: getStoredConversations(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting ||
//               isLoading) {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//           if (_permissionGranted == PermissionStatus.denied ||
//               _permissionGranted == PermissionStatus.deniedForever) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'Location Permission required',
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 14), // Add
//                   Text(
//                     'to enable chat feature.',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   SizedBox(height: 14), // Add
//                   Text(
//                     'Open Settings to turn on location.',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   SizedBox(height: 16),
//                   TextButton(
//                     onPressed: () {
//                       _openAppSettings(context);
//                     },
//                     style: TextButton.styleFrom(
//                       foregroundColor: Colors.white,
//                       backgroundColor: Colors.blue,
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(24),
//                       ),
//                     ),
//                     child: Text(
//                       'Open Settings',
//                       style: TextStyle(fontSize: 18),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           } else if (snapshot.hasData) {
//             List<Conversation> storedConversations = snapshot.data!;

//             if (storedConversations.isEmpty) {
//               return Center(
//                 child: Text(''),
//               );
//             }

//             return ListView.builder(
//                 // itemCount: conversationTopics.length,
//                 itemCount: conversationTopics.length +
//                     (conversationTopics.length ~/ 4),
//                 itemBuilder: (context, index) {
//                   if (index % 5 == 4) {
//                     // Check if it's the ad banner index
//                     // The ad banner should be shown after every 5 items (0-based index)
//                     return AdBannerWidget();
//                   } else {
//                     // Calculate the actual index in the conversation topics list
//                     final conversationIndex = index - (index ~/ 5);
//                     final conversation = storedConversations[conversationIndex];
//                     final topic = conversationTopics[conversationIndex];
//                     final timestampp =
//                         conversationTimestamps[conversationIndex];
//                     final count = replyCounts[conversationIndex];
//                     final serverMsgID = serverMsgIds[conversationIndex];

//                     DateTime dateTime =
//                         DateTime.fromMillisecondsSinceEpoch(timestampp);
//                     String formattedDateTime =
//                         DateFormat('MMM d, yyyy h:mm:ss a').format(dateTime);
//                     final timestamp = formattedDateTime;

//                     final isRead = conversation.isRead;

//                     // print('List item read status $isRead');

//                     return GestureDetector(
//                       onTap: () async {
//                         if (!isRead) {
//                           // Mark conversation as read
//                           conversation.isRead = true;
//                           await storeConversations(storedConversations);
//                           setState(() {}); // Trigger a rebuild of the widget
//                         }

//                         InterstitialAdManager.showInterstitialAd();

//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => Chat(
//                               topic: topic,
//                               serverMsgId: serverMsgID,
//                             ),
//                           ),
//                         ).then((_) {
//                           // Called when returning from the chat screen
//                           setState(() {}); // Trigger a rebuild of the widget
//                         });
//                       },
//                       onLongPress: () {
//                         showDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             return AlertDialog(
//                               content: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   isRead
//                                       ? _buildDialogOption(
//                                           DialogStrings.MARK_CHAT_THIS_UNREAD,
//                                           DialogStrings.MARK_CHAT_UNREAD,
//                                           () async {
//                                           print('Chat UnRead');
//                                           conversation.isRead = false;
//                                           await storeConversations(
//                                               storedConversations);
//                                           setState(() {});

//                                           Navigator.of(context)
//                                               .pop(); // Close the dialog if needed
//                                         })
//                                       : _buildDialogOption(
//                                           DialogStrings.MARK_CHAT_READ,
//                                           DialogStrings.MESSAGE_ICON_WILL,
//                                           () async {
//                                           print('Chat Read');
//                                           conversation.isRead = true;
//                                           await storeConversations(
//                                               storedConversations);
//                                           setState(() {});

//                                           Navigator.of(context)
//                                               .pop(); // Close the dialog if needed
//                                         }),
//                                 ],
//                               ),
//                               actions: [
//                                 TextButton(
//                                   child: Text(DialogStrings.CANCEL),
//                                   onPressed: () {
//                                     Navigator.of(context).pop();
//                                   },
//                                 ),
//                               ],
//                             );
//                           },
//                         );
//                       },
//                       child: Card(
//                         elevation: 2,
//                         color: Colors.blue[300],
//                         margin:
//                             EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         child: ListTile(
//                           title: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               isRead
//                                   ? SizedBox()
//                                   : Row(
//                                       children: [
//                                         Icon(
//                                           Icons.chat,
//                                           size: 17,
//                                         ),
//                                         SizedBox(width: 8),
//                                       ],
//                                     ),
//                               Text(
//                                 topic,
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: isRead
//                                       ? FontWeight.normal
//                                       : FontWeight.bold,
//                                 ),
//                                 overflow: TextOverflow
//                                     .ellipsis, // Show ellipsis if the text overflows
//                                 maxLines: 3, // Show only one line of text
//                               ),
//                             ],
//                           ),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Padding(
//                                 padding: EdgeInsets.only(bottom: 5, top: 8),
//                                 child: Text(
//                                   '${Constants.LAST_ACTIVE}$timestamp',
//                                   style: TextStyle(fontSize: 14),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: EdgeInsets.only(bottom: 5),
//                                 child: Text(
//                                   '${Constants.REPLIES}$count',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: isRead
//                                         ? FontWeight.normal
//                                         : FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           trailing: Icon(
//                             Icons.arrow_forward_ios,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     );
//                   }
//                 });
//           } else {
//             // Handle error case
//             return Center(
//               child: Text(''),
//             );
//           }
//         },
//       ),
//     );
//   }

//   Widget _buildDialogOption(String title, String subtitle, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.only(bottom: 16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//               ),
//             ),
//             SizedBox(height: 4),
//             Text(
//               subtitle,
//               style: TextStyle(color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//testing for cache
import 'package:chat/chat/new_conversation.dart';
import 'package:chat/chat/chat.dart';
import 'package:chat/main.dart';
import 'package:chat/settings/settings.dart';
import 'package:chat/utils/ads.dart';
import 'package:chat/utils/alert_dialog.dart';
import 'package:chat/utils/constants.dart';
import 'package:chat/utils/register_user.dart';
import 'package:chat/utils/shared_pref.dart';
import 'package:chat/get_all_reply_messages.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chat/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:chat/chat/conversation_data.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_settings/app_settings.dart';
import 'package:location/location.dart';

class ChatListr extends StatefulWidget {
  final Key key;

  ChatListr({
    required this.key,
  });

  @override
  _ChatListrState createState() => _ChatListrState();
}

class _ChatListrState extends State<ChatListr>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  List<String> conversationTopics = [];
  List<int> conversationTimestamps = [];

  List<String> replyCounts = [];
  List<ReplyMsg> replyMsgs = [];

  int statusCode = 0;
  String statusMessage = '';
  List<String> serverMsgIds = [];

  bool isLoading = true;

  Location location = Location();
  PermissionStatus? _permissionGranted;
  //bool isAppSettingsOpen = false;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    InterstitialAdManager.initialize();

    print('iiiiiiiiiiiiiiiinit called');

    WidgetsBinding.instance.addObserver(this);

    // location.hasPermission().then((permission) {
    //   setState(() {
    //     _permissionGranted = permission;
    //   });
    // });

    getData().then((_) {
      setState(() {
        isLoading = false;
      });
    });
    // SharedPreferences.getInstance().then((prefs) async {
    //   // _permissionGranted = await location.hasPermission();

    //   bool isAppInstalled = prefs.getBool('isAppInstalled') ?? false;

    //  // if (isAppInstalled) {
    //     getData().then((_) {
    //       setState(() {
    //         isLoading = false;
    //       });
    //     });
    //  // }
    // });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
    InterstitialAdManager.dispose();
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
    _permissionGranted = await location.hasPermission();

    if (_permissionGranted == PermissionStatus.granted ||
        _permissionGranted == PermissionStatus.grantedLimited) {
      await getConversationsData();
    } else {
      // await registerDevice();
      // await getConversationsData();
    }
  }

  // Future<void> getData() async {
  //   _permissionGranted = await location.hasPermission();

  //   if (_permissionGranted == PermissionStatus.denied ||
  //       _permissionGranted == PermissionStatus.deniedForever) {
  //     print('get data permission denied');
  //   } else {
  //     print('get data else');
  //     await registerDevice();
  //     await getConversationsData();
  //   }
  // }

  Future<void> getConversationsData() async {
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

              //   print(response.body);

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
                  topic: conversationTopic,
                  timestamp: conversationTimestamp,
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

                //  setState(() {});
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
      } else {
        // Handle connection error
      }
    } catch (e) {
      // Handle exception
    }
  }

  Future<void> _openAppSettings(BuildContext context) async {
    SharedPrefs.setBool('isAppSettingsOpen', true);
    setState(() {
      //isAppSettingsOpen = true;

      isLoading = true;
    });
    await AppSettings.openAppSettings(type: AppSettingsType.location);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    Location location = Location();
    late PermissionStatus _permissionGranted;
    bool isAppOpenSettings = SharedPrefs.getBool('isAppSettingsOpen') ?? false;

    print('-----------start-------------');
    print('AppLifecycleState: $state'); // Add this line

    print('iiiiiiiiiiiiisloading $isLoading');
    print('iiiiiiiiiiiiiappopen $isAppOpenSettings');

    if (state == AppLifecycleState.resumed && isAppOpenSettings) {
      setState(() {
        isLoading = true;
      });
      SharedPrefs.setBool('isAppSettingsOpen', false);

      print('iiiiiiiiiiiiisiffloading $isLoading');

      _permissionGranted = await location.hasPermission();

      print('ppppppppppermission $_permissionGranted');

      if (_permissionGranted == PermissionStatus.granted ||
          _permissionGranted == PermissionStatus.grantedLimited) {
        print('if Screen refreshed after returning from settings');

        await registerDevice();
        await getData();
        setState(() {
          isLoading = false;
        });
      } else {
        print('eeelllssee');
      }

      setState(() {
        isLoading = false;
      });
      // }
      print('iiiiiiiiiiiiisendloading $isLoading');
    } else {
      print('main else');
    }
    print('------------end-------------');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: FutureBuilder<List<Conversation>>(
        future: getStoredConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            List<Conversation> storedConversations =
                snapshot.data ?? []; // Use cached data
            print('Stored Conversations: $storedConversations');

            if (_permissionGranted == PermissionStatus.denied ||
                _permissionGranted == PermissionStatus.deniedForever) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Location Permission required',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 14), // Add
                    Text(
                      'to enable chat feature.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 14), // Add
                    Text(
                      'Open Settings to turn on location.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        _openAppSettings(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        'Open Settings',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              );
            } else if (storedConversations.isNotEmpty) {
              // List<Conversation> storedConversations = snapshot.data!;

              // if (storedConversations.isEmpty) {
              //   return Center(
              //     child: Text(''),
              //   );
              // }

              return ListView.builder(
                  // itemCount: conversationTopics.length,

                  // itemCount: conversationTopics.length +
                  //     (conversationTopics.length ~/ 4),

                  //Step 1 start
                  itemCount: storedConversations.length +
                      (storedConversations.length ~/ 4),
                  //Step 1 end
                  itemBuilder: (context, index) {
                    print('Item Builder: $index');

                    if (index % 5 == 4) {
                      // Check if it's the ad banner index
                      // The ad banner should be shown after every 5 items (0-based index)
                      return AdBannerWidget();
                      // return _admobBanner;

                      // return Text('');
                    } else {
                      // Calculate the actual index in the conversation topics list
                      final conversationIndex = index - (index ~/ 5);
                      final conversation =
                          storedConversations[conversationIndex];

                      // final topic = conversationTopics[conversationIndex];
                      // final timestampp =
                      //     conversationTimestamps[conversationIndex];
                      // final count = replyCounts[conversationIndex];
                      // final serverMsgID = serverMsgIds[conversationIndex];

                      //Step 2 start
                      final topic =
                          conversation.topic; // Use topic from conversation
                      final timestampp = conversation
                          .timestamp; // Use timestamp from conversation
                      final count = conversation
                          .replyCount; // Use replyCount from conversation
                      final serverMsgID = conversation
                          .conversationId; // Use serverMsgId from conversation
                      //Step 2 start

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

                          //  InterstitialAdManager.showInterstitialAd();

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
                                    isRead
                                        ? _buildDialogOption(
                                            DialogStrings.MARK_CHAT_THIS_UNREAD,
                                            DialogStrings.MARK_CHAT_UNREAD,
                                            () async {
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
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                    fontWeight: isRead
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                                  overflow: TextOverflow
                                      .ellipsis, // Show ellipsis if the text overflows
                                  maxLines: 3, // Show only one line of text
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
                    }
                  }
                  );
            } else {
              return Center(
                child: Text(''),
              );
            }
          } else {
            // Handle error case
            return Center(
              child: Text(''),
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
