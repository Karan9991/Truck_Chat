import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'This app is provided as a free service for trucking professionals.',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'We want the commercial truck driving community to have a pleasant and useful experience using the free TruckChat app, so that means no posting of explicit or offensive content. More specifically: no porn, no racism, no homophobia, no threats, no abuse, no bullying, no profanity, no sexual advances, no solicitation or personal services. No advertising of your business (unless you are a paying Sponsor of the app with written permission from the developer).',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'If we feel you are violating these terms, we can remove your content and/or delete your profile without question. We encourage checking with drivers about weather, traffic, parking, company reviews, delivery discussions between drivers and dispatchers.',
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}
