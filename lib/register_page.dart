import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'AppUtilities.dart';
import 'FirebaseUtilities.dart';
import 'login_page.dart';
import 'mainScreen.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordNController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();

  bool _isLoading = false;
  bool showPassword = false;

  void onTapRegister() {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _passwordNController.text.isEmpty ||
        _firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty) {
      AppUtilities.showAlertDialog(
        'Hata',
        'Tüm alanları doldurmalısınız!',
        context,
      );
      return;
    }

    if (_passwordController.text == _passwordNController.text) {
      if (UserUtilities.isStrongPassword(_passwordNController.text)){
        if (UserUtilities.isValidEmail(_emailController.text)) {
          if (UserUtilities.isValidName(_firstNameController.text)) {
            if (UserUtilities.isValidName(_lastNameController.text)) {
              registerUser(
                _emailController.text.trim(),
                _passwordController.text,
                _firstNameController.text.trim(),
                _lastNameController.text.trim(),
              );
            } else {
              AppUtilities.showAlertDialog(
                'Hata',
                'Lütfen geçerli bir soyad girin.\nİlk harfi büyük, diğer harfleri küçük olmalı',
                context,
              );
            }
          } else {
            AppUtilities.showAlertDialog(
              'Hata',
              'Lütfen geçerli bir ad girin.\nİlk harfi büyük, diğer harfleri küçük olmalı',
              context,
            );
          }
        } else {
          AppUtilities.showAlertDialog(
            'Hata',
            'Lütfen geçerli bir mail girin.',
            context,
          );
        }
      }
       else {
        AppUtilities.showAlertDialog(
            'Hata',
            'Şifre güvenliği zayıf! Şifre en az 8 karakter uzunluğunda olmalı ve '
                'en az bir büyük harf, bir küçük harf, ve bir sayı '
                'içermelidir.', context);
      }
    } else {
      AppUtilities.showAlertDialog(
        'Hata',
        'Şifreler aynı değil!',
        context,
      );
    }
  }



  void registerUser(String email, String password, String firstName, String lastName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        String userId = userCredential.user!.uid;

        // Yeni kullanıcı belgesini oluştur
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
        });



        print('Kullanıcı oluşturuldu: $userId');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => mainScreen(title: "main")),
              (route) => false,
        );
      }
    } catch (e) {
      String errorMessage = "Bir hata oluştu. Lütfen tekrar deneyin.";
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'Şifre zayıf. Daha güçlü bir şifre seçin.';
            break;
          case 'email-already-in-use':
            errorMessage = 'Bu e-posta adresi zaten kullanılıyor. Lütfen giriş yapın.';
            break;
          case 'invalid-email':
            errorMessage = 'Geçersiz e-posta adresi formatı. Lütfen doğru bir e-posta adresi girin.';
            break;
          default:
            errorMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.';
            break;
        }
        if (e.code == 'email-already-in-use') {
          AppUtilities.showAlertDialogAndNavigate('Hata', errorMessage, "LoginPage", email, context);
          return;
        }
      }
      AppUtilities.showAlertDialog('Hata', errorMessage, context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      backgroundColor: Color.fromRGBO(31, 44, 55, 1),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Image.asset(AppUtilities.appLogoPath, height: 120, width: 120),
                    SizedBox(height: 10),
                    Text(
                      AppUtilities.appName,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        fontFamily: 'AsusRog',
                      ),
                    ),
                    SizedBox(height: 8),
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
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Ad',
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
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
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Soyad',
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Color.fromRGBO(31, 44, 55, 1)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'E-posta',
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
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
                            controller: _passwordController,
                            obscureText: !showPassword, // Şifrenin gizlenmesini kontrol etmek için obscureText özelliğini kullanın
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Şifre',
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
                    SizedBox(height: 10.0),
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
                            controller: _passwordNController,
                            obscureText: !showPassword, // Şifrenin gizlenmesini kontrol etmek için obscureText özelliğini kullanın
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Şifreyi Doğrula',
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    if (_isLoading)
                      CircularProgressIndicator()
                    else
                      GestureDetector(
                        onTap: onTapRegister,
                        
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppUtilities.primaryButtonColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: InkWell(
                                onTap: onTapRegister,
                                child: Text(
                                  "Kayıt Ol",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Kayıtlı mısınız?",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage(title: "login")),
                                  (route) => false,
                            );
                          },
                          child: const Text(
                            " Şimdi Giriş Yapın!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppUtilities.primaryButtonColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
