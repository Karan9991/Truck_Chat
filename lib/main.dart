import 'dart:convert';
import 'dart:io';

import 'package:chat/chat_screen.dart';
import 'package:chat/getFcm.dart';
import 'package:chat/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void _incrementCounter() async {
    // String? fcmKey = await getFcmToken();
    // print('FCM Key : $fcmKey');
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
      // Inside the source screen

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    configLocalNotification();

    _configureFCM();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  // void _configureFCM() {
  //   _firebaseMessaging.requestPermission();

  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     print('Foreground notification received: $message');

  //     if (message.notification != null) {
  //       showNotification(message.notification!);
  //     } else {
  //       print('No notification payload found in the message.');
  //     }
  //   }, onError: (error) {
  //     print('Error receiving foreground notification: $error');
  //   });

  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //     print('Background notification received: $message');

  //     if (message.notification != null) {
  //       showNotification(message.notification!);
  //     } else {
  //       print('No notification payload found in the message.');
  //     }
  //   }, onError: (error) {
  //     print('Error receiving background notification: $error');
  //   });
  // }

//original
  void _configureFCM() {
    _firebaseMessaging.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('fffffffffForeground notification received $message');

      if (message.notification != null) {
        //  showNotification(message.notification!);
        showNotification('title', 'body');
        print('nnnnnnotification data ');
        print(message.notification?.title);
        print(message.notification?.body);

        // _showLocalNotification(message.data);
      }
      // Handle foreground notifications here
      // Example: Show a local notification using flutter_local_notifications package
      // _showLocalNotification(message.data);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('bbbbbbbbbbbBackground notification received $message');
      if (message.notification != null) {
        // showNotification(message.notification!);
        //_showLocalNotification(message.data);
      }

      // Handle background notifications here
    });
  }

  void showNotification(String? title, String? body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'com.dfa.flutterchatdemo', // Replace with your Android package name
      'Flutter chat demo',
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: null,
    );
  }

//original
  // void showNotification(RemoteNotification remoteNotification) async {
  //   AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //     Platform.isAndroid
  //         ? 'com.dfa.flutterchatdemo'
  //         : 'com.duytq.flutterchatdemo',
  //     'Flutter chat demo',
  //     playSound: true,
  //     enableVibration: true,
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );

  //   DarwinNotificationDetails iOSPlatformChannelSpecifics =
  //       DarwinNotificationDetails();
  //   NotificationDetails platformChannelSpecifics = NotificationDetails(
  //     android: androidPlatformChannelSpecifics,
  //     iOS: iOSPlatformChannelSpecifics,
  //   );

  //   print(remoteNotification);

  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     remoteNotification.title,
  //     remoteNotification.body,
  //     platformChannelSpecifics,
  //     payload: null,
  //   );
  // }

//original
  void configLocalNotification() {
    AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // void _showLocalNotification(Map<String, dynamic> data) async {
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //     'channel_id',
  //     'channel_name',
  //     channelDescription: 'channel_description',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );
  //   const NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);

  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     data['title'] ?? '',
  //     data['body'] ?? '',
  //     platformChannelSpecifics,
  //     payload: data['payload'],
  //   );
  // }

  // void showLocalNotification(String title, String body) {
  //   const androidNotificationDetail = AndroidNotificationDetails(
  //       '0', // channel Id
  //       'general' // channel Name
  //       );
  //   const iosNotificatonDetail = DarwinNotificationDetails();
  //   const notificationDetails = NotificationDetails(
  //     iOS: iosNotificatonDetail,
  //     android: androidNotificationDetail,
  //   );
  //   flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
  // }
}
