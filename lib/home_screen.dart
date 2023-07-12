// import 'package:chat/chat/chatlist.dart';
// import 'package:chat/chat/chatlistreactive.dart';
import 'package:chat/chat/new_conversation.dart';
// import 'package:chat/chat_list_screen.dart';
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
// import 'chat/chatlist.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:chat/utils/shared_pref.dart';
import 'dart:convert';
import 'dart:io';
import 'package:admob_flutter/admob_flutter.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //InterstitialAdManager.initialize();

    //    Future.delayed(Duration(seconds: 5), () {
    // InterstitialAdManager.showInterstitialAd();
    // });
  }

  @override
  void dispose() {
    super.dispose();
    //InterstitialAdManager.dispose();
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
              onSelected: (value) {
                // Perform action when a pop-up menu item is selected
                switch (value) {
                  case 'settings':
                   // InterstitialAdManager.showInterstitialAd();
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
        // body: _widgetOptions.elementAt(_selectedIndex),

        body: Column(
          children: [
            Expanded(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
            // Container(
            //   height: 50, // Adjust the height of the ad container as needed
            //   child: AdmobBanner(
            //     adUnitId: AdHelper.bannerAdUnitId,
            //     adSize: AdmobBannerSize.BANNER,
            //   ),
            // ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.article),
              label: Constants.NEWS,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: Constants.CHATS,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: Constants.SPONSORS,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.rate_review),
              label: Constants.REVIEWS,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: Constants.PRIVATE_CHAT,
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

class PrivateChatTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Private Chat Tab'),
    );
  }
}
