import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barcode_attendance/main.dart';
import 'package:barcode_attendance/signup.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class Loginpg extends StatefulWidget {
  const Loginpg({super.key});

  @override
  State<Loginpg> createState() => _LoginpgState();
}

class _LoginpgState extends State<Loginpg> {

  TextEditingController _emailphoneController = TextEditingController();
  TextEditingController _passController = TextEditingController();
  // bool _validateName=false;

  @override
  void initState() {
    EasyLoading.init();
    super.initState();

  }

  @override
  void dispose() {
    _emailphoneController.dispose();
    _passController.dispose();
    super.dispose();
  }


  Future<void> storecredentials(String n,String M,String em, String ut,String bcd) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username',n);
    prefs.setString('useremail',em);
    prefs.setString('usermobileno', M);
    prefs.setString('usertype', ut);
    prefs.setString('barcodeid', bcd);

  }

  String?  _emailphoneerror, _passerror;

  void validmailphone(String val) {
    setState(() {
      _emailphoneerror = val.isEmpty ? 'Username is required.' : null;
    });
  }

  void validpass(String val) async{
    setState(() {

      if (val.isEmpty) {
        _passerror = 'Password is required.';
      }
        else
        _passerror = null;
    });
  }

  bool _passinvis = true;

  Future<void> checkCredentials(String username,String pass) async { // updating attendance in database
    final dio = Dio();
    var formData = FormData.fromMap({
      'method': 'loginLogic',
      'emailorphone' : username,
      'password' : pass,
    });
    try{
      var response = await dio.post("https://firstflutterapp.000webhostapp.com/myfirstflutter/barcodedb.php", data: formData);
      EasyLoading.dismiss();
      String responseBody = response.data;
      var stat = json.decode(responseBody)['status'];



      if(stat=="1"){
        var data = json.decode(responseBody)['main_data'] ;
        for(final d in data){
          storecredentials(d['name'], d['mobileno'], d['email'], d['usertype'],d['barcodeid']);
        }
        _emailphoneerror = null;
        _passerror = null;
      }
      else if(stat=="-1"){
        setState(() {
          _emailphoneerror = json.decode(responseBody)['message'];
          _passerror = json.decode(responseBody)['message'];
        });
        print("qqqqqqqqqqqqqqqqqqqqqq "+_emailphoneerror.toString());
      }

      else{
        print("^^^^^^^^^^^^^^^^^^^^ : "+stat);
      }

      if ((_emailphoneerror == null) && (_passerror == null)) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomePage(title: 'Barcode Scanner')));
      }
      else{
        print("0000000000000000000000 "+_passerror.toString());
        print("qqqqqqqqqqqqqqqqqqqqqq "+_emailphoneerror.toString());
        _emailphoneerror = null;
        _passerror = null;
        var sb =  SnackBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          content: Container(
            padding: EdgeInsets.all(16),
            height: 70,
            decoration: BoxDecoration(
              color: Color(0xFFC72C41),
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            child: Center(
              child: Text(
                "No User Found!",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ) ,
          duration: Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).showSnackBar(sb);
      }
    }
    catch (e){
      EasyLoading.dismiss();
      EasyLoading.showError('No Internet Connection !',duration: Duration(seconds: 4),dismissOnTap: true,);
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        // title:  Text(
        //   'Login',
        //   style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary,),
        // ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Container(
          // height: MediaQuery.of(context).size.height,
          // width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 75,),
                Text ("Login", style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),),
                SizedBox(height: 20,),
                Text("Welcome back ! ",style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                ),),
                SizedBox(height: 30,),

                TextField(
                  controller: _emailphoneController,
                  onChanged: (value) {
                    validmailphone(value);
                  },
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  enableSuggestions: true,
                  decoration: InputDecoration(
                    labelText: 'UserName',
                    hintText: 'Email or phone number',
                    errorText: _emailphoneerror,
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _passController,
                  //  onChanged: (value){validpass(value);},
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _passinvis,
                  obscuringCharacter: '*',
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: _passerror,
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _passinvis ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _passinvis = !_passinvis;
                        });
                      },
                    ),
                  ),
                  //inputFormatters: [LengthLimitingTextInputFormatter(10),FilteringTextInputFormatter.digitsOnly],
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  width: 550,
                  height: 60,
                  child: ElevatedButton(
                      onPressed: () {
                        // _nameController.text.isEmpty? _validateName=true:_validateName=false;
                        EasyLoading.show(status: 'Signing in...');
                        validpass(_passController.text);
                        validmailphone(_emailphoneController.text);
                        if( _passerror == null && !EmailValidator.validate(_emailphoneController.text) ){
                          _emailphoneerror = 'Please enter valid email.';
                          bool allnum = true;
                          String s = _emailphoneController.text;
                          for (int i = 0; i < _emailphoneController.text.length; i++) {
                              if(!(s.codeUnitAt(i) >= 48 && s.codeUnitAt(i) <= 57)){
                                allnum = false;
                              }
                          }
                          if(allnum && (_emailphoneController.text.length == 10)){
                            _emailphoneerror = null;
                            // check for credentials from database
                            checkCredentials(_emailphoneController.text, _passController.text);
                          }
                          else _emailphoneerror = "Please enter valid phone number.";
                        }

                        else if(_passerror == null) {
                          // check for credentials from database
                          checkCredentials(_emailphoneController.text, _passController.text);
                        }


                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      )),
                ),

                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Dont have an account?"),
                    InkWell(
                      onTap: (){
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => signup()),
                        );
                      },
                      child: Text("Sign Up",style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18
                      ),),
                    ),
                  ],
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
