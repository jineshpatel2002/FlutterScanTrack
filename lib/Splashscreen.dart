import 'dart:async';
import 'package:barcode_attendance/main.dart';
import 'package:barcode_attendance/login_reg_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    recievecredentials();

  }

  String? userpass,useremail,username,usercontact;
  Future<void> recievecredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      useremail = prefs.getString('useremail');
    });
    nextPage();
  }

  void nextPage(){
    if(useremail==null){
      Timer(Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginRegPage()),
        );
      });
    }
    else{
      Timer(Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(title: "Barcode Scanner")),
        );
      });
    }

  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor:Theme.of(context).colorScheme.inversePrimary,
        )
    );
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Image(
                  image: AssetImage('assets/milople.png'),
                   height: 300,
                   width: 355,
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

