import 'package:barcode_attendance/Loginpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_attendance/signup.dart';

class LoginRegPage extends StatelessWidget {
  const LoginRegPage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor:Theme.of(context).colorScheme.inversePrimary,
        )
    );
    return Scaffold(

      body: SafeArea(
      child: SingleChildScrollView(
        child: Container(
        // width: MediaQuery.of(context).size.width,
        // height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.symmetric(horizontal: 30,vertical: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Hello There!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
            ),
            SizedBox(height: 30,),
            Container(
              //color: Colors.white,
              height: MediaQuery.of(context).size.height/3,
              decoration: BoxDecoration(
                  image:DecorationImage(image: AssetImage('assets/milople.png'))
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              width: 550,
              height: 60,
              //color: Theme.of(context).primaryColorLight,
              child: ElevatedButton(
                  onPressed: () {
                    // _nameController.text.isEmpty? _validateName=true:_validateName=false;

                    Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Loginpg()));
                    },

                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  )
              ),
            ),

            SizedBox(height: 30,),

            Container(
              //color: Theme.of(context).primaryColorLight,
              padding: EdgeInsets.symmetric(horizontal: 20),
              width: 550,
              height: 60,
              child: ElevatedButton(
                  onPressed: () {
                    // _nameController.text.isEmpty? _validateName=true:_validateName=false;

                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                signup()));
                  },

                  child: Text(
                    'Sign-Up',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  )
              ),
            )

          ],
        ),
    ],
   ),
  ),
      ),
  ),
  );
  }
}
