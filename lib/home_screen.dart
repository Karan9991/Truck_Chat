import 'package:chat/chat_list_screen.dart';
import 'package:chat/news_tab.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Widget> _widgetOptions = [
    NewsTab(),
    ChatListScreen(),
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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TruckChat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('TruckChat'),
          actions: [
            IconButton(
              icon: Icon(Icons.chat),
              onPressed: () {
                // Perform action when chat icon is pressed
              },
            ),
            IconButton(
              icon: Icon(Icons.grid_on),
              onPressed: () {
                // Perform action when grid box icon is pressed
              },
            ),
            PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    child: Text('Menu Item 1'),
                    value: 'item1',
                  ),
                  PopupMenuItem(
                    child: Text('Menu Item 2'),
                    value: 'item2',
                  ),
                  PopupMenuItem(
                    child: Text('Menu Item 3'),
                    value: 'item3',
                  ),
                ];
              },
              onSelected: (value) {
                // Perform action when a pop-up menu item is selected
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
              icon: Icon(Icons.chat_bubble),
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
           unselectedItemColor: Colors.grey, // Added line to set unselected icon color
  backgroundColor: Colors.white, 
    unselectedLabelStyle: TextStyle(color: Colors.grey), // Set color for unselected tab item text
  selectedLabelStyle: TextStyle(color: Colors.blue), // Set color for selected tab item text
  type: BottomNavigationBarType.fixed, // Set type to Fixed for more than 3 items

        ),
      ),
    );
  }
}

// class NewsTab extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text('News Tab'),
//     );
//   }
// }

class ChatsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Chats Tab'),
    );
  }
}

class SponsorsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Sponsors Tab'),
    );
  }
}

class ReviewsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Reviews Tab'),
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

// void main() {
//   runApp(MyApp());
// }