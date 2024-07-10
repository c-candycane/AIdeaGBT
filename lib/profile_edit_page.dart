

import 'package:aideagbt/reset_password_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'AppUtilities.dart';
import 'FirebaseUtilities.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
class ProfileScreen extends StatefulWidget {

  const ProfileScreen({Key? key, required this.username}) : super(key: key);

  final String username;
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String currentPassword = '';
  String newPassword = '';
  String confirmNewPassword = '';

  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();



  bool showPassword = false;

  bool showPasswordN= false;

  @override
  void initState() {
    currentPasswordController.text = currentPassword;
    newPasswordController.text = newPassword;
    confirmNewPasswordController.text = confirmNewPassword;

    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    void onSaveButtonPressed() async {
      User? user = FirebaseAuth.instance.currentUser;

      String currentPassword = currentPasswordController.text;
      String newPassword = newPasswordController.text;
      String confirmNewPassword = confirmNewPasswordController.text;

      // Hata durumları için kontrol yapın
      if (newPassword.isEmpty) {
        AppUtilities.showAlertDialog('Hata', 'Yeni şifre boş olamaz. Lütfen bir şifre girin.', context);
        return;
      }
      if (newPassword != confirmNewPassword) {
        AppUtilities.showAlertDialog('Hata', 'Yeni şifreler uyuşmuyor. Lütfen doğru şekilde girin.', context);
        return;
      }
      else if (!UserUtilities.isStrongPassword(newPassword)){
        AppUtilities.showAlertDialog('Hata', 'Şifre güvenliği zayıf! Şifre en az 8 karakter uzunluğunda olmalı ve en az bir büyük harf, bir küçük harf, bir sayı ve bir özel karakter içermelidir.', context);
        return;
      }
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user!.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);

        await user.updatePassword(newPassword);
        UserUtilities.signOut(context);

      } catch (e) {

        AppUtilities.showAlertDialog('Hata', 'Mevcut şifre yanlış. Lütfen doğru şifreyi girin.', context);

      }
    }


    return Scaffold(

      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.username,
          style: TextStyle(fontSize: 24),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                'Şifreyi Düzenle',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextField(
                      controller: currentPasswordController,
                      obscureText: !showPasswordN,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Mevcut Şifre',
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              showPasswordN = !showPasswordN; // CheckBox işaretlendiğinde showPassword değerini tersine çevirin
                            });
                          },
                          child: Icon(
                            showPasswordN ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextField(
                      controller: newPasswordController,
                      obscureText: !showPassword, // Şifrenin gizlenmesini kontrol etmek için obscureText özelliğini kullanın
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Yeni Şifre',
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              showPassword = !showPassword; // CheckBox işaretlendiğinde showPassword değerini tersine çevirin
                            });
                          },
                          child: Icon(
                            showPassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextField(
                      controller: confirmNewPasswordController,
                      obscureText: !showPassword, // Şifrenin gizlenmesini kontrol etmek için obscureText özelliğini kullanın
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Yeni Şifreyi Onayla',
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.0),
              InkWell(
                onTap: () {
                  onSaveButtonPressed();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppUtilities.primaryButtonColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: InkWell(
                        onTap: () {},
                        child: Text(
                          "Kaydet",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ResetPasswordPage()),
                  );
                },
                child: Text(
                  'Şifremi Unuttum',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: AppUtilities.primaryButtonColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

