import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

final FirebaseAuth _auth = FirebaseAuth.instance;
class UserUtilities {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String _admin_uid = 'UmwGNqRZg3aaoz2LvaZLiF6zYky1';

  static Future<String> getUserName() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        String firstName = userDoc['firstName'];
        String lastName = userDoc['lastName'];

        String fullName = '$firstName $lastName';
        return fullName;
      } else {
        return 'Kullanıcı bilgileri bulunamadı';
      }
    } else {
      return 'Kullanıcı girişi yapılmamış';
    }
  }
  static Future<String> getUserMail() async {

    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        String email = userDoc['email'];
        return email;
      } else {
        return 'Kullanıcı bilgileri bulunamadı';
      }
    } else {
      return 'Kullanıcı girişi yapılmamış';
    }
  }
  static void signOut(context) async {
    _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage(title: "login")),
          (route) => false,
    );
  }

  static String? getCurrentUserUid() {
    return _auth.currentUser?.uid;
  }

  static bool isStrongPassword(String password) {


    if (password.length < 8) return false;


    RegExp uppercaseRegex = RegExp(r'[A-Z]');
    RegExp lowercaseRegex = RegExp(r'[a-z]');
    RegExp digitRegex = RegExp(r'[0-9]');


    return uppercaseRegex.hasMatch(password) &&
        lowercaseRegex.hasMatch(password) &&
        digitRegex.hasMatch(password);
  }

  static bool isValidName(String name) {
    name = name.trim();
    RegExp regExp = RegExp(r'^[A-Za-zğüşıöçĞÜŞİÖÇ]+(?: [A-Za-zğüşıöçĞÜŞİÖÇ]+)*$');
    return regExp.hasMatch(name);
  }


  static bool isValidEmail(String email) {
    email = email.trim();
    RegExp regExp = RegExp(r'^[\w-]+(\.[\w-]+)*@(gmail\.com|hotmail\.com|outlook\.com|yahoo\.com|icloud\.com|ogr\.cbu\.edu\.tr|cbu\.edu\.tr)$');
    return regExp.hasMatch(email);
  }

  static isCurrentUserAdmin() {
    return _auth.currentUser?.uid == _admin_uid;
  }

}

class StorageUtilities {

  static Future<String?> uploadFile(String fileDir, String storageDir, String fileName, String extention,) async {
    final firebase_storage.Reference ref = firebase_storage.FirebaseStorage
        .instance
        .ref()
        .child(storageDir)
        .child('${DateTime.now()}_${fileName}.${extention}');
    await ref.putFile(File(fileDir!));
    fileDir = await ref.getDownloadURL();
    return fileDir;
  }


}
