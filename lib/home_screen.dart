// import 'package:chat/chat/chatlist.dart';
// import 'package:chat/chat/chatlistreactive.dart';
import 'package:chat/chat/new_conversation.dart';
// import 'package:chat/chat_list_screen.dart';
import 'package:chat/news_tab.dart';
import 'package:chat/reactivechat/chatlistreact.dart';
import 'package:chat/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'chat/chatlist.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:chat/utils/shared_pref.dart';
import 'dart:convert';

// import 'package:chat/reactivechat/chatlistreact.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  final List<Widget> _widgetOptions = [
    NewsTab(),
    ChatListr(
      key: UniqueKey(),
    ),

    // ChatList(key: UniqueKey()),
    SponsorsTab(),
    ReviewsTab(),
    PrivateChatTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _refreshChatList() {
    setState(() {
      // Update the key of ChatList widget to force a rebuild
      // _widgetOptions[1] = ChatList(key: UniqueKey(), );
      _widgetOptions[1] = ChatListr(
        key: UniqueKey(),
      );
    });
  }

  void _showReportAbuseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Report Abuse'),
          content: Text(
              'To report abuse or inappropriate content, tap on a message inside a chat conversation and select an option from the popup.'),
          actions: [
            TextButton(
              child: Text('Got It!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String? currentUserChatHandle =
        SharedPrefs.getString('currentUserChatHandle');
    String appBarTitle = currentUserChatHandle != null
        ? 'TruckChat $currentUserChatHandle'
        : 'TruckChat';

    return MaterialApp(
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
              onPressed: () {
                // Perform action when grid box icon is pressed
              },
            ),
            PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    child: Text('Settings'),
                    value: 'settings',
                  ),
                  PopupMenuItem(
                    child: Text('Tell a Friend'),
                    value: 'tell a friend',
                  ),
                  PopupMenuItem(
                    child: Text('Help'),
                    value: 'help',
                  ),
                  PopupMenuItem(
                    child: Text('Report Abuse'),
                    value: 'report abuse',
                  ),
                  PopupMenuItem(
                    child: Text('Refresh'),
                    value: 'refresh',
                  ),
                  if (!Platform.isIOS)
                    PopupMenuItem(
                      child: Text('Exit'),
                      value: 'exit',
                    ),
                ];
              },
              onSelected: (value) {
                // Perform action when a pop-up menu item is selected
                switch (value) {
                  case 'settings':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                    break;
                  case 'tell a friend':
                    String email = Uri.encodeComponent("");
                    String subject = Uri.encodeComponent("Check out TruckChat");
                    String body = Uri.encodeComponent(
                        "I am using TruckChat right now, check it out at:\n\nhttp://play.google.com/store/apps/details?id=com.teletype.truckchat\n\nhttp://truckchatapp.com");
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
                  case 'report abuse':
                    _showReportAbuseDialog(context);
                    break;
                  case 'refresh':
                    _refreshChatList();

                    break;
                  case 'exit':
                    SystemNavigator.pop();
                    break;
                }
              },
            ),
          ],
        ),
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.article),
              label: 'News',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: 'Sponsors',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.rate_review),
              label: 'Reviews',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Private Chat',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          onTap: _onItemTapped,
          unselectedItemColor:
              Colors.grey, // Added line to set unselected icon color
          backgroundColor: Colors.white,
          unselectedLabelStyle: TextStyle(
              color: Colors.grey), // Set color for unselected tab item text
          selectedLabelStyle: TextStyle(
              color: Colors.blue), // Set color for selected tab item text
          type: BottomNavigationBarType
              .fixed, // Set type to Fixed for more than 3 items
        ),
      ),
    );
  }
}

class ChatsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Chats Tab'),
    );
  }
}

class SponsorsTab extends StatelessWidget {
  final String sponsorUrl = 'http://truckchatapp.com/sponsors.html';

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
  final String sponsorUrl = 'http://truckchatapp.com/reviews/mobile';

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
  final String sponsorUrl = 'http://truckchatapp.com/index.html#FAQ';

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(sponsorUrl)),
      ),
    );
  }
}

class PrivateChatTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Private Chat Tab'),
    );
  }
}
