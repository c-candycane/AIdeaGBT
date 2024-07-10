import 'dart:io';
import 'package:flutter/material.dart';

import 'login_page.dart';

class AppUtilities {
  static const String appName = "AIdeaGBT";
  static const String appModel = "AIdeaGBT-V2";
  static const String appVersion = "2024 Version 6";
  static const Color backgroundColor = Color.fromRGBO(31, 44, 55, 1);
  static const Color primaryButtonColor = Colors.blue;
  static const String appLogoPath = "images/aideasoft_logobw.png";

  static const TextStyle primaryTextStyleWhite = TextStyle(
    color: Colors.white,
    fontSize: 20
  );
  static const TextStyle primaryTextStyleWhiteBold = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20
  );
  static const TextStyle primaryTextStyleWhiteSmall = TextStyle(
      color: Colors.white,
      fontSize: 14
  );
  static const TextStyle primaryTextStyleWhiteSmallItalic = TextStyle(
      color: Colors.white,
      fontStyle: FontStyle.italic,
      fontSize: 14
  );
  static const TextStyle primaryTextStyleWhiteXLarge = TextStyle(
      color: Colors.white,
      fontSize: 26
  );
  static const TextStyle primaryTextStyleBlue = TextStyle(
      color: Colors.blue,
      fontSize: 18
  );
  static const TextStyle primaryTextStyleBlueSmall = TextStyle(
      color: Colors.blue,
      fontSize: 14
  );
  static const TextStyle primaryTextStyleBlueLarge = TextStyle(
      color: Colors.blue,
      fontSize: 22
  );
  static const TextStyle primaryTextStyleBlueXLargeBold = TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.bold,
      fontSize: 26
  );
  static const TextStyle primaryTextStyleBlueItalic = TextStyle(
      color: Colors.blue,
      fontStyle: FontStyle.italic,
      fontSize: 18
  );

  static String removeSpaces(String input) {
    return input.replaceAll(' ', '');
  }


  static void showAlertDialog(String title, String message, context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromRGBO(31, 44, 55, 1),
          title: Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Tamam',
                style: TextStyle(
                  color: AppUtilities.primaryButtonColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  static void showAlertDialogAndNavigate(String title, String message, String page, String pageMessage,context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromRGBO(31, 44, 55, 1),
          title: Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Tamam',
                style: TextStyle(
                  color: primaryButtonColor
                ),
              ),
              onPressed: () {
                if (page == "LoginPage"){
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage(title: pageMessage)),
                        (route) => false,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }


  static final List<String> categories = [
    'Hayvanlar',
    'Renkler',
    'Yiyecekler',
    'Meslekler',
    'Giysiler',
    'Ulaşım Araçları',
    'Mutfak Eşyaları',
    'Doğa Elementleri',
    'Saatler ve Zaman',
    'Ev Eşyaları',
    'Meyve ve Sebzeler',
    'Vücut Parçaları',
    'Sporlar',
    'Mekanlar',
    'Müzik Aletleri',
    'Diğer'
  ];


}
