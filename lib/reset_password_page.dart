import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'AppUtilities.dart';


class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  void onTapResetPassword() async {
    if (_emailController.text.isEmpty) {
      AppUtilities.showAlertDialog(
        'Hata',
        'Lütfen e-posta adresinizi girin!',
        context,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
      AppUtilities.showAlertDialogAndNavigate(
        'Başarılı',
        'Şifre sıfırlama isteği gönderildi. Lütfen e-posta adresinizi kontrol edin.',
        'LoginPage',
        _emailController.text,
        context,
      );
    } catch (e) {
      String errorMessage = "Bir hata oluştu. Lütfen tekrar deneyin.";
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'Geçersiz e-posta adresi formatı. Lütfen doğru bir e-posta adresi girin.';
            break;
          case 'user-not-found':
            errorMessage = 'Bu e-posta adresine kayıtlı bir hesap bulunamadı.';
            break;
          default:
            errorMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.';
            break;
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
        title: Text('Şifremi Unuttum'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: AppUtilities.backgroundColor),
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
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : InkWell(
              onTap: onTapResetPassword,
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
                      "Şifre Sıfırlamak İçin E-posta Gönder",
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
          ],
        ),
      ),
    );
  }
}
