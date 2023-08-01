import 'dart:convert';
import 'dart:io';
import 'package:chat/home_screen.dart';
import 'package:chat/privateChat/chat.dart';
import 'package:chat/utils/avatar.dart';
import 'package:chat/utils/chat_handle.dart';
import 'package:chat/utils/constants.dart';
import 'package:chat/utils/device_type.dart';
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
import 'package:admob_flutter/admob_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  print("backgroundHandler: ${message.notification}");
  // Handle the background message here
  await SharedPrefs.init();
  bool? notifications = SharedPrefs.getBool(SharedPrefsKeys.NOTIFICATIONS);
  if (notifications!) {
    handleFCMMessage(message.data, message);
  }
}
//7FADBC328BBB96431CA78C2E559B06A7
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Admob.initialize(
   // testDeviceIds: ['5F18997E57B09D90875E5BFFF902E13D'],
  ); //testDeviceIds: ['5F18997E57B09D90875E5BFFF902E13D'],
  await Admob.requestTrackingAuthorization();

  configLocalNotification();
  _configureFCM();

  await SharedPrefs.init();
  await registerDevice();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isAppInstalled = prefs.getBool('isAppInstalled') ?? false;

  if (!isAppInstalled) {
    await initNotificationsAndSoundPrefs();
    await prefs.setBool('isAppInstalled', true);
  }

  FirebaseMessaging.onBackgroundMessage(backgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Truck Chat',

      initialRoute: '/',

      routes: {
        '/home': (context) => HomeScreen(),
        '/chat': (context) => ChatScreen(
              userId: 'sd',
              receiverUserName: 'sd',
              receiverId: 'adsf',
              receiverEmojiId: 'ds',
            ),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: SendRequestScreen(senderId: '1', receiverId: '2'),
      // home: ChatScreen(chatId: '21'),
      //home: ChatListScreen(),
      home: HomeScreen(),
    );
  }
}

Future<String?> getFCMToken(String receiverId) async {
  DatabaseReference fcmTokenRef = FirebaseDatabase.instance
      .ref()
      .child('users')
      .child(receiverId)
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

Future<void> initNotificationsAndSoundPrefs() async {
  SharedPrefs.setBool(SharedPrefsKeys.CHAT_TONES, true);
  SharedPrefs.setBool(SharedPrefsKeys.NOTIFICATIONS, true);
  SharedPrefs.setBool(SharedPrefsKeys.NOTIFICATIONS_TONE, true);
  SharedPrefs.setBool(SharedPrefsKeys.VIBRATE, true);
  SharedPrefs.setBool(SharedPrefsKeys.PRIVATE_CHAT, false);
  SharedPrefs.setBool('isUserOnChatScreen', false);
  SharedPrefs.setBool('isUserOnPublicChatScreen', false);
}

Future<void> registerDevice() async {
  String user_id = '';
  String deviceType = getDeviceType();

  //print("register device");
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

  SharedPrefs.setString(SharedPrefsKeys.SERIAL_NUMBER, serialNumber!);

  if (serialNumber == null) {
    // Handle error getting serial number
    print('Error getting device serial number');
    return;
  }

  String? registrationId = await getFirebaseToken();
  //String? registrationId = await getFCMToken('2');

  print('Firebase token $registrationId');
  if (registrationId == null) {
    // Handle error getting Firebase token
    print('Error getting Firebase token');
    return;
  }

  // Prepare request body
  Map<String, dynamic> requestBody = {
    API.DEVICE_ID: serialNumber,
    API.DEVICE_GCM_ID: registrationId,
    API.DEVICE_TYPE: deviceType,
    API.LATITUDE: currentLocation.latitude,
    API.LONGITUDE: currentLocation.longitude,
  };

  String requestBodyJson = jsonEncode(requestBody);

  // Send POST request to server
  Uri url = Uri.parse(API.DEVICE_REGISTER);
  http.Response response = await http.post(
    url,
    body: requestBodyJson,
    headers: {API.CONTENT_TYPE: API.APPLICATION_JSON},
  );

  // Handle server response
  if (response.statusCode == 200) {
    print('---------------Device Register Response---------------');

    // Registration successful
    print("Device registered successfully!");

    Map<String, dynamic> responseBody = jsonDecode(response.body);

    // Check if the user_id exists in the response
    if (responseBody.containsKey(API.USER_ID)) {
      user_id = responseBody[API.USER_ID].toString();
      print("User ID: $user_id");
      SharedPrefs.setString(SharedPrefsKeys.USER_ID, user_id);
      SharedPrefs.setDouble(
          SharedPrefsKeys.LATITUDE, currentLocation.latitude!);
      SharedPrefs.setDouble(
          SharedPrefsKeys.LONGITUDE, currentLocation.longitude!);

      // String? currentUserId = SharedPrefs.getString(SharedPrefsKeys.USER_ID);

      // getFCMToken(currentUserId!);

      print('testing ${SharedPrefs.getString(SharedPrefsKeys.USER_ID)}');
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
    print("Serial number $serialNumber");
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

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void _configureFCM() {
  _firebaseMessaging.requestPermission();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Foreground notification received');

    print('data ${message.data}');
    String title = message.notification!.title ?? '';

    print('notification $title');

    handleFCMMessage(message.data, message);

    if (message.notification != null) {
      //  showNotification(message.notification!);
      // showNotification('title', 'body');
      // print('Notification data ');
      // print(message.notification?.title);
      // print(message.notification?.body);

      // _showLocalNotification(message.data);
    }
    // Handle foreground notifications here
    // Example: Show a local notification using flutter_local_notifications package
    // _showLocalNotification(message.data);
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('onMessageOpenedApp $message');
    // handleFCMMessage(message.data, message);

    if (message.notification != null) {
      // showNotification(message.notification!);
      //_showLocalNotification(message.data);
    }

    // Handle background notifications here
  });
}

void handleFCMMessage(Map<String, dynamic> data, RemoteMessage message) {
  final senderId = data['senderUserId'];
  final notificationType = data['type'];

  print('--------------------------Notification-----------------------------');
  print('sender id $senderId');
  print('type $notificationType');
  print('--------------------------Notification-----------------------------');

  String title = message.notification!.title ?? 'There are new messages!';
  String body = message.notification!.body ?? 'Tap here to open TruckChat';
  String? currentUserId = SharedPrefs.getString(SharedPrefsKeys.USER_ID);

  if (notificationType == 'public') {
    if (!SharedPrefs.getBool('isUserOnPublicChatScreen')!) {
      if (currentUserId != senderId) {
        showNotification(
            Constants.FCM_NOTIFICATION_TITLE, Constants.FCM_NOTIFICATION_BODY);
      }
    }
  } else if (notificationType == 'private') {
    if (!SharedPrefs.getBool('isUserOnChatScreen')!) {
      showNotification(title, body);
    }
  }
}

void showNotification(String? title, String? body) async {
  HapticFeedback.vibrate();

  bool androidNotificationTone =
      SharedPrefs.getBool(SharedPrefsKeys.NOTIFICATIONS_TONE) ?? false;

  print('notification tone testing $androidNotificationTone');

  print('showNotification method called');
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'com.teletype.truckchat2.android', // Replace with your Android package name
    'Flutter chat demo',
    playSound: androidNotificationTone,
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

//original AndroidInitializationSettings('@drawable/app_icon_foreground');
void configLocalNotification() {
  AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/ic_launcher');
  DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
  InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}
