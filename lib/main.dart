import 'dart:convert';
import 'dart:io';

import 'package:chat/chat_list_screen.dart';
import 'package:chat/chat_screen.dart';
import 'package:chat/getFcm.dart';
import 'package:chat/get_previous_messages.dart';
import 'package:chat/home_screen.dart';
import 'package:chat/utils/avatar.dart';
import 'package:chat/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:device_info/device_info.dart';
import 'get_all_reply_messages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPrefs.init(); // Initialize SharedPrefs

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

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
    setState(() {
      _counter++;
      //registerDevice();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );

      //  showAvatarSelectionDialog(context);

      //  String? vv = SharedPrefs.getString('userId');
      //           print("shared pref userid $vv");

      //      Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => ChatListScreen(
      //       conversationTopics: serverMessageIds,
      //       conversationTimestamps: conversation_timestamp,
      //       replyCounts: counts,
      //       replyMsgs: reply_msgs,
      //     ),
      //   ),
      // );
    });
  }

  @override
  void initState() {
    super.initState();
    configLocalNotification();

    _configureFCM();

    registerDevice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
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

  Future<void> registerDevice() async {
    String user_id = '';

    print("register device");
    Location location = Location();
    LocationData? currentLocation;

    // Request location permission
    PermissionStatus? permissionStatus;
    permissionStatus = await location.requestPermission();
    if (permissionStatus != PermissionStatus.granted) {
      // Handle permission not granted
      return;
    }

    // Fetch current location
    try {
      currentLocation = await location.getLocation();
      print(currentLocation.latitude);
      print(currentLocation.longitude);
    } catch (e) {
      // Handle location fetch error
      print('Error fetching location: $e');
      return;
    }

    // Device registration data
    // Fetch device serial number
    String? serialNumber = await getDeviceSerialNumber();
    if (serialNumber == null) {
      // Handle error getting serial number
      print('Error getting device serial number');
      return;
    }

    String? registrationId = await getFirebaseToken();
    if (registrationId == null) {
      // Handle error getting Firebase token
      print('Error getting Firebase token');
      return;
    }

    // String serialNumber = "YOUR_DEVICE_SERIAL_NUMBER";
    // String registrationId = "YOUR_REGISTRATION_ID";

    // Prepare request body
    Map<String, dynamic> requestBody = {
      "device_id": serialNumber,
      "device_gcm_id": registrationId,
      "device_type": "Android",
      "latitude": currentLocation.latitude,
      "longitude": currentLocation.longitude,
    };

    String requestBodyJson = jsonEncode(requestBody);

    // Send POST request to server
    Uri url = Uri.parse("http://smarttruckroute.com/bb/v1/device_register");
    http.Response response = await http.post(
      url,
      body: requestBodyJson,
      headers: {"Content-Type": "application/json"},
    );

    // Handle server response
    if (response.statusCode == 200) {
      // Registration successful
      print("Device registered successfully!");

      Map<String, dynamic> responseBody = jsonDecode(response.body);

      // Check if the user_id exists in the response
      if (responseBody.containsKey("user_id")) {
        user_id = responseBody["user_id"];
        print("User ID: $user_id");
        SharedPrefs.setString('userId', user_id);
        SharedPrefs.setDouble('latitude', currentLocation.latitude!);
        SharedPrefs.setDouble('longitude', currentLocation.longitude!);
      } else {
        print("Error: User ID not found in response");
      }

      // GetPreviousMessagesAsyncTask task = GetPreviousMessagesAsyncTask(
      //  user_id,
      //   1.0,
      //   1.0,
      // );

      // task.execute();

      //getAllMessages();

      print(response.body);
    } else {
      // Registration failed
      print("Device registration failed: ${response.body}");
    }
  }

  Future<String?> getDeviceSerialNumber() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? serialNumber;

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      serialNumber = androidInfo.androidId;
      print("sssserial number $serialNumber");
    } else if (Platform.isIOS) {
      // For iOS, you can use androidId as an alternative if needed
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      serialNumber = iosInfo.identifierForVendor;
    }

    return serialNumber;
  }

  Future<String?> getFirebaseToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token;

    try {
      token = await messaging.getToken();
    } catch (e) {
      print('Error getting Firebase token: $e');
    }

    return token;
  }

  //get conversations

  Future<bool> getAllMessages(List<String> serverMessageIds) async {
    int status_code = 0;
    String counts = '';
    int conversation_timestamp = 0;
    //String conversation_timestamp = '';
    List<ReplyMsg> reply_msgs = [];

    String status_message = '';
    String conversation_topic = '';

    final url =
        Uri.parse("http://smarttruckroute.com/bb/v1/get_all_reply_message");

    for (var serverMessageId in serverMessageIds) {
      Map<String, dynamic> requestBody = {
        "server_message_id": serverMessageId,
      };

      // Map<String, dynamic> requestBody = {
      //   "server_message_id": "48702",
      // };

      try {
        http.Response response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestBody),
        );
        if (response.statusCode == 200) {
          final result = response.body;

          try {
            final jsonResult = jsonDecode(result);
            // status_code = jsonResult[PARAM_STATUS];

            if (jsonResult.containsKey('message')) {
              status_message = jsonResult['message'];
            } else {
              status_message = '';
            }

            counts = jsonResult['counts'];

            conversation_topic = jsonResult['original'];
            print("conversation topic $conversation_topic");
            print('counts $counts');
            try {
              conversation_timestamp =
                  int.tryParse(jsonResult['timestamp']) ?? 0;
            } catch (e) {
              conversation_timestamp = 0;
            }

            final jsonReplyList = jsonResult['messsage_reply_list'];
            int countValue = int.parse(counts);

            if (counts == jsonReplyList.length) {
              for (var i = 0; i < countValue; ++i) {
                final jsonReply = jsonReplyList[i];
                final rid = jsonReply['server_msg_reply_id'];
                final replyMsg = jsonReply['reply_msg'];
                final uid = jsonReply['user_id'];
                final emojiId = jsonReply['emoji_id'];
                int timestamp;
                try {
                  timestamp = int.tryParse(jsonReply['timestamp']) ?? 0;
                } catch (e) {
                  timestamp = 0;
                }

                reply_msgs
                    .add(ReplyMsg(rid, uid, replyMsg, timestamp, emojiId));
              }
            }

            return true;
          } catch (e) {
            print(e);
            status_message = e.toString();
          }
        } else {
          status_message = 'Connection Error';
        }
      } catch (e) {
        print(e);
      }
    }

    return false;
  }
}

class ReplyMsg {
  final String rid;
  final String uid;
  final String replyMsg;
  final int timestamp;
  final String emojiId;

  ReplyMsg(this.rid, this.uid, this.replyMsg, this.timestamp, this.emojiId);
}
