import 'package:aideagbt/profile_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AppUtilities.dart';
import 'FirebaseUtilities.dart';
import 'info_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ErrorReportingPopup extends StatefulWidget {
  final String senderUsername;
  final String senderMail;
  ErrorReportingPopup({required this.senderUsername, required this.senderMail});

  @override
  _ErrorReportingPopupState createState() => _ErrorReportingPopupState();
}

class _ErrorReportingPopupState extends State<ErrorReportingPopup> {
  TextEditingController _errorMessageController = TextEditingController();

  void _sendErrorMessage() {
    String errorMessage = _errorMessageController.text.trim();
    if (errorMessage.isNotEmpty) {
      // Firebase'e hata mesajını ve diğer bilgileri kaydetme
      FirebaseFirestore.instance.collection('errorMessages').add({
        'message': errorMessage,
        'senderName': widget.senderUsername,
        'senderMail': widget.senderMail,
        'timestamp': Timestamp.now(),
      });

      // Popup'ı kapat
      Navigator.of(context).pop();
    } else {
      // Hata mesajı boşsa kullanıcıyı uyar
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hata!'),
            content: Text('Lütfen bir hata mesajı girin.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Tamam'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppUtilities.backgroundColor,
      title: Text('Hata Bildir', style: AppUtilities.primaryTextStyleBlue,),
      content: TextField(
        controller: _errorMessageController,
        decoration: InputDecoration(
            hintText: 'Hata mesajınızı buraya girin...',
            hintStyle: AppUtilities.primaryTextStyleWhiteSmall
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('İptal', style: AppUtilities.primaryTextStyleBlueSmall,),
        ),
        ElevatedButton(
          onPressed: _sendErrorMessage,
          child: Text('Gönder'),
        ),
      ],
    );
  }
}

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String userName = '';
  String userEmail = '';
  String uid = '';

  bool isLoading = true; // Yükleme işareti için durum değişkeni
  bool isLinkMode = false; // Link girme modunu kontrol eden değişken

  // IP adresi için dört ayrı controller
  TextEditingController _ipPart1Controller = TextEditingController();
  TextEditingController _ipPart2Controller = TextEditingController();
  TextEditingController _ipPart3Controller = TextEditingController();
  TextEditingController _ipPart4Controller = TextEditingController();
  TextEditingController _linkController = TextEditingController(); // Link için controller

  @override
  void initState() {
    super.initState();
    getUserInfo();
    _fetchIpAddress(); // IP adresini Firestore'dan çek
  }

  Future<void> getUserInfo() async {
    UserUtilities.getUserName().then((name) {
      setState(() {
        userName = name;
      });
    });

    UserUtilities.getUserMail().then((email) {
      setState(() {
        userEmail = email;
      });
    });

    setState(() {
      uid = UserUtilities.getCurrentUserUid() ?? '';
      isLoading = false;
    });
  }

  void _fetchIpAddress() async {
    try {
      // Firestore'dan kullanıcının IP adresini al
      DocumentSnapshot<Map<String, dynamic>> userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        String ipAddress = userDoc['chat_ip'] ?? '';
        if (ipAddress.isNotEmpty) {
          if (ipAddress.startsWith('http')) {
            setState(() {
              isLinkMode = true;
              _linkController.text = ipAddress;
            });
          } else {
            List<String> parts = ipAddress.split('.');
            if (parts.length == 4) {
              _ipPart1Controller.text = parts[0];
              _ipPart2Controller.text = parts[1];
              _ipPart3Controller.text = parts[2];
              _ipPart4Controller.text = parts[3];
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching IP address: $e');
    }
  }

  void _saveIpAddress() {
    String ipAddress =
        '${_ipPart1Controller.text.trim()}.${_ipPart2Controller.text.trim()}.${_ipPart3Controller.text.trim()}.${_ipPart4Controller.text.trim()}';
    if (ipAddress.isNotEmpty) {
      // Kullanıcının IP adresini Firestore'a kaydet
      FirebaseFirestore.instance.collection('users').doc(uid).set({
        'chat_ip': ipAddress,
      }, SetOptions(merge: true)).then((_) {
        AppUtilities.showAlertDialog("Başarılı", "IP Adresi kaydedildi.", context);
      }).catchError((error) {
        print('Error saving IP address: $error');
      });
    } else {
      // IP adresi boşsa kullanıcıyı uyar
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hata!'),
            content: Text('Lütfen bir IP adresi girin.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Tamam'),
              ),
            ],
          );
        },
      );
    }
  }

  void _saveLink() {
    String link = _linkController.text.trim();
    if (link.isNotEmpty) {
      // Kullanıcının linkini Firestore'a kaydet
      FirebaseFirestore.instance.collection('users').doc(uid).set({
        'chat_ip': link,
      }, SetOptions(merge: true)).then((_) {
        AppUtilities.showAlertDialog("Başarılı", "Link kaydedildi.", context);
      }).catchError((error) {
        print('Error saving link: $error');
      });
    } else {
      // Link boşsa kullanıcıyı uyar
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hata!'),
            content: Text('Lütfen bir link girin.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Tamam'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: AppUtilities.backgroundColor,
      body: SingleChildScrollView(
        child: Center(
          child: isLoading
              ? CircularProgressIndicator() // Yükleme işareti
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(AppUtilities.appLogoPath, height: 190, width: 190),
              SizedBox(height: 20),
              Text(
                'Merhaba $userName',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '$userEmail',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 30),
              SwitchListTile(
                title: Text(
                  'Link ile giriş yap',
                  style: TextStyle(color: Colors.white),
                ),
                value: isLinkMode,
                onChanged: (bool value) {
                  setState(() {
                    isLinkMode = value;
                  });
                },
              ),
              if (!isLinkMode)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 50,
                          child: TextField(
                            controller: _ipPart1Controller,
                            keyboardType: TextInputType.number,
                            style: AppUtilities.primaryTextStyleWhiteSmall,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: AppUtilities.primaryTextStyleWhiteSmallItalic,
                            ),
                          ),
                        ),
                        Text('.', style: TextStyle(color: Colors.white, fontSize: 20)),
                        SizedBox(
                          width: 50,
                          child: TextField(
                            controller: _ipPart2Controller,
                            keyboardType: TextInputType.number,
                            style: AppUtilities.primaryTextStyleWhiteSmall,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: AppUtilities.primaryTextStyleWhiteSmallItalic,
                            ),
                          ),
                        ),
                        Text('.', style: TextStyle(color: Colors.white, fontSize: 20)),
                        SizedBox(
                          width: 50,
                          child: TextField(
                            controller: _ipPart3Controller,
                            keyboardType: TextInputType.number,
                            style: AppUtilities.primaryTextStyleWhiteSmall,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: AppUtilities.primaryTextStyleWhiteSmallItalic,
                            ),
                          ),
                        ),
                        Text('.', style: TextStyle(color: Colors.white, fontSize: 20)),
                        SizedBox(
                          width: 50,
                          child: TextField(
                            controller: _ipPart4Controller,
                            keyboardType: TextInputType.number,
                            style: AppUtilities.primaryTextStyleWhiteSmall,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: AppUtilities.primaryTextStyleWhiteSmallItalic,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _saveIpAddress,
                      child: Text('IP Adresini Kaydet'),
                    ),
                  ],
                ),
              if (isLinkMode)
                Column(
                  children: [
                    TextField(
                      controller: _linkController,
                      keyboardType: TextInputType.url,
                      style: AppUtilities.primaryTextStyleWhiteSmall,
                      decoration: InputDecoration(
                        hintText: 'Linki buraya girin...',
                        hintStyle: AppUtilities.primaryTextStyleWhiteSmallItalic,
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _saveLink,
                      child: Text('Linki Kaydet'),
                    ),
                  ],
                ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ErrorReportingPopup(senderUsername: userName, senderMail: userEmail);
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                child: Text('Hata Bildir'),
              ),
              SizedBox(height: 5),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen(username: userName)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                child: Text('Şifreyi Değiştir'),
              ),
              SizedBox(height: 5),
              ElevatedButton(
                onPressed: () {
                  UserUtilities.signOut(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                child: Text('Çıkış Yap'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InfoScreen(),
            ),
          );
        },
        child: Icon(
          Icons.info,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      resizeToAvoidBottomInset: true,
    );
  }
}
