import 'dart:async';
import 'dart:convert';

import 'package:barcode_attendance/Delete_user.dart';
import 'package:barcode_attendance/Update_%20user.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:barcode_attendance/New_user.dart';
import 'package:barcode_attendance/Reportgen.dart';
import 'package:barcode_attendance/Splashscreen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter/material.dart' ;
import 'package:flutter/services.dart' ;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:barcode_attendance/login_reg_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
  configLoading();
}

void configLoading() {
  EasyLoading.instance

    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.light
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..maskColor = Colors.blue.withOpacity(0.8)
    ..userInteractions = false
    ..dismissOnTap = false
    ..indicatorColor = Colors.black;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        //statusBarColor: Colors.purple[300],
      )
    );
    return MaterialApp(
      title: 'App',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),

     home: SplashScreen(),
     builder: EasyLoading.init(),
     );
  }
}

class HomePage extends StatefulWidget {
   HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  FocusNode fn = FocusNode();
  late DateTime prevdate,todaydate,now;
  String? scanresult,lastCallDate;
  late TwilioFlutter twilioFlutter;
  List<String> Attendees = [],smsrecievers = [];
  TextEditingController _inpresult = TextEditingController();

   bool _isLoading=false,_ignorepointer = false,_match=false;


  @override
  void initState() {

      internetCheck();
      super.initState();

  }

  void dispose() {
    super.dispose();
  }


  Future<void> internetCheck() async {
    try{
      final dio = Dio();
      var response = await dio.post("https://www.instagram.com/");
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      setState(() {
        _ignorepointer = false;
      });

      _callFunction();
      now = DateTime.now();
      todaydate = DateTime(now!.year,now!.month,now!.day);
      permissonData();
      //twilioinit();
      recievecredentials();
    }
    catch (e){
      setState(() {
        _ignorepointer = true;
      });
      final snackBar = SnackBar(
        content: const Text('No Internet!'),
        action: SnackBarAction(
          label: 'Try Again',
          onPressed: () {
            internetCheck();
          },
        ),
        duration: Duration(days: 365),
      );


      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

  }


  Future<void> scanBarcode() async {
  // barcode scan logic function.
    try {
      
      scanresult = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );
      FlutterBeep.beep();

      if (scanresult == '-1') {
        // User canceled the scan
        print('Scan canceled');
        scanresult = null ;
        var snackBar = SnackBar(
          padding: EdgeInsets.all(16),
          content: Center(
            child: Text("Scan Cancelled",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
            ),
          ),
          backgroundColor: Colors.grey,
          dismissDirection: DismissDirection.horizontal,
          duration: Duration(milliseconds: 1000),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        print("Stored barcode : "+scanresult.toString());
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_NOT_GRANTED') {
        print('Camera permission denied');

        var snackBar = SnackBar(
          content: Text("Camera permission denied"),
          backgroundColor: Colors.brown[800],
          duration: Duration(milliseconds: 4000),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        scanresult = null;
      } else {
        print('Error: $e');
        scanresult = null;
        var snackBar = SnackBar(
          content: Text("$e"),
          backgroundColor: Colors.brown[800],
          duration: Duration(milliseconds: 4000),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print('Error: $e');
      scanresult = null;
      var snackBar = SnackBar(
        content: Text("$e"),
        backgroundColor: Colors.brown[800],
        duration: Duration(milliseconds: 4000),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    if(!mounted) return;

    setState(() {
      this.scanresult = (scanresult !=null )? scanresult!.replaceAll("]C1", ""):scanresult;

    });

  }


  void _callFunction() async {  // new day date compare with previous day
    SharedPreferences prefs = await SharedPreferences.getInstance();
    lastCallDate = prefs.getString('lastCallDate');

    DateTime now2 = DateTime.now();
    String currentDate = "${now2.year}-${now2.month}-${now2.day}";

    print(lastCallDate.toString()+ " ------ "+currentDate);
    lastDateCheck(
        DateTime(now2!.year,now2!.month,now2!.day).toString().replaceAll(" 00:00:00.000", ""),
        currentDate , lastCallDate.toString()
    );

  }


  Future<void> lastDateCheck(String dt,String d1,String d2) async {
    final dio = Dio();
    var formData = FormData.fromMap({
      'method': 'lastDate',

    });
    var response = await dio.post("https://firstflutterapp.000webhostapp.com/myfirstflutter/barcodedb.php", data: formData);
    String responseBody = response.data;
    var d = json.decode(responseBody)['data'];


      setState(() {
        _match = (dt==d.toString());
      });

    if ( (d1!=d2) && !_match) {
      Routine(d1);
      print("HEyyyyyyy how may I help you!!!");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('lastCallDate', d1);
    }
}


  String? usertype,useremail,username,usercontact;
  Future<void> recievecredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    usertype = prefs.getString('usertype')!;
    useremail = prefs.getString('useremail')!;
    username = prefs.getString('username')!;
    usercontact = prefs.getString('usermobileno')!;

    setState(() {
    });
  }

  Future<void> Routine(String todaydate) async { // new day insert data in attendance table routine
    final dio = Dio();
    var formData = FormData.fromMap({
      'method': 'barcodeDailyRoutine',
      'date' : todaydate,

    });
    var response = await dio.post("https://firstflutterapp.000webhostapp.com/myfirstflutter/barcodedb.php", data: formData);
    String responseBody = response.data;
    setState(() {
    });
    var message=json.decode(responseBody)['message'];
    if(message=="Data Found"){
          print("777777"+json.decode(responseBody)['status']);

    }
    else if(message=="Data not found"){
      print("8888888"+json.decode(responseBody)['status']);
    }
  }

  Future<void> Haajri(String barcode,String todaydate) async { // updating attendance in database
    final dio = Dio();
    var formData = FormData.fromMap({
      'method': 'barcodePresence',
      'date' : todaydate,
      'barcodeid' : barcode,
    });
      var response = await dio.post("https://firstflutterapp.000webhostapp.com/myfirstflutter/barcodedb.php", data: formData);
      String responseBody = response.data;
      var stat = json.decode(responseBody)['status'];

      if (stat == "1") {
        fetchMobile(barcode);
        print("After sms");
      }
      else {
        //var msg = json.decode(responseBody)['message'];
        setState(() {
          _isLoading = false;
          EasyLoading.showSuccess(
            'Done!',
            duration: Duration(seconds: 3),
            dismissOnTap: true,
          );
        });
      }

      setState(() {});

  }


  Future<void> fetchMobile(String barcode) async { // fetching mobile from database for sms.
    final dio = Dio();
    var formData = FormData.fromMap({
      'method': 'smsCall',
      'barcodeid' : barcode,
    });
    var response = await dio.post("https://firstflutterapp.000webhostapp.com/myfirstflutter/barcodedb.php", data: formData);
    String responseBody = response.data;
    var stat = json.decode(responseBody)['status'];

      setState(() {
        _isLoading=false;
        EasyLoading.showSuccess('Done!',duration: Duration(seconds: 3),dismissOnTap: true,);

      });

      if(stat=="1"){
        var callno = json.decode(responseBody)['main_data'] ;
        smsrecievers.add(callno[0].toString());
        String MSG = "Namaste 🙏🙏 from Jinesh :)";
        // for(final mob in callno){
        //   String num = "+91" + mob['Mobile'];
        //   print(num);
        //   sendSmsTwilio(num, MSG);
        // }
        _sendSMS(MSG, smsrecievers);

      }
      else{
        print("^^^^^^^^^^^^^^^^^^^^ : "+stat);
      }



  }


  void Haajripuring(List<String> l) async{
    for(final bcode in l){
      if(bcode != null)Haajri(bcode, todaydate.toString());
    }
    print("DONE!!!!");

  }


  void _sendSMS(String message, List<String> recipents) async {
    String _result = await sendSMS(message: message, recipients: recipents,sendDirect: true)
        .catchError((onError) {
      print(onError);
    });
  }


  Future<void> permissonData() async {

    PermissionStatus status = await Permission.sms.request();
    if (status.isGranted) {
      // Permission is granted, proceed with sending SMS
      // ...
    } else {
      // Permission denied, handle accordingly
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
              "SMS permission required!!",
              style: TextStyle(
                fontSize: 18,
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


  // void twilioinit(){
  //   twilioFlutter = TwilioFlutter(
  //       accountSid: 'ACdbe7cc151e6b5b60f8e7556fc55d3269',
  //       authToken: '55c68ba48ae12157e6e3dc6b415f5027',
  //       twilioNumber: '+15416923163');
  // }
  //
  //
  // void sendSmsTwilio(String number,String msg) async {
  //   twilioFlutter.sendSMS(
  //       toNumber: number,
  //       messageBody: msg);
  // }



  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor:Theme.of(context).colorScheme.inversePrimary,
        )
    );


    return Scaffold(

      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),

      drawer: IgnorePointer(
        ignoring: _ignorepointer,
        child: (_ignorepointer) ? Center() : Drawer(
          backgroundColor: Colors.white,
          child: ListView(
                padding: EdgeInsets.zero,
                 children : [
                   UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    accountName: Text(
                      username.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    accountEmail: Text(
                      useremail.toString(),
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: AssetImage('assets/profile.png'),
                    ),
                  ),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.house),
                    title: Text('Home'),
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                    //splashColor: Colors.lightBlueAccent,
                    onTap: () {
                      // Handle drawer item tap
                      Navigator.pop(context);
                    },
                  ),

                   ListTile(
                     leading: Icon(Icons.picture_as_pdf),
                     title: Text('Report'),
                     visualDensity: VisualDensity.adaptivePlatformDensity,
                     //splashColor: Colors.lightBlueAccent,
                     onTap: () {
                       Navigator.pop(context);
                       Navigator.push(
                         context,
                         MaterialPageRoute(builder: (context) => reportgen()),
                       );
                     },
                   ),

                  Visibility(
                    visible:  (usertype == "1"),
                    child: ListTile(
                      leading: Icon(FontAwesomeIcons.personCirclePlus),
                      title: Text('Add person'),
                      visualDensity: VisualDensity.adaptivePlatformDensity,
                      //splashColor: Colors.lightBlueAccent,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => newuser()),
                        );
                      },
                    ),
                  ),
                   Visibility(
                     visible:  (usertype == "1"),
                     child: ListTile(
                       leading: Icon(FontAwesomeIcons.personCircleExclamation),
                       title: Text('Update person'),
                       visualDensity: VisualDensity.adaptivePlatformDensity,
                       //splashColor: Colors.lightBlueAccent,
                       onTap: () {
                         Navigator.pop(context);
                         Navigator.push(
                           context,
                           MaterialPageRoute(builder: (context) => updateuser()),
                         );
                       },
                     ),
                   ),
                   Visibility(
                     visible: (usertype == "1"),
                     child: ListTile(
                       leading: Icon(FontAwesomeIcons.personCircleMinus),
                       title: Text('Delete person'),
                       visualDensity: VisualDensity.adaptivePlatformDensity,
                       //splashColor: Colors.lightBlueAccent,
                       onTap: () {
                         Navigator.pop(context);
                         Navigator.push(
                           context,
                           MaterialPageRoute(builder: (context) => deleteuser()),
                         );
                       },
                     ),
                   ),

                  ListTile(
                    leading: Icon(FontAwesomeIcons.rightFromBracket),
                    title: Text('logout'),
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                    //splashColor: Colors.lightBlueAccent,
                    onTap: () async {
                      // Handle drawer item tap
                      SharedPreferences pre = await SharedPreferences.getInstance();
                      String? tmp = pre.getString('lastCallDate');
                      pre.clear();
                      pre.setString('lastCallDate', tmp!);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginRegPage()),
                      );
                    },
                  ),

              SizedBox(height: 25,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton( onPressed: (){
                      Future<void> launchTwitterURL() async {
                        Uri twitterUrl = Uri.parse("https://twitter.com/milople");
                        if (!await launchUrl(
                          twitterUrl,
                          mode: LaunchMode.externalNonBrowserApplication,)
                        ) {
                          throw 'Could not launch Twitter URL';
                        }
                      }
                      launchTwitterURL();
                    },
                    icon: Icon(FontAwesomeIcons.twitter),),

                  IconButton(onPressed: (){
                    Future<void> launchLinkedinURL() async {
                      Uri linkedUrl = Uri.parse("https://www.linkedin.com/company/milople");
                      if (!await launchUrl(
                        linkedUrl,
                        mode: LaunchMode.externalNonBrowserApplication,)
                      ) {
                        throw 'Could not launch linkedin URL';
                      }
                    }
                    launchLinkedinURL();
                  },
                    icon: Icon(FontAwesomeIcons.linkedinIn),),

                  IconButton( onPressed: (){
                    Future<void> launchInstagramURL() async {
                      Uri instagramUrl = Uri.parse("https://www.instagram.com/milople/");
                      if (!await launchUrl(
                        instagramUrl,
                        mode: LaunchMode.externalNonBrowserApplication,)
                      ) {
                        throw 'Could not launch Instagram URL';
                      }
                    }
                    launchInstagramURL();
                  },
                    icon: Icon(FontAwesomeIcons.instagram),),

                  IconButton( onPressed: (){
                    Future<void> launchYoutubeURL() async {
                      Uri youtubeUrl = Uri.parse("https://www.youtube.com/channel/UC2wZcyQ9DYKRERy5dMNGTtQ");
                      if (!await launchUrl(
                        youtubeUrl,
                        mode: LaunchMode.externalNonBrowserApplication,)
                      ) {
                        throw 'Could not launch Youtube URL';
                      }
                    }
                    launchYoutubeURL();
                  },
                    icon: Icon(FontAwesomeIcons.youtube),),

                  IconButton( onPressed: (){
                      Future<void> launchFacebookURL() async {
                        Uri facebookUrl = Uri.parse("https://www.facebook.com/Milople");
                        if (!await launchUrl(
                            facebookUrl,
                        mode: LaunchMode.externalNonBrowserApplication,)
                        ) {
                          throw 'Could not launch Facebook URL';
                        }
                      }
                        launchFacebookURL();
                    },
                    icon: Icon(FontAwesomeIcons.facebook),),
                ],
              ),
            ],
          ),
        ),
      ),

      body:_isLoading ? Center(child: CircularProgressIndicator(),) : IgnorePointer(
        ignoring: _ignorepointer,
        child: SingleChildScrollView(

          child: Column(

            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: <Widget>[

              Container(
                padding: EdgeInsets.only(left: 25,top: 35,right: 25,bottom: 15),
                child: TextField(
                  controller: _inpresult,
                  focusNode: fn,
                  onTap: (){
                      fn.requestFocus();
                  },
                  onTapOutside: (pd){
                    fn.unfocus();
                  },
                  onChanged: (value) {},
                  decoration: const InputDecoration(
                    labelText: 'Barcode ID',
                    hintText: 'C-000',
                    border: OutlineInputBorder(),

                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(10),FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-]')),],
                ),
              ),

              SizedBox(height: 60,),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: EdgeInsets.all(5),
                  height: 109,
                  width: 255,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    //borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Image.asset('assets/barcode1.gif',
                  height: 200,

                  ),

                ),
              ),

              SizedBox(height: 90,),
              ElevatedButton.icon(
                  onPressed: (){
                    scanBarcode();

                    if(this.scanresult != null)Attendees.add(this.scanresult!);
                },
                  icon: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.camera_alt,size: 28,),
                  ),

                  label: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Scan Barcode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
              ),
                  ),
              ),
              Text(
                scanresult == null ? '' : 'Scan Result : $scanresult',
              ),
              SizedBox(height: 110,),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          onPressed: () async{
                            try{
                                    final dio = Dio();
                                    var response = await dio.post("https://www.instagram.com");
                                    print("HHHHHHHHHHiiiiiiiiiiiii");
                                    if (this.scanresult != null)
                                        Attendees.add(this.scanresult!);
                                    if (_inpresult.text.isNotEmpty)
                                        Attendees.add(_inpresult.text);
                                    if (Attendees.isNotEmpty) {
                                        setState(() {
                                          if (Attendees.length != 0)
                                            _isLoading = true;
                                          // CircularProgressIndicator();
                                        });
                                        Haajripuring(Attendees);

                                        smsrecievers.clear();
                                        Attendees.clear();
                                        scanresult = null;
                                        _inpresult.clear();
                                    } else {
                                        var sb = SnackBar(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .background,
                                          content: Container(
                                            padding: EdgeInsets.all(16),
                                            height: 70,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFC72C41),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(25)),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Please scan/enter Barcode!!",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          duration: Duration(seconds: 3),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(sb);
                                    }
                                  }
                                  catch (e){
                                    EasyLoading.showError('No Internet Connection !',duration: Duration(seconds: 4),dismissOnTap: false,);
                                  }
                                },

                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text("Submit",
                            style: TextStyle(
                              fontSize: 17,
                            ),),
                          )
                      ),

                      SizedBox(width: 50,),

                      ElevatedButton(
                          onPressed: (){

                            setState(() {

                            });
                            smsrecievers.clear();
                            Attendees.clear();
                            scanresult = null;
                            _inpresult.clear();

                          },

                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text("Cancel",
                              style: TextStyle(
                                fontSize: 17,
                              ),),
                          )
                      ),
                    ],
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



// flutter build apk --debug
// 000Webhost  .com
// website name : - firstflutterapp,  pass : Myfirstflutter@11  (same credendentials for file manager login)
// database name : id21006595_appdb , username : id21006595_myappdb, pass : Flutterapp1@db
