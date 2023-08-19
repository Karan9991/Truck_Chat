import 'dart:convert';
// import 'dart:html';
import 'dart:io';
import 'package:chat/chat/conversation_data.dart';
import 'package:chat/home_screen.dart';
import 'package:chat/privateChat/chat.dart';
import 'package:chat/privateChat/pending_requests.dart';
import 'package:chat/privateChat/private_chat_homescreen.dart';
import 'package:chat/utils/ads.dart';
import 'package:chat/utils/alert_dialog.dart';
import 'package:chat/utils/avatar.dart';
import 'package:chat/utils/chat_handle.dart';
import 'package:chat/utils/constants.dart';
import 'package:chat/utils/device_type.dart';
import 'package:chat/utils/register_user.dart';
import 'package:chat/utils/shared_pref.dart';
import 'package:chat/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
// import 'package:location2/location2.dart';

import 'package:device_info/device_info.dart';
import 'get_all_reply_messages.dart';
//import 'package:admob_flutter/admob_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:chat/utils/navigator_key.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  print("backgroundHandler: ${message.notification}");
  // Handle the background message here
  await SharedPrefs.init();
  bool? notifications = SharedPrefs.getBool(SharedPrefsKeys.NOTIFICATIONS);
  if (notifications!) {
    handleFCMMessage(message.data, message);
  }
}

// AppOpenAd? openAd;

// Future<void> loadAd() async {
//   await AppOpenAd.load(
//       adUnitId: 'ca-app-pub-3940256099942544/3419835294',
//       request: const AdRequest(),
//       adLoadCallback: AppOpenAdLoadCallback(onAdLoaded: (ad) {
//         print('ad is loaded');
//         openAd = ad;
//         // openAd!.show();
//       }, onAdFailedToLoad: (error) {
//         print('ad failed to load $error');
//       }),
//       orientation: AppOpenAd.orientationPortrait);
// }

// void showAd() {
//   if (openAd == null) {
//     print('trying tto show before loading');
//     loadAd();
//     return;
//   }

//   openAd!.fullScreenContentCallback =
//       FullScreenContentCallback(onAdShowedFullScreenContent: (ad) {
//     print('onAdShowedFullScreenContent');
//   }, onAdFailedToShowFullScreenContent: (ad, error) {
//     ad.dispose();
//     print('failed to load $error');
//     openAd = null;
//     loadAd();
//   }, onAdDismissedFullScreenContent: (ad) {
//     ad.dispose();
//     print('dismissed');
//     openAd = null;
//     loadAd();
//   });

//   openAd!.show();
// }

AppOpenAd? myAppOpenAd;

loadAppOpenAd() {
  AppOpenAd.load(
      adUnitId: AdHelper.openAppAdUnitId, //Your ad Id from admob
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            myAppOpenAd = ad;
            myAppOpenAd!.show();
          },
          onAdFailedToLoad: (error) {}),
      orientation: AppOpenAd.orientationPortrait);
}

//7FADBC328BBB96431CA78C2E559B06A7
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  MobileAds.instance.initialize();

  await loadAppOpenAd();
  //loadAd();


  // await Admob.initialize(
  //     // testDeviceIds: ['5F18997E57B09D90875E5BFFF902E13D'],
  //     ); //testDeviceIds: ['5F18997E57B09D90875E5BFFF902E13D'],
  // // MobileAds.instance.initialize();

  // await Admob.requestTrackingAuthorization();

  configLocalNotification();
  _configureFCM();

  await SharedPrefs.init();
  await registerDevice();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isAppInstalled = prefs.getBool('isAppInstalled') ?? false;

  if (!isAppInstalled) {
    await initNotificationsAndSoundPrefs();
    //await registerDevice();
    // await prefs.setBool('isAppInstalled', true);
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
      navigatorKey: navigatorKey,

      initialRoute: '/',

      routes: {
        '/': (context) => HomeScreen(
              initialTabIndex: 1,
            ),
        '/privateChat': (context) => PrivateChatTab(key: UniqueKey()),
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
      // home: ReviewsTab(key: UniqueKey(),),
      // home: HomeScreen(initialTabIndex: 1, ),
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
  SharedPrefs.setBool(SharedPrefsKeys.PRIVATE_CHAT, true);
  SharedPrefs.setBool('isUserOnChatScreen', false);
  SharedPrefs.setBool('isUserOnPublicChatScreen', false);
}

// Future<void> registerDevice() async {
//   String user_id = '';
//   String deviceType = getDeviceType();

//   //print("register device");
//    Location location = Location();
//    LocationData? currentLocation;

//   // Request location permission

//   PermissionStatus? permissionStatus;
//   permissionStatus = await location.requestPermission();
//   if (permissionStatus != PermissionStatus.granted) {
//     // Handle permission not granted
//     return;
//   }

//   // Fetch current location
//   try {
//   //    Permission.location.request();
//   //  currentLocation = await getLocation(); //catch exception
//     currentLocation = await location.getLocation();
//     print(currentLocation.latitude);
//     print(currentLocation.longitude);
//   } catch (e) {
//     // Handle location fetch error
//     print('Error fetching location: $e');
//     return;
//   }

//   // Device registration data
//   // Fetch device serial number and store in SharedPrefs
//   String? serialNumber = await getDeviceSerialNumber();

//   SharedPrefs.setString(SharedPrefsKeys.SERIAL_NUMBER, serialNumber!);

//   if (serialNumber == null) {
//     // Handle error getting serial number
//     print('Error getting device serial number');
//     return;
//   }

//   String? registrationId = await getFirebaseToken();
//   //String? registrationId = await getFCMToken('2');

//   print('Firebase token $registrationId');
//   if (registrationId == null) {
//     // Handle error getting Firebase token
//     print('Error getting Firebase token');
//     return;
//   }

//   // Prepare request body
//   Map<String, dynamic> requestBody = {
//     API.DEVICE_ID: serialNumber,
//     API.DEVICE_GCM_ID: registrationId,
//     API.DEVICE_TYPE: deviceType,
//     API.LATITUDE: currentLocation.latitude,
//     API.LONGITUDE: currentLocation.longitude,
//   };

//   String requestBodyJson = jsonEncode(requestBody);

//   // Send POST request to server
//   Uri url = Uri.parse(API.DEVICE_REGISTER);
//   http.Response response = await http.post(
//     url,
//     body: requestBodyJson,
//     headers: {API.CONTENT_TYPE: API.APPLICATION_JSON},
//   );

//   // Handle server response
//   if (response.statusCode == 200) {
//     print('---------------Device Register Response---------------');

//     // Registration successful
//     print("Device registered successfully!");

//     Map<String, dynamic> responseBody = jsonDecode(response.body);

//     // Check if the user_id exists in the response
//     if (responseBody.containsKey(API.USER_ID)) {
//       user_id = responseBody[API.USER_ID].toString();
//       print("User ID: $user_id");
//       SharedPrefs.setString(SharedPrefsKeys.USER_ID, user_id);
//       SharedPrefs.setDouble(
//           SharedPrefsKeys.LATITUDE, currentLocation.latitude!);
//       SharedPrefs.setDouble(
//           SharedPrefsKeys.LONGITUDE, currentLocation.longitude!);

//       //  String? currentUserId = SharedPrefs.getString(SharedPrefsKeys.USER_ID);

//       //  getFCMToken(currentUserId!);

//       print('testing ${SharedPrefs.getString(SharedPrefsKeys.USER_ID)}');
//     } else {
//       print("Error: User ID not found in response");
//     }

//     print(response.body);
//   } else {
//     // Registration failed
//     print("Device registration failed: ${response.body}");
//   }
// }

// Future<String?> getDeviceSerialNumber() async {
//   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//   String? serialNumber;

//   if (Platform.isAndroid) {
//     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//     serialNumber = androidInfo.androidId;
//     print("Serial number $serialNumber");
//   } else if (Platform.isIOS) {
//     // For iOS, you can use androidId as an alternative if needed
//     IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
//     serialNumber = iosInfo.identifierForVendor;
//   }

//   return serialNumber;
// }

// Future<String?> getFirebaseToken() async {
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   String? token;

//   try {
//     token = await messaging.getToken();
//   } catch (e) {
//     print('Error getting Firebase token: $e');
//   }

//   return token;
// }

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

    bool? notifications = SharedPrefs.getBool(SharedPrefsKeys.NOTIFICATIONS);
    if (notifications!) {
      handleFCMMessage(message.data, message);
    }

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
    print('onMessageOpenedApp----------------->');
    // handleFCMMessage(message.data, message);

    if (message.notification != null) {
      // showNotification(message.notification!);
      //_showLocalNotification(message.data);
    }

    // Handle background notifications here
  });
}

// void handleFCMMessage(Map<String, dynamic> data, RemoteMessage message) async {
//   final senderId = data['senderUserId'];
//   final notificationType = data['type'];

//   print('--------------------------Notification-----------------------------');
//   print('sender id $senderId');
//   print('type $notificationType');
//   print('--------------------------Notification-----------------------------');

//   String title = message.notification!.title ?? 'There are new messages!';
//   String body = message.notification!.body ?? 'Tap here to open TruckChat';
//   String? currentUserId = SharedPrefs.getString(SharedPrefsKeys.USER_ID);

//   if (notificationType == 'public') {
//     if (!SharedPrefs.getBool('isUserOnPublicChatScreen')!) {
//       if (currentUserId != senderId) {
//         showNotification(
//             Constants.FCM_NOTIFICATION_TITLE, Constants.FCM_NOTIFICATION_BODY);
//       }
//     }
//   } else if (notificationType == 'private') {
//     if (!SharedPrefs.getBool('isUserOnChatScreen')!) {
//       showNotification(title, body);
//     }
//   } else if (notificationType == 'privatechat') {
//     showNotification(title, body);
//   }
// }
//testing notificaioin
void handleFCMMessage(Map<String, dynamic> data, RemoteMessage message) async {
  final senderId = data['senderUserId'];
  final notificationType = data['type'];
  final conversationId = data[
      'conversationId']; // Assuming you receive the conversation ID in the notification data

  print('--------------------------Notification-----------------------------');
  print('sender id $senderId');
  print('type $notificationType');
  print('--------------------------Notification-----------------------------');

  String title = message.notification!.title ?? 'There are new messages!';
  String body = message.notification!.body ?? 'Tap here to open TruckChat';
  String? currentUserId = SharedPrefs.getString(SharedPrefsKeys.USER_ID);

  if (notificationType == 'public') {
    print('if public');
    if (!SharedPrefs.getBool('isUserOnPublicChatScreen')!) {
      print('if isUserOnPublicChatScreen');

      if (currentUserId != senderId) {
        List<Conversation> storedConversations = await getStoredConversations();
        Conversation? conversationToRefresh; // Initialize as nullable
        print('if curren');

        for (var conversation in storedConversations) {
          if (conversation.conversationId == conversationId &&
              !conversation.isDeleted) {
            print('if conversationToRefresh ${conversation.isDeleted}');

            conversationToRefresh = conversation;
            break;
          } else {
            print(
                'else conversationid  ${conversation.conversationId} $conversationId ${conversation.isDeleted} ${conversation.topic}');
          }
        }

        if (conversationToRefresh != null) {
          print('if conversationToRefresh nulled $conversationToRefresh');

          showNotification(Constants.FCM_NOTIFICATION_TITLE,
              Constants.FCM_NOTIFICATION_BODY);
        } else {
          print('else conversationToRefresh $conversationToRefresh');
        }
      }
    }
  } else if (notificationType == 'private') {
    print('if private');

    if (!SharedPrefs.getBool('isUserOnChatScreen')!) {
      showNotification(title, body);
    }
  } else if (notificationType == 'privatechat') {
    print('if privatechat');

    showNotification(title, body);
  } else if (notificationType == 'newchat') {
    print('if newchat');

    showNotification(title, body);
  }
}

void handleFCMMessageBackground(
    Map<String, dynamic> data, RemoteMessage message) async {
  final senderId = data['senderUserId'];
  final notificationType = data['type'];
  final conversationId = data[
      'conversationId']; // Assuming you receive the conversation ID in the notification data

  print('--------------------------Notification-----------------------------');
  print('sender id $senderId');
  print('type $notificationType');
  print('--------------------------Notification-----------------------------');

  String title = message.notification!.title ?? 'There are new messages!';
  String body = message.notification!.body ?? 'Tap here to open TruckChat';
  String? currentUserId = SharedPrefs.getString(SharedPrefsKeys.USER_ID);

  if (notificationType == 'public') {
    if (currentUserId != senderId) {
      List<Conversation> storedConversations = await getStoredConversations();
      Conversation? conversationToRefresh; // Initialize as nullable

      for (var conversation in storedConversations) {
        if (conversation.conversationId == conversationId &&
            !conversation.isDeleted) {
          conversationToRefresh = conversation;
          break;
        }
      }

      if (conversationToRefresh != null) {
        showNotification(
            Constants.FCM_NOTIFICATION_TITLE, Constants.FCM_NOTIFICATION_BODY);
      }
    }
  } else if (notificationType == 'private') {
    showNotification(title, body);
  } else if (notificationType == 'privatechat') {
    showNotification(title, body);
  } else if (notificationType == 'newchat') {
    showNotification(title, body);
  }
}

Future<String> getNotificationChannelId() async {
  bool notificationTone =
      SharedPrefs.getBool(SharedPrefsKeys.NOTIFICATIONS_TONE) ?? false;
  bool notificationVibrate =
      SharedPrefs.getBool(SharedPrefsKeys.VIBRATE) ?? false;

  // Default channel ID for when both notification tone and vibrate are disabled
  String channelId = 'default_channel';

  switch (notificationTone) {
    case true:
      switch (notificationVibrate) {
        case true:
          channelId = 'tone_and_vibrate_channel';
          break;
        case false:
          channelId = 'tone_channel';
          break;
      }
      break;
    case false:
      switch (notificationVibrate) {
        case true:
          channelId = 'vibrate_channel';
          break;
        case false:
          channelId = 'silent_channel';
          break;
      }
      break;
  }

  return channelId;
}

void showNotification(String? title, String? body) async {
  //check user preferences for notification and vibrate
  String channelId = await getNotificationChannelId();
  bool shouldPlaySound =
      (channelId == 'tone_channel' || channelId == 'tone_and_vibrate_channel');
  bool shouldEnableVibration = (channelId == 'vibrate_channel' ||
      channelId == 'tone_and_vibrate_channel');

  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    channelId,
    'Truck Chat',
    playSound: shouldPlaySound,
    enableVibration: shouldEnableVibration,
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

class LocationPermissionObserver extends NavigatorObserver {
  bool settingsScreenOpened = false;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute is MaterialPageRoute) {
      settingsScreenOpened = true;
    }
    super.didPush(route, previousRoute);
  }

  void userReturnedFromSettingsScreen() {
    settingsScreenOpened = false;
  }
}
