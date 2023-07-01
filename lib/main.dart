import 'dart:convert';
import 'dart:io';

import 'package:chat/chat_list_screen.dart';
import 'package:chat/chat_screen.dart';
import 'package:chat/getFcm.dart';
import 'package:chat/get_previous_messages.dart';
import 'package:chat/home_screen.dart';
import 'package:chat/utils/avatar.dart';
import 'package:chat/utils/chat_handle.dart';
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
  await SharedPrefs.init(); // Initialize SharedPrefs
  await registerDevice();

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
      home: HomeScreen(),
    );
  }
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
  // Fetch device serial number and store in SharedPrefs
  String? serialNumber = await getDeviceSerialNumber();

  SharedPrefs.setString('serialNumber', serialNumber!);

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

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   void _incrementCounter() async {
//     setState(() {
//       _counter++;
//       //registerDevice();
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => HomeScreen()),
//       );
//       //   ChatHandle.showChatHandle(context); // Call the showChatHandle function

//       //  showAvatarSelectionDialog(context);

//       //  String? vv = SharedPrefs.getString('serialNumber');
//       //           print("shared pref serialNumber $vv");

//       //      Navigator.push(
//       //   context,
//       //   MaterialPageRoute(
//       //     builder: (context) => ChatListScreen(
//       //       conversationTopics: serverMessageIds,
//       //       conversationTimestamps: conversation_timestamp,
//       //       replyCounts: counts,
//       //       replyMsgs: reply_msgs,
//       //     ),
//       //   ),
//       // );
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     configLocalNotification();

//     _configureFCM();

//     // registerDevice();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }

// //original
//   void _configureFCM() {
//     _firebaseMessaging.requestPermission();
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('fffffffffForeground notification received $message');

//       if (message.notification != null) {
//         //  showNotification(message.notification!);
//         showNotification('title', 'body');
//         print('nnnnnnotification data ');
//         print(message.notification?.title);
//         print(message.notification?.body);

//         // _showLocalNotification(message.data);
//       }
//       // Handle foreground notifications here
//       // Example: Show a local notification using flutter_local_notifications package
//       // _showLocalNotification(message.data);
//     });
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('bbbbbbbbbbbBackground notification received $message');
//       if (message.notification != null) {
//         // showNotification(message.notification!);
//         //_showLocalNotification(message.data);
//       }

//       // Handle background notifications here
//     });
//   }

//   void showNotification(String? title, String? body) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'com.dfa.flutterchatdemo', // Replace with your Android package name
//       'Flutter chat demo',
//       playSound: true,
//       enableVibration: true,
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     DarwinNotificationDetails iOSPlatformChannelSpecifics =
//         DarwinNotificationDetails();

//     NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: iOSPlatformChannelSpecifics,
//     );

//     await flutterLocalNotificationsPlugin.show(
//       0,
//       title,
//       body,
//       platformChannelSpecifics,
//       payload: null,
//     );
//   }

// //original
//   void configLocalNotification() {
//     AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     DarwinInitializationSettings initializationSettingsIOS =
//         DarwinInitializationSettings();
//     InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );
//     flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

 
// }

class ReplyMsg {
  final String rid;
  final String uid;
  final String replyMsg;
  final int timestamp;
  final String emojiId;

  ReplyMsg(this.rid, this.uid, this.replyMsg, this.timestamp, this.emojiId);
}
