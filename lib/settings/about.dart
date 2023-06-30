import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/ic_logo.png',
              width: 200,
            ),
            Text(
              'LIVE CHAT WITH FELLOW COMMERCIAL DRIVERS IN YOUR AREA.\nIT\'S LIKE HAVING A DIGITAL CB AT NO COST.',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.0),
            Text(
              'Totally FREE app, no hidden fees.\nPlease support our Sponsors.',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.0),
            Text(
              '© TeleType Co. All Rights Reserved',
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 16.0),
            Divider(height: 2.0),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => _launchURL(Uri.parse('http://truckchatapp.com')),
                  child: Text(
                    'Visit the website',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16.0,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _launchURL(Uri.parse(
                      'http://truckchatapp.com/index.html#Contact')), // Replace with your contact URL
                  child: Text(
                    'Contact us',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16.0,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                String email = Uri.encodeComponent("");
                String subject = Uri.encodeComponent("Check out TruckChat");
                String body = Uri.encodeComponent(
                    "I am using TruckChat right now, check it out at:\n\nhttp://play.google.com/store/apps/details?id=com.teletype.truckchat\n\nhttp://truckchatapp.com");
                print(subject);
                Uri mail =
                    Uri.parse("mailto:$email?subject=$subject&body=$body");
                launchUrl(mail);
              },
              child: Text(
                'Tell a Friend',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16.0,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Text('Version 2.0.11.44'),
            Text(
              'Serial# ',
              style: TextStyle(fontSize: 16),
            ),
            FutureBuilder<String>(
              future: getPaddedSerialNumber(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text(snapshot.data ?? 'Unknown');
                }
              },
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => showTermsOfServiceDialog(
                      context), // Replace with your terms of service URL
                  child: Text(
                    'Terms of Service',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16.0,
                      fontStyle: FontStyle.italic,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void showTermsOfServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Terms of Service'),
        content: Text(
          'This app is provided as a free service for trucking professionals.\n\nWe want the commercial truck driving community to have a pleasant and useful experience using the free TruckChat app, so that means no posting of explicit or offensive content. More specifically: no porn, no racism, no homophobia, no threats, no abuse, no bullying, no profanity, no sexual advances, no solicitation or personal services. No advertising of your business (unless you are a paying Sponsor of the app with written permission from the developer).\n\nIf we feel you are violating these terms, we can remove your content and/or delete your profile without question. We encourage checking with drivers about weather, traffic, parking, company reviews, delivery discussions between drivers and dispatchers.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Got It!'),
          ),
        ],
      ),
    );
  }

  Future<String> getPaddedSerialNumber() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    String? serial;

    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo =
            await deviceInfoPlugin.androidInfo;
        serial = androidInfo.androidId;
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        serial = iosInfo.identifierForVendor;
      }
    } on PlatformException {
      serial = '';
    }

    final int padding = 4;
    if ((serial!.length % padding) == 0) {
      final StringBuffer stringBuffer = StringBuffer();

      for (int i = 0; i < serial.length; i += padding) {
        if (stringBuffer.isNotEmpty) {
          stringBuffer.write("-");
        }

        stringBuffer.write(serial.substring(i, i + padding));
      }

      return stringBuffer.toString();
    }

    return serial;
  }
}
