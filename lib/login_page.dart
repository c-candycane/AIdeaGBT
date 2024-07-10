import 'package:aideagbt/register_page.dart';
import 'package:aideagbt/reset_password_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'AppUtilities.dart';
import 'FirebaseUtilities.dart';
import 'mainScreen.dart';
import 'package:google_sign_in/google_sign_in.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool _isLoading = false;
  bool showPassword = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkEmailValidity();
  }

  void checkEmailValidity() {
    if (UserUtilities.isValidEmail(widget.title)) {
        _emailController.text = widget.title;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(31, 44, 55, 1),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Image.asset(AppUtilities.appLogoPath, height: 180, width: 180),
                    SizedBox(height: 20),
                    Text(
                      AppUtilities.appName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontFamily: 'AsusRog',
                      ),
                    ),
                    SizedBox(height: 30),
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
                            obscureText: !showPassword,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Şifre',
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showPassword = !showPassword;
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
                    SizedBox(height: 10),
                    if (_isLoading)
                      CircularProgressIndicator()
                    else
                      InkWell(
                        onTap: () {
                          signUserIn();
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
                              child: Text(
                                "Giriş Yap",
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
                    SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Kayıtlı değil misiniz?",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegisterPage(title: "register")),
                            );
                          },
                          child: Text(
                            " Şimdi Kaydolun!",
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppUtilities.primaryButtonColor,),
                          ),
                        ),
                      ],
                    ),
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
                          color: AppUtilities.primaryButtonColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            signUserInGoogle();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          ),
                          icon: Image.asset(
                            "images/google.png",
                            height: 24,
                            width: 24,
                          ),
                          label: Text(
                            "Google hesabı ile giriş yap",
                            style: TextStyle(
                              color: Color.fromRGBO(31, 44, 55, 1),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  signUserInGoogle() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        await _auth.signOut();

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        User? user = userCredential.user;
        if (user != null) {
          if (userCredential.additionalUserInfo?.isNewUser == true) {
            List<String>? nameParts = user.displayName!.split(' ');
            String firstName = nameParts.first;
            String lastName = nameParts.length > 1 ? nameParts.last : '';
            String userId = user.uid;
            String? email = user.email;
            await FirebaseFirestore.instance.collection('users').doc(userId).set({
              'firstName': firstName,
              'lastName': lastName,
              'email' : email,
            });

          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => mainScreen(title: "firstMain")),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      AppUtilities.showAlertDialog("Giriş hatası", "Google hesabı ile giriş yaparken bir hata oluştu.",context);
      print("Giriş hatası: $e");
    }
  }

  signUserIn() async {
    setState(() {
      _isLoading = true;
    });

    if (_emailController.text.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      AppUtilities.showAlertDialog("Hata", "E-posta alanı boş olamaz.",context);
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      AppUtilities.showAlertDialog("Hata", "Şifre alanı boş olamaz.",context);
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => mainScreen(title: "firstMain")),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      String errorMessage = "Giriş hatası";
      if (e is FirebaseAuthException) {
        print(e.code);
        if (e.code == 'user-not-found') {
          errorMessage = "Bu e-posta adresine kayıtlı kullanıcı bulunmamaktadır.";
        } else if (e.code == 'invalid-credential') {
          errorMessage = "E-posta veya şifreniz yanlış.";
        } else if (e.code == 'invalid-email') {
          errorMessage = "Lütfen geçerli bir e-posta girin.";
        }

      }
      AppUtilities.showAlertDialog("Lütfen tekrar deneyin.", errorMessage,context);
      print("Giriş hatası: $e");
    }
  }
}
