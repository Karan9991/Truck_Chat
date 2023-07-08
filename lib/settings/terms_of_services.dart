import 'package:chat/utils/constants.dart';
import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Constants.TERMS_AND_CONDITIONS),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Constants.TERMS_AND_CONDITIONS,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              Constants.THIS_APP_IS_PROVIDED,
              style: TextStyle(fontSize: 18.0),
            ),
         
          ],
        ),
      ),
    );
  }
}
