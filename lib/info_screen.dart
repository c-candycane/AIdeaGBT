import 'package:flutter/material.dart';


import 'AppUtilities.dart';

class InfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppUtilities.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Uygulama Hakkında',
          style: AppUtilities.primaryTextStyleWhiteXLarge,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yapımcılar:',
              style: AppUtilities.primaryTextStyleWhite,
            ),
            Text(
              'Hüseyin ÖZCAN',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'İletişim Maili:',
              style: AppUtilities.primaryTextStyleWhite,
            ),
            Text(
              'huseyinozcan5507@hotmail.com',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Sürüm:',
              style: AppUtilities.primaryTextStyleWhite,
            ),
            Text(
              AppUtilities.appVersion,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Text(
              'Model:',
              style: AppUtilities.primaryTextStyleWhite,
            ),
            Text(
              AppUtilities.appModel,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 10),
            Text(
              AppUtilities.appName,
              style: AppUtilities.primaryTextStyleWhiteSmallItalic,
            ),
          ],
        ),
      ),
    );
  }
}
