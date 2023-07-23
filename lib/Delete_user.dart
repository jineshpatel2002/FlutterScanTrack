import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:barcode_attendance/main.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class deleteuser extends StatefulWidget {
  const deleteuser({super.key});

  @override
  State<deleteuser> createState() => _deleteuserState();
}

class _deleteuserState extends State<deleteuser> {

  TextEditingController _barcodeid = TextEditingController();
   bool isOpen =false,_ignorepointer=false,_isloading=false;

  final List<String> barcodelist = [],names = [],_selectedbarcodes=[];


  String? Barcode;

  @override
  void initState() {
    internetCheck();
    super.initState();

  }
  @override
  void dispose() {
    _barcodeid.dispose();
    super.dispose();
  }

Future<void> internetCheck() async {
  try{
    final dio = Dio();
    var response = await dio.post("https://www.instagram.com");
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() {
      _ignorepointer = false;
      _isloading = true;
    });

    setState(() {
      FetchBarcodeName();
    });
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

  Future<void> DeleteUser(String barcode) async { // Delete a user
    final dio = Dio();
    var formData = FormData.fromMap({
      'method': 'deleteUser',
      'barcodeid' : barcode,

    });

      var response = await dio.post("https://firstflutterapp.000webhostapp.com/myfirstflutter/barcodedb.php", data: formData);
      String responseBody = response.data;
      var stat = json.decode(responseBody)['status'];

      setState(() {
        if(stat=="1"){
          // success
        }
        else{
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
                  json.decode(responseBody)['message'],
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


      });

  }


  Future<void> FetchBarcodeName() async { // fetch barcode

    final dio = Dio();
    var formData = FormData.fromMap({
      'method': 'fetchBarcodeName',

    });
    var response = await dio.post("https://firstflutterapp.000webhostapp.com/myfirstflutter/barcodedb.php", data: formData);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _isloading = false;
      String responseBody = response.data;

      var stat = json.decode(responseBody)['status'];

      if(stat=="1"){
        // store barcode
        var msg = json.decode(responseBody)['main_data'] ;

        for(final person in msg){
          if(prefs.getString('barcodeid') == person['barcodeid'])continue;
          barcodelist.add(person['barcodeid']);
          names.add(person['name']);
        }

      }
      else{
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
                json.decode(responseBody)['message'],
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ) ,
          duration: Duration(seconds: 5),
        );
        ScaffoldMessenger.of(context).showSnackBar(sb);
      }

    });

  }


  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedbarcodes.add(itemValue);
      } else {
        _selectedbarcodes.remove(itemValue);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Delete Users',),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: IgnorePointer(
        ignoring: _ignorepointer,
        child: SingleChildScrollView(
          child: Container(
             //height: MediaQuery.of(context).size.height -20,
            // width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  SizedBox(height: 20,),
                  Text ("Select users to delete : ", style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),),

                  SizedBox(height: 30,),


                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      padding: EdgeInsets.all(5),
                      height: 495,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: _isloading ? Center(child: CircularProgressIndicator(),) : ListView.builder(
                        itemCount: barcodelist.length,
                        itemBuilder: (BuildContext context, int pos){
                          return Card(
                            elevation: 5,
                            shadowColor: Colors.brown,
                            child: CheckboxListTile(
                              title: Text(names[pos]),
                              subtitle: Text(barcodelist[pos]),
                              value: _selectedbarcodes.contains(barcodelist[pos]),
                              onChanged: (isChecked){
                                setState(() {
                                  _itemChange(barcodelist[pos], isChecked!);
                                });
                              },
                            ),
                          );
                        }
                        ,

                      ),
                    ),
                  ),
                  SizedBox(height: 30,),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: MediaQuery.of(context).size.width,
                    height: 60,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.delete),
                        onPressed: () async {

                          try {
                            final dio = Dio();
                            var response = await dio.post("https://www.instagram.com");


                            if(_selectedbarcodes.isEmpty){
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
                                      "Please Select !!",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ) ,
                                duration: Duration(seconds: 2),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(sb);
                            }
                            else{
                              for(final Barcode in _selectedbarcodes){
                                setState(() {
                                  DeleteUser(Barcode);
                                });
                              }

                              String sbmsg = (_selectedbarcodes.length).toString()  ;
                              sbmsg = sbmsg + " Users Deleted!!";
                              var sb =  SnackBar(
                                backgroundColor: Theme.of(context).colorScheme.background,
                                content: Container(
                                  padding: EdgeInsets.all(16),
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent,
                                    borderRadius: BorderRadius.all(Radius.circular(25)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      sbmsg,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ) ,
                                duration: Duration(seconds: 3),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(sb);

                              Timer(Duration(milliseconds: 3500), () {
                                Navigator.pop(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomePage(title: "Barcode Scanner")),
                                );
                              });
                            }
                          }
                          catch (e) {
                            EasyLoading.showError('No Internet Connection !',duration: Duration(seconds: 4),dismissOnTap: false,);
                          }
                        },

                        label: Text('Delete',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        )
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
