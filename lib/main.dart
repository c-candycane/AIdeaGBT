import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'AppUtilities.dart';
import 'login_page.dart';
import 'mainScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Colors.blue,
            onPrimary: Color.fromRGBO(31, 44, 55, 1),
            secondary: Colors.blue,
            onSecondary: Colors.blue,
            error: Colors.red,
            onError: Colors.red,
            background: Color.fromRGBO(31, 44, 55, 1),
            onBackground: Color.fromRGBO(31, 44, 55, 1),
            surface: Colors.white,
            onSurface: Color.fromRGBO(31, 44, 55, 1),

          ),


          scaffoldBackgroundColor: Color.fromRGBO(31, 44, 55, 1),
          appBarTheme: const AppBarTheme(
              backgroundColor: Color.fromRGBO(31, 44, 55, 1),
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 24)),
          progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: Colors.blue),
          buttonTheme: const ButtonThemeData(buttonColor: Colors.blue),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),

                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              )),
          switchTheme: SwitchThemeData(
            thumbColor: MaterialStateProperty.all<Color>(Colors.blue),
            trackColor: MaterialStateProperty.all<Color>(Colors.white),
            trackOutlineColor:
            MaterialStateProperty.all<Color>(Colors.transparent),
          ),
          checkboxTheme: CheckboxThemeData(
            fillColor: MaterialStateProperty.all<Color>(Colors.white),
            checkColor: MaterialStateProperty.all<Color>(Colors.blue),
            overlayColor: MaterialStateProperty.all<Color>(Colors.blue),
          ),
          dropdownMenuTheme: const DropdownMenuThemeData(
            textStyle: TextStyle(color: Colors.white),
          ),
          primaryColor: Colors.blue,
          primarySwatch: Colors.blue,
          indicatorColor: Colors.blue,

          listTileTheme: const ListTileThemeData(
            textColor: Colors.white,
          ),
          iconButtonTheme: IconButtonThemeData(
              style: ButtonStyle(
                iconColor: MaterialStateProperty.all<Color>(Colors.blue),
              )),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.blue,

          )),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Timer? _timer;

  @override
  void initState() {
    User? user = FirebaseAuth.instance.currentUser;
    super.initState();
    if (user!=null){
      _timer = Timer(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => mainScreen(title: "user")),
        );
      });
    }
    else{
      _timer = Timer(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage(title: "firstMain")),
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Stack(
          children: [
            Positioned(
              top: 130,
              left: 10,
              right: 10,
              child: Image.asset(
                AppUtilities.appLogoPath,
                height: 220,
                width: 180,
              ),
            ),
            const Positioned(
              bottom: 160,
              left: 15,
              right: 10,
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      "AIdeaGBT",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.0,
                          fontFamily: 'AsusRog'
                      ),
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