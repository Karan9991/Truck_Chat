// import 'package:chat/chat/new_conversation.dart';
// import 'package:chat/main.dart';
// import 'package:chat/privateChat/private_chat_homescreen.dart';
// import 'package:chat/chat/starred_chat_list.dart';
// import 'package:chat/news_tab.dart';
// import 'package:chat/chat/chat_list.dart';
// import 'package:chat/settings/settings.dart';
// import 'package:chat/utils/ads.dart';
// import 'package:chat/utils/alert_dialog.dart';
// import 'package:chat/utils/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'dart:io' show Platform;
// import 'package:provider/provider.dart';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:chat/utils/shared_pref.dart';
// import 'dart:convert';
// import 'dart:io';
// import 'package:admob_flutter/admob_flutter.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_beep/flutter_beep.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_database/firebase_database.dart';

// // import 'package:chat/reactivechat/chatlistreact.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
//   String? currentUserId;

//   int _selectedIndex = 1;
//   final List<Widget> _widgetOptions = [
//     NewsTab(
//       key: UniqueKey(),
//     ),
//     ChatListr(
//       key: UniqueKey(),
//     ),

//     // ChatList(key: UniqueKey()),
//     SponsorsTab(key: UniqueKey()),
//     ReviewsTab(key: UniqueKey()),
//     PrivateChatTab(key: UniqueKey()),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();

//     currentUserId = SharedPrefs.getString(SharedPrefsKeys.USER_ID);

//     getFCMToken(currentUserId!);

//     _refreshChatListWithFCM();

//     InterstitialAdManager.initialize();

//     //    Future.delayed(Duration(seconds: 5), () {
//     // InterstitialAdManager.showInterstitialAd();
//     // });
//   }

//   Future<String?> getFCMToken(String currentUserId) async {
//     DatabaseReference fcmTokenRef = FirebaseDatabase.instance
//         .ref()
//         .child('users')
//         .child(currentUserId)
//         .child('fcmToken');

//     // Check if the token already exists in the database
//     DatabaseEvent event = await fcmTokenRef.once();
//     DataSnapshot dataSnapshot = event.snapshot;

//     String? token = dataSnapshot.value as String?;

//     if (token == null) {
//       // If the token doesn't exist in the database, generate a new token
//       FirebaseMessaging messaging = FirebaseMessaging.instance;
//       token = await messaging.getToken();

//       if (token != null) {
//         // Store the newly generated token in the database
//         fcmTokenRef.set(token);
//       }
//     }

//     return token;
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     InterstitialAdManager.dispose();
//   }

//   void _refreshChatListWithFCM() {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('Public Chat Foreground notification received');
//       Map<String, dynamic> data = message.data;
//       final notificationType = data['type'];

//       print('data ${message.data}');
//       print('type $notificationType');

//       if (notificationType == 'public') {
//         _refreshChatList();

//         if (SharedPrefs.getBool(SharedPrefsKeys.CHAT_TONES)!) {
//           FlutterBeep.beep();
//         }
//       }

//       //handleFCMMessage(message.data, message);
//     });
//   }

//   void handleFCMMessage(Map<String, dynamic> data, RemoteMessage message) {
//     final senderId = data['senderUserId'];
//     final notificationType = data['type'];
//     print(
//         '--------------------------Private Chat Notification-----------------------------');
//     print('sender id $senderId');
//     print('type $notificationType');

//     print(
//         '--------------------------Private Chat Notification-----------------------------');
//     String title = message.notification!.title ?? 'There are new messages!';
//     String body = message.notification!.body ?? 'Tap here to open TruckChat';

//     if (notificationType == 'public') {
//       _refreshChatList();

//       if (SharedPrefs.getBool(SharedPrefsKeys.CHAT_TONES)!) {
//         FlutterBeep.beep();
//       }
//     }
//   }

//   // void _refreshChatListWithFCM() {
//   //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//   //     print('Refresh ChatList');

//   //     _refreshChatList();

//   //     if (SharedPrefs.getBool(SharedPrefsKeys.CHAT_TONES)!) {
//   //       FlutterBeep.beep();
//   //     }
//   //   });
//   // }

//   // void _refreshChatList() {
//   //   setState(() {
//   //     // Update the key of ChatList widget to force a rebuild
//   //     // _widgetOptions[1] = ChatList(key: UniqueKey(), );
//   //     _widgetOptions[1] = ChatListr(
//   //       key: UniqueKey(),
//   //     );
//   //   });
//   // }

//   void _refreshChatList() {
//     setState(() {
//       // Update the key of the currently selected widget to force a rebuild
//       _widgetOptions[_selectedIndex] = _getCurrentTabWidget();
//     });
//   }

//   Widget _getCurrentTabWidget() {
//     switch (_selectedIndex) {
//       case 0:
//         return NewsTab(
//           key: UniqueKey(),
//         );
//       case 1:
//         return ChatListr(key: UniqueKey());
//       case 2:
//         return SponsorsTab(key: UniqueKey());
//       case 3:
//         return ReviewsTab(key: UniqueKey());
//       case 4:
//         return PrivateChatTab(key: UniqueKey());
//       default:
//         return Container();
//     }
//   }

//   void _showReportAbuseDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(DialogStrings.REPORT_ABUSE),
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

//   // @override
//   // Widget build(BuildContext context) {
//   //   String? currentUserChatHandle =
//   //       SharedPrefs.getString(SharedPrefsKeys.CURRENT_USER_CHAT_HANDLE);
//   //   String appBarTitle = currentUserChatHandle != null
//   //       ? '${Constants.APP_BAR_TITLE} ($currentUserChatHandle)'
//   //       : Constants.APP_BAR_TITLE;

//   //   //  SharedPrefs.setBool('termsAgreed', false);

//   //   bool hasAgreed = SharedPrefs.getBool(SharedPrefsKeys.TERMS_AGREED) ?? false;
//   //   if (!hasAgreed) {
//   //     WidgetsBinding.instance!.addPostFrameCallback((_) {
//   //       showTermsOfServiceDialog(context);
//   //     });
//   //   }

//   //   return MaterialApp(
//   //     debugShowCheckedModeBanner: false,
//   //     theme: ThemeData(
//   //       primarySwatch: Colors.blue,
//   //     ),
//   //     home: Scaffold(
//   //         appBar: AppBar(
//   //           leading: Image.asset(
//   //             'assets/ic_launcher.png',
//   //             width: 34,
//   //             height: 34,
//   //           ),
//   //           title: Text(appBarTitle),
//   //           actions: [
//   //             IconButton(
//   //               icon: Image.asset(
//   //                 'assets/add_blog.png',
//   //                 width: 30,
//   //                 height: 30,
//   //               ),
//   //               onPressed: () {
//   //                 // Perform action when chat icon is pressed
//   //                 Navigator.push(
//   //                   context,
//   //                   MaterialPageRoute(
//   //                       builder: (context) => NewConversationScreen()),
//   //                 );
//   //               },
//   //             ),
//   //             IconButton(
//   //               icon: Icon(Icons.grid_view_rounded),
//   //               onPressed: () async {
//   //                 showMarkAsReadUnreadDialog(context);
//   //                 // _refreshChatList();
//   //                 // Perform action when grid box icon is pressed
//   //               },
//   //             ),
//   //             PopupMenuButton(
//   //               itemBuilder: (BuildContext context) {
//   //                 return [
//   //                   PopupMenuItem(
//   //                     child: Text(Constants.SETTINGS),
//   //                     value: 'settings',
//   //                   ),
//   //                   PopupMenuItem(
//   //                     child: Text(Constants.TELL_A_FRIEND),
//   //                     value: 'tell a friend',
//   //                   ),
//   //                   PopupMenuItem(
//   //                     child: Text(Constants.HELP),
//   //                     value: 'help',
//   //                   ),
//   //                   PopupMenuItem(
//   //                     child: Text(Constants.STARRED_CHAT),
//   //                     value: 'starred chat',
//   //                   ),
//   //                   PopupMenuItem(
//   //                     child: Text(Constants.REPORT_ABUSE),
//   //                     value: 'report abuse',
//   //                   ),
//   //                   PopupMenuItem(
//   //                     child: Text(Constants.REFRESH),
//   //                     value: 'refresh',
//   //                   ),
//   //                   // if (!Platform.isIOS)
//   //                   PopupMenuItem(
//   //                     child: Text(Constants.EXIT),
//   //                     value: 'exit',
//   //                   ),
//   //                 ];
//   //               },
//   //               onSelected: (value) async {
//   //                 // Perform action when a pop-up menu item is selected
//   //                 switch (value) {
//   //                   case 'settings':
//   //                     //InterstitialAdManager.showInterstitialAd();
//   //                     Navigator.push(
//   //                       context,
//   //                       MaterialPageRoute(
//   //                           builder: (context) => SettingsScreen()),
//   //                     );
//   //                     break;
//   //                   case 'tell a friend':
//   //                     String email = Uri.encodeComponent("");
//   //                     String subject =
//   //                         Uri.encodeComponent(Constants.CHECK_OUT_TRUCKCHAT);
//   //                     String body =
//   //                         Uri.encodeComponent(Constants.I_AM_USING_TRUCKCHAT);
//   //                     print(subject);
//   //                     Uri mail = Uri.parse(
//   //                         "mailto:$email?subject=$subject&body=$body");
//   //                     launchUrl(mail);
//   //                     break;
//   //                   case 'help':
//   //                     Navigator.push(
//   //                       context,
//   //                       MaterialPageRoute(builder: (context) => Help()),
//   //                     );
//   //                     break;
//   //                   case 'starred chat':
//   //                     Navigator.push(
//   //                       context,
//   //                       MaterialPageRoute(
//   //                         builder: (context) =>
//   //                             StarredChatList(key: UniqueKey()),
//   //                       ),
//   //                     );
//   //                     break;
//   //                   case 'report abuse':
//   //                     _showReportAbuseDialog(context);
//   //                     break;
//   //                   case 'refresh':
//   //                     _refreshChatList();

//   //                     break;
//   //                   case 'exit':
//   //                     if (Platform.isIOS) {
//   //                       // Handle iOS-specific exit behavior (e.g., display an alert)
//   //                       showDialog(
//   //                         context: context,
//   //                         builder: (context) => AlertDialog(
//   //                           title: Text(DialogStrings.EXIT),
//   //                           content: Text(DialogStrings.ARE_YOU_SURE),
//   //                           actions: [
//   //                             TextButton(
//   //                               onPressed: () => Navigator.of(context).pop(),
//   //                               child: Text(DialogStrings.CANCEL),
//   //                             ),
//   //                             TextButton(
//   //                               onPressed: () =>
//   //                                   Navigator.of(context).pop(true),
//   //                               child: Text(DialogStrings.EXIT),
//   //                             ),
//   //                           ],
//   //                         ),
//   //                       ).then((exitConfirmed) {
//   //                         if (exitConfirmed ?? false) {
//   //                           exit(0); // Exit the app
//   //                         }
//   //                       });
//   //                     } else if (Platform.isAndroid) {
//   //                       SystemNavigator.pop();
//   //                     }
//   //                     break;
//   //                 }
//   //               },
//   //             ),
//   //           ],
//   //         ),
//   //         body: Column(
//   //           children: [
//   //             Expanded(
//   //               child: _widgetOptions.elementAt(_selectedIndex),
//   //             ),
//   //           ],
//   //         ),
//   //         bottomNavigationBar: Column(
//   //           mainAxisSize: MainAxisSize.min,
//   //           mainAxisAlignment: MainAxisAlignment.end,
//   //           children: [
//   //             BottomNavigationBar(
//   //               items: const <BottomNavigationBarItem>[
//   //                 BottomNavigationBarItem(
//   //                   icon: Icon(Icons.article),
//   //                   label: Constants.NEWS,
//   //                 ),
//   //                 BottomNavigationBarItem(
//   //                   icon: Icon(Icons.chat),
//   //                   label: Constants.CHATS,
//   //                 ),
//   //                 BottomNavigationBarItem(
//   //                   icon: Icon(Icons.star),
//   //                   label: Constants.SPONSORS,
//   //                 ),
//   //                 BottomNavigationBarItem(
//   //                   icon: Icon(Icons.rate_review),
//   //                   label: Constants.REVIEWS,
//   //                 ),
//   //                 BottomNavigationBarItem(
//   //                   icon: Icon(Icons.person),
//   //                   label: Constants.PRIVATE_CHAT,
//   //                 ),
//   //               ],
//   //               currentIndex: _selectedIndex,
//   //               selectedItemColor: Colors.blue,
//   //               onTap: _onItemTapped,
//   //               unselectedItemColor:
//   //                   Colors.grey, // Added line to set unselected icon color
//   //               backgroundColor: Colors.white,
//   //               unselectedLabelStyle: TextStyle(
//   //                   color:
//   //                       Colors.grey), // Set color for unselected tab item text
//   //               selectedLabelStyle: TextStyle(
//   //                   color: Colors.blue), // Set color for selected tab item text
//   //               type: BottomNavigationBarType
//   //                   .fixed, // Set type to Fixed for more than 3 items
//   //             ),
//   //             AdmobBanner(
//   //               adUnitId: AdHelper.bannerAdUnitId,
//   //               adSize: AdmobBannerSize.ADAPTIVE_BANNER(
//   //                   width: MediaQuery.of(context).size.width.toInt()),
//   //             )
//   //           ],
//   //         )),
//   //   );
//   // }

// //original
//   @override
//   Widget build(BuildContext context) {
//     String? currentUserChatHandle =
//         SharedPrefs.getString(SharedPrefsKeys.CURRENT_USER_CHAT_HANDLE);
//     String appBarTitle = currentUserChatHandle != null
//         ? '${Constants.APP_BAR_TITLE} ($currentUserChatHandle)'
//         : Constants.APP_BAR_TITLE;

//     //  SharedPrefs.setBool('termsAgreed', false);

//     bool hasAgreed = SharedPrefs.getBool(SharedPrefsKeys.TERMS_AGREED) ?? false;
//     if (!hasAgreed) {
//       WidgetsBinding.instance!.addPostFrameCallback((_) {
//         showTermsOfServiceDialog(context);
//       });
//     }

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Scaffold(

//           appBar: AppBar(
//             leading: Image.asset(
//               'assets/ic_launcher.png',
//               width: 34,
//               height: 34,
//             ),
//             title: Text(appBarTitle),
//             actions: [
//               IconButton(
//                 icon: Image.asset(
//                   'assets/add_blog.png',
//                   width: 30,
//                   height: 30,
//                 ),
//                 onPressed: () {
//                   // Perform action when chat icon is pressed
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => NewConversationScreen()),
//                   );
//                 },
//               ),
//               IconButton(
//                 icon: Icon(Icons.grid_view_rounded),
//                 onPressed: () async {
//                   showMarkAsReadUnreadDialog(context);
//                   // _refreshChatList();
//                   // Perform action when grid box icon is pressed
//                 },
//               ),
//               PopupMenuButton(
//                 itemBuilder: (BuildContext context) {
//                   return [
//                     PopupMenuItem(
//                       child: Text(Constants.SETTINGS),
//                       value: 'settings',
//                     ),
//                     PopupMenuItem(
//                       child: Text(Constants.TELL_A_FRIEND),
//                       value: 'tell a friend',
//                     ),
//                     PopupMenuItem(
//                       child: Text(Constants.HELP),
//                       value: 'help',
//                     ),
//                     PopupMenuItem(
//                       child: Text(Constants.STARRED_CHAT),
//                       value: 'starred chat',
//                     ),
//                     PopupMenuItem(
//                       child: Text(Constants.REPORT_ABUSE),
//                       value: 'report abuse',
//                     ),
//                     PopupMenuItem(
//                       child: Text(Constants.REFRESH),
//                       value: 'refresh',
//                     ),
//                     // if (!Platform.isIOS)
//                     PopupMenuItem(
//                       child: Text(Constants.EXIT),
//                       value: 'exit',
//                     ),
//                   ];
//                 },
//                 onSelected: (value) async {
//                   // Perform action when a pop-up menu item is selected
//                   switch (value) {
//                     case 'settings':
//                       //InterstitialAdManager.showInterstitialAd();
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => SettingsScreen()),
//                       );
//                       break;
//                     case 'tell a friend':
//                       String email = Uri.encodeComponent("");
//                       String subject =
//                           Uri.encodeComponent(Constants.CHECK_OUT_TRUCKCHAT);
//                       String body =
//                           Uri.encodeComponent(Constants.I_AM_USING_TRUCKCHAT);
//                       print(subject);
//                       Uri mail = Uri.parse(
//                           "mailto:$email?subject=$subject&body=$body");
//                       launchUrl(mail);
//                       break;
//                     case 'help':
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => Help()),
//                       );
//                       break;
//                     case 'starred chat':
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               StarredChatList(key: UniqueKey()),
//                         ),
//                       );
//                       break;
//                     case 'report abuse':
//                       _showReportAbuseDialog(context);
//                       break;
//                     case 'refresh':
//                       _refreshChatList();

//                       break;
//                     case 'exit':
//                       if (Platform.isIOS) {
//                         // Handle iOS-specific exit behavior (e.g., display an alert)
//                         showDialog(
//                           context: context,
//                           builder: (context) => AlertDialog(
//                             title: Text(DialogStrings.EXIT),
//                             content: Text(DialogStrings.ARE_YOU_SURE),
//                             actions: [
//                               TextButton(
//                                 onPressed: () => Navigator.of(context).pop(),
//                                 child: Text(DialogStrings.CANCEL),
//                               ),
//                               TextButton(
//                                 onPressed: () =>
//                                     Navigator.of(context).pop(true),
//                                 child: Text(DialogStrings.EXIT),
//                               ),
//                             ],
//                           ),
//                         ).then((exitConfirmed) {
//                           if (exitConfirmed ?? false) {
//                             exit(0); // Exit the app
//                           }
//                         });
//                       } else if (Platform.isAndroid) {
//                         SystemNavigator.pop();
//                       }
//                       break;
//                   }
//                 },
//               ),
//             ],
//           ),
//           body: Column(
//             children: [
//               Expanded(
//                 child: _widgetOptions.elementAt(_selectedIndex),
//               ),
//             ],
//           ),
//           bottomSheet: Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               BottomNavigationBar(

//                 items: const <BottomNavigationBarItem>[
//                   BottomNavigationBarItem(
//                     icon: Icon(Icons.article),
//                     label: Constants.NEWS,
//                   ),
//                   BottomNavigationBarItem(
//                     icon: Icon(Icons.chat),
//                     label: Constants.CHATS,
//                   ),
//                   BottomNavigationBarItem(
//                     icon: Icon(Icons.star),
//                     label: Constants.SPONSORS,
//                   ),
//                   BottomNavigationBarItem(
//                     icon: Icon(Icons.rate_review),
//                     label: Constants.REVIEWS,
//                   ),
//                   BottomNavigationBarItem(
//                     icon: Icon(Icons.person),
//                     label: Constants.PRIVATE_CHAT,
//                   ),
//                 ],
//                 currentIndex: _selectedIndex,
//                 selectedItemColor: Colors.blue,
//                 onTap: _onItemTapped,
//                 unselectedItemColor:
//                     Colors.grey, // Added line to set unselected icon color
//                 backgroundColor: Colors.white,
//                 unselectedLabelStyle: TextStyle(
//                     color:
//                         Colors.grey), // Set color for unselected tab item text
//                 selectedLabelStyle: TextStyle(
//                     color: Colors.blue), // Set color for selected tab item text
//                 type: BottomNavigationBarType
//                     .fixed, // Set type to Fixed for more than 3 items
//               ),
//               AdmobBanner(
//                 adUnitId: AdHelper.bannerAdUnitId,
//                 adSize: AdmobBannerSize.ADAPTIVE_BANNER(
//                     width: MediaQuery.of(context).size.width.toInt()),
//               )
//             ],
//           )),
//     );
//   }

// }

// // class ChatsTab extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Center(
// //       child: Text('Chats Tab'),
// //     );
// //   }
// // }

// class SponsorsTab extends StatelessWidget {
//   final Key key;

//   SponsorsTab({
//     required this.key,
//   });

//   final String sponsorUrl = API.SPONSORS;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: InAppWebView(
//         initialUrlRequest: URLRequest(url: Uri.parse(sponsorUrl)),
//       ),
//     );
//   }
// }

// class ReviewsTab extends StatelessWidget {
//   final Key key;

//   ReviewsTab({
//     required this.key,
//   });

//   final String sponsorUrl = API.REVIEWS;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: InAppWebView(
//         initialUrlRequest: URLRequest(url: Uri.parse(sponsorUrl)),
//       ),
//     );
//   }
// }

// class Help extends StatelessWidget {
//   final String sponsorUrl = API.HELP;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: InAppWebView(
//         initialUrlRequest: URLRequest(url: Uri.parse(sponsorUrl)),
//       ),
//     );
//   }
// }

//big testing
import 'package:chat/chat/new_conversation.dart';
import 'package:chat/main.dart';
import 'package:chat/privateChat/private_chat_homescreen.dart';
import 'package:chat/chat/starred_chat_list.dart';
import 'package:chat/news_tab.dart';
import 'package:chat/chat/chat_list.dart';
import 'package:chat/settings/settings.dart';
import 'package:chat/utils/ads.dart';
import 'package:chat/utils/alert_dialog.dart';
import 'package:chat/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:chat/utils/shared_pref.dart';
import 'dart:convert';
import 'dart:io';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';

// import 'package:chat/reactivechat/chatlistreact.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String? currentUserId;
  PageController _pageController = PageController();
  PageStorageBucket _bucket = PageStorageBucket();
  late TabController _tabController;

  int _selectedIndex = 1;
  final List<Widget> _widgetOptions = [
    NewsTab(
      key: UniqueKey(),
    ),
    ChatListr(
      key: UniqueKey(),
    ),

    // ChatList(key: UniqueKey()),
    SponsorsTab(key: UniqueKey()),
    ReviewsTab(key: UniqueKey()),
    PrivateChatTab(key: UniqueKey()),
  ];

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 1);

    currentUserId = SharedPrefs.getString(SharedPrefsKeys.USER_ID);

    getFCMToken(currentUserId!);

    _refreshChatListWithFCM();

    InterstitialAdManager.initialize();

    //    Future.delayed(Duration(seconds: 5), () {
    // InterstitialAdManager.showInterstitialAd();
    // });
  }

  Future<String?> getFCMToken(String currentUserId) async {
    DatabaseReference fcmTokenRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(currentUserId)
        .child('fcmToken');

    // Check if the token already exists in the database
    DatabaseEvent event = await fcmTokenRef.once();
    DataSnapshot dataSnapshot = event.snapshot;

    String? token = dataSnapshot.value as String?;

    if (token == null) {
      // If the token doesn't exist in the database, generate a new token
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      token = await messaging.getToken();

      if (token != null) {
        // Store the newly generated token in the database
        fcmTokenRef.set(token);
      }
    }

    return token;
  }

  @override
  void dispose() {
    super.dispose();
    InterstitialAdManager.dispose();
    _tabController.dispose();
  }

  void _refreshChatListWithFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Public Chat Foreground notification received');
      Map<String, dynamic> data = message.data;
      final notificationType = data['type'];

      print('data ${message.data}');
      print('type $notificationType');

      if (notificationType == 'public') {
        _refreshChatList();

        if (SharedPrefs.getBool(SharedPrefsKeys.CHAT_TONES)!) {
          FlutterBeep.beep();
        }
      }

      //handleFCMMessage(message.data, message);
    });
  }

  void handleFCMMessage(Map<String, dynamic> data, RemoteMessage message) {
    final senderId = data['senderUserId'];
    final notificationType = data['type'];
    print(
        '--------------------------Private Chat Notification-----------------------------');
    print('sender id $senderId');
    print('type $notificationType');

    print(
        '--------------------------Private Chat Notification-----------------------------');
    String title = message.notification!.title ?? 'There are new messages!';
    String body = message.notification!.body ?? 'Tap here to open TruckChat';

    if (notificationType == 'public') {
      _refreshChatList();

      if (SharedPrefs.getBool(SharedPrefsKeys.CHAT_TONES)!) {
        FlutterBeep.beep();
      }
    }
  }

  // void _refreshChatListWithFCM() {
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     print('Refresh ChatList');

  //     _refreshChatList();

  //     if (SharedPrefs.getBool(SharedPrefsKeys.CHAT_TONES)!) {
  //       FlutterBeep.beep();
  //     }
  //   });
  // }

  // void _refreshChatList() {
  //   setState(() {
  //     // Update the key of ChatList widget to force a rebuild
  //     // _widgetOptions[1] = ChatList(key: UniqueKey(), );
  //     _widgetOptions[1] = ChatListr(
  //       key: UniqueKey(),
  //     );
  //   });
  // }

  void _refreshChatList() {
    setState(() {
      // Update the key of the currently selected widget to force a rebuild
      _widgetOptions[_selectedIndex] = _getCurrentTabWidget();
    });
  }

  Widget _getCurrentTabWidget() {
    switch (_selectedIndex) {
      case 0:
        return NewsTab(
          key: UniqueKey(),
        );
      case 1:
        return ChatListr(key: UniqueKey());
      case 2:
        return SponsorsTab(key: UniqueKey());
      case 3:
        return ReviewsTab(key: UniqueKey());
      case 4:
        return PrivateChatTab(key: UniqueKey());
      default:
        return Container();
    }
  }

  void _showReportAbuseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(DialogStrings.REPORT_ABUSE),
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

//original
  // @override
  // Widget build(BuildContext context) {
  //   String? currentUserChatHandle =
  //       SharedPrefs.getString(SharedPrefsKeys.CURRENT_USER_CHAT_HANDLE);
  //   String appBarTitle = currentUserChatHandle != null
  //       ? '${Constants.APP_BAR_TITLE} ($currentUserChatHandle)'
  //       : Constants.APP_BAR_TITLE;

  //   //  SharedPrefs.setBool('termsAgreed', false);

  //   bool hasAgreed = SharedPrefs.getBool(SharedPrefsKeys.TERMS_AGREED) ?? false;
  //   if (!hasAgreed) {
  //     WidgetsBinding.instance!.addPostFrameCallback((_) {
  //       showTermsOfServiceDialog(context);
  //     });
  //   }

  //   return MaterialApp(
  //     debugShowCheckedModeBanner: false,
  //     theme: ThemeData(
  //       primarySwatch: Colors.blue,
  //     ),
  //     home: Scaffold(

  //         appBar: AppBar(
  //           leading: Image.asset(
  //             'assets/ic_launcher.png',
  //             width: 34,
  //             height: 34,
  //           ),
  //           title: Text(appBarTitle),
  //           actions: [
  //             IconButton(
  //               icon: Image.asset(
  //                 'assets/add_blog.png',
  //                 width: 30,
  //                 height: 30,
  //               ),
  //               onPressed: () {
  //                 // Perform action when chat icon is pressed
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                       builder: (context) => NewConversationScreen()),
  //                 );
  //               },
  //             ),
  //             IconButton(
  //               icon: Icon(Icons.grid_view_rounded),
  //               onPressed: () async {
  //                 showMarkAsReadUnreadDialog(context);
  //                 // _refreshChatList();
  //                 // Perform action when grid box icon is pressed
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
  //                   PopupMenuItem(
  //                     child: Text(Constants.REFRESH),
  //                     value: 'refresh',
  //                   ),
  //                   // if (!Platform.isIOS)
  //                   PopupMenuItem(
  //                     child: Text(Constants.EXIT),
  //                     value: 'exit',
  //                   ),
  //                 ];
  //               },
  //               onSelected: (value) async {
  //                 // Perform action when a pop-up menu item is selected
  //                 switch (value) {
  //                   case 'settings':
  //                     //InterstitialAdManager.showInterstitialAd();
  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(
  //                           builder: (context) => SettingsScreen()),
  //                     );
  //                     break;
  //                   case 'tell a friend':
  //                     String email = Uri.encodeComponent("");
  //                     String subject =
  //                         Uri.encodeComponent(Constants.CHECK_OUT_TRUCKCHAT);
  //                     String body =
  //                         Uri.encodeComponent(Constants.I_AM_USING_TRUCKCHAT);
  //                     print(subject);
  //                     Uri mail = Uri.parse(
  //                         "mailto:$email?subject=$subject&body=$body");
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
  //                         builder: (context) =>
  //                             StarredChatList(key: UniqueKey()),
  //                       ),
  //                     );
  //                     break;
  //                   case 'report abuse':
  //                     _showReportAbuseDialog(context);
  //                     break;
  //                   case 'refresh':
  //                     _refreshChatList();

  //                     break;
  //                   case 'exit':
  //                     if (Platform.isIOS) {
  //                       // Handle iOS-specific exit behavior (e.g., display an alert)
  //                       showDialog(
  //                         context: context,
  //                         builder: (context) => AlertDialog(
  //                           title: Text(DialogStrings.EXIT),
  //                           content: Text(DialogStrings.ARE_YOU_SURE),
  //                           actions: [
  //                             TextButton(
  //                               onPressed: () => Navigator.of(context).pop(),
  //                               child: Text(DialogStrings.CANCEL),
  //                             ),
  //                             TextButton(
  //                               onPressed: () =>
  //                                   Navigator.of(context).pop(true),
  //                               child: Text(DialogStrings.EXIT),
  //                             ),
  //                           ],
  //                         ),
  //                       ).then((exitConfirmed) {
  //                         if (exitConfirmed ?? false) {
  //                           exit(0); // Exit the app
  //                         }
  //                       });
  //                     } else if (Platform.isAndroid) {
  //                       SystemNavigator.pop();
  //                     }
  //                     break;
  //                 }
  //               },
  //             ),
  //           ],
  //         ),
  //         body: Column(
  //           children: [
  //             Expanded(
  //               child: _widgetOptions.elementAt(_selectedIndex),
  //             ),
  //           ],
  //         ),
  //         bottomSheet: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           mainAxisAlignment: MainAxisAlignment.end,
  //           children: [
  //             BottomNavigationBar(

  //               items: const <BottomNavigationBarItem>[
  //                 BottomNavigationBarItem(
  //                   icon: Icon(Icons.article),
  //                   label: Constants.NEWS,
  //                 ),
  //                 BottomNavigationBarItem(
  //                   icon: Icon(Icons.chat),
  //                   label: Constants.CHATS,
  //                 ),
  //                 BottomNavigationBarItem(
  //                   icon: Icon(Icons.star),
  //                   label: Constants.SPONSORS,
  //                 ),
  //                 BottomNavigationBarItem(
  //                   icon: Icon(Icons.rate_review),
  //                   label: Constants.REVIEWS,
  //                 ),
  //                 BottomNavigationBarItem(
  //                   icon: Icon(Icons.person),
  //                   label: Constants.PRIVATE_CHAT,
  //                 ),
  //               ],
  //               currentIndex: _selectedIndex,
  //               selectedItemColor: Colors.blue,
  //               onTap: _onItemTapped,
  //               unselectedItemColor:
  //                   Colors.grey, // Added line to set unselected icon color
  //               backgroundColor: Colors.white,
  //               unselectedLabelStyle: TextStyle(
  //                   color:
  //                       Colors.grey), // Set color for unselected tab item text
  //               selectedLabelStyle: TextStyle(
  //                   color: Colors.blue), // Set color for selected tab item text
  //               type: BottomNavigationBarType
  //                   .fixed, // Set type to Fixed for more than 3 items
  //             ),
  //             AdmobBanner(
  //               adUnitId: AdHelper.bannerAdUnitId,
  //               adSize: AdmobBannerSize.ADAPTIVE_BANNER(
  //                   width: MediaQuery.of(context).size.width.toInt()),
  //             )
  //           ],
  //         )),
  //   );
  // }

  //testing 1
  @override
  Widget build(BuildContext context) {
    String? currentUserChatHandle =
        SharedPrefs.getString(SharedPrefsKeys.CURRENT_USER_CHAT_HANDLE);
    String appBarTitle = currentUserChatHandle != null
        ? '${Constants.APP_BAR_TITLE} ($currentUserChatHandle)'
        : Constants.APP_BAR_TITLE;

    //  SharedPrefs.setBool('termsAgreed', false);

    bool hasAgreed = SharedPrefs.getBool(SharedPrefsKeys.TERMS_AGREED) ?? false;
    if (!hasAgreed) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        showTermsOfServiceDialog(context);
      });
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: Image.asset(
            'assets/ic_launcher.png',
            width: 34,
            height: 34,
          ),
          title: Text(appBarTitle),
          actions: [
            IconButton(
              icon: Image.asset(
                'assets/add_blog.png',
                width: 30,
                height: 30,
              ),
              onPressed: () {
                // Perform action when chat icon is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewConversationScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.grid_view_rounded),
              onPressed: () async {
                showMarkAsReadUnreadDialog(context);
                // _refreshChatList();
                // Perform action when grid box icon is pressed
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
                  PopupMenuItem(
                    child: Text(Constants.REFRESH),
                    value: 'refresh',
                  ),
                  // if (!Platform.isIOS)
                  PopupMenuItem(
                    child: Text(Constants.EXIT),
                    value: 'exit',
                  ),
                ];
              },
              onSelected: (value) async {
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
                  case 'refresh':
                    _refreshChatList();

                    break;
                  case 'exit':
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
                    } else if (Platform.isAndroid) {
                      SystemNavigator.pop();
                    }
                    break;
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  NewsTab(
                    key: UniqueKey(),
                  ),
                  ChatListr(key: UniqueKey()),
                  SponsorsTab(key: UniqueKey()),
                  ReviewsTab(key: UniqueKey()),
                  PrivateChatTab(key: UniqueKey()),
                ],
              ),
            ),
          ],
        ),

        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2.0)],
          ),
          child: AdmobBanner(
            adUnitId: AdHelper.bannerAdUnitId,
            adSize: AdmobBannerSize.ADAPTIVE_BANNER(
              width: MediaQuery.of(context).size.width.toInt(),
            ),
          ),
        ),

        bottomSheet: PreferredSize(
          preferredSize: Size.fromHeight(60.0), // Set the height of the TabBar
          child: Container(
            height: 60.0,
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(icon: Icon(Icons.article), text: Constants.NEWS),
                Tab(icon: Icon(Icons.chat), text: Constants.CHATS),
                Tab(icon: Icon(Icons.star), text: Constants.SPONSORS),
                Tab(icon: Icon(Icons.rate_review), text: Constants.REVIEWS),
                Tab(icon: Icon(Icons.person), text: Constants.PRIVATE_CHAT),
              ],
              unselectedLabelColor:
                  Colors.grey, // Color of unselected tab icon and text
              labelColor: Colors.blue, // Color of selected tab icon and text
              labelPadding: EdgeInsets.symmetric(
                  horizontal: 6.0, vertical: 2.0), // Add padding around the tab labels
            ),
          ),
        ),
        //           AdmobBanner(
        //   adUnitId: AdHelper.bannerAdUnitId,
        //   adSize: AdmobBannerSize.ADAPTIVE_BANNER(
        //       width: MediaQuery.of(context).size.width.toInt()),
        // )
      ),
    );
  }
}

// Calculate the height of the AdmobBanner based on the available constraints
double _getAdmobBannerHeight(BoxConstraints constraints) {
  // Choose the desired AdSize based on the device orientation
  final adSize = AdmobBannerSize.ADAPTIVE_BANNER(
    width: constraints.maxWidth.toInt(),
  );

  // Calculate the height based on the width and height aspect ratio of the AdSize
  return adSize.height.toDouble();
}

class SponsorsTab extends StatelessWidget {
  final Key key;

  SponsorsTab({
    required this.key,
  });

  final String sponsorUrl = API.SPONSORS;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(sponsorUrl)),
      ),
    );
  }
}

class ReviewsTab extends StatelessWidget {
  final Key key;

  ReviewsTab({
    required this.key,
  });

  final String sponsorUrl = API.REVIEWS;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(sponsorUrl)),
      ),
    );
  }
}

class Help extends StatelessWidget {
  final String sponsorUrl = API.HELP;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(sponsorUrl)),
      ),
    );
  }
}
