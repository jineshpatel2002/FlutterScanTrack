import 'dart:async';
import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:barcode_attendance/main.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dio/dio.dart';

class updateuser extends StatefulWidget {
  const updateuser({super.key});

  @override
  State<updateuser> createState() => _updateuserState();
}

class _updateuserState extends State<updateuser> {

  TextEditingController _nameController = TextEditingController();
  TextEditingController _barcodeid = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passController = TextEditingController();
  TextEditingController _confirmpassController = TextEditingController();
  // bool _validateName=false;

  final List<String> barcodelist = [],names = [], type = [
    'Admin',
    'Sub admin',
    'Member'
  ];
  String? Barcode,userType;

  @override
  void initState() {
    super.initState();
    setState(() {
      FetchBarcodeName();
    });
  }
  @override
  void dispose() {
    _barcodeid.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmpassController.dispose();
    super.dispose();
  }

  String? _nameerror,_phonerror,_emailerror,_barcodeerror,_utypeerror,_passerror,_conpaserror;
  void validname(String val){
    setState(() {
      _nameerror = val.isEmpty ? 'Name is required.':null;
    });
  }
  void validphone(String val){
    setState(() {
      _phonerror = val.isEmpty ? 'Phone is required.':null;
    });
  }
  void validmail(String val){
    setState(() {
      _emailerror = val.isEmpty ? 'Email is required.':null;
    });
  }
  void validbarcode(String? val){
    setState(() {
      _barcodeerror = val== null ? 'Please select a user Barcode':null;
    });
  }

  void validutype(String? val){
    setState(() {
      _utypeerror = val==null ? 'Please select a user type':null;
    });
  }

  void validpass(String val) {
    bool Capletter = false, Specchar = false;
    setState(() {
      for (int i = 0; i < val.length; i++) {
        if (val.codeUnitAt(i) >= 65 && val.codeUnitAt(i) <= 90) {
          Capletter = true;
        }
      }

      for (int i = 0; i < val.length; i++) {
        if ((val.codeUnitAt(i) >= 33 && val.codeUnitAt(i) <= 47) ||
            (val.codeUnitAt(i) >= 58 && val.codeUnitAt(i) <= 64) ||
            (val.codeUnitAt(i) >= 91 && val.codeUnitAt(i) <= 96) ||
            (val.codeUnitAt(i) >= 123 && val.codeUnitAt(i) <= 126)) {
          Specchar = true;
        }
      }

      if (val.isEmpty) {
        _passerror = 'Password is required.';
      } else if(val.length <8){
        _passerror = 'Password length must be atleast 8.';
      } else if (!Capletter) {
        _passerror = 'Password must contain atleast 1 Capital Letter.';
      } else if (!Specchar) {
        _passerror = 'Password must contain atleast 1 Special Character.';
      } else
        _passerror = null;
    });
  }

  void validconfirmpass(String val,String val1){
    setState(() {
      if(val.isEmpty){
        _conpaserror = 'Confirm Password is required.';
      }
      else if(val != val1){
        _conpaserror = 'Confirm Password and Password must be same!!';
      }
      else{
        _conpaserror = null;
      }
    });

  }

  bool _passinvis = true, _conpassinvis = true;


  Future<void> UpdateUser(String barcode,String name,String mobileno,String email,int usertype,String? pass) async { // New user entry
    final dio = Dio();
    var formData = FormData.fromMap({
      'method': 'updateUser',
      'name' : name,
      'barcodeid' : barcode,
      'mobileno' : mobileno,
      'email' : email,
      'usertype' : usertype,
      'password' : pass,
    });
    var response = await dio.post("https://firstflutterapp.000webhostapp.com/myfirstflutter/barcodedb.php", data: formData);
    String responseBody = response.data;
    var stat = json.decode(responseBody)['status'];

    if(stat=="1"){
      print(json.decode(responseBody)['message']);
    }
    else{
      print("^^^^^^^^^^^^^^^^^^^^ : "+stat);
    }

  }


  Future<void> FetchBarcodeName() async { // fetch barcode
    final dio = Dio();
    var formData = FormData.fromMap({
      'method': 'fetchBarcodeName',

    });
    var response = await dio.post("https://firstflutterapp.000webhostapp.com/myfirstflutter/barcodedb.php", data: formData);
    setState(() {

      String responseBody = response.data;

      var stat = json.decode(responseBody)['status'];

      if(stat=="1"){
        // store barcode
        var msg = json.decode(responseBody)['main_data'] ;

        for(final person in msg){
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: const Text('Update User ',),
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

                SizedBox(height: 30,),
                // Text ("Welcome!!", style: TextStyle(
                //   fontSize: 30,
                //   fontWeight: FontWeight.bold,
                // ),),
                // SizedBox(height: 20,),
                Text("Update details of the user : ",style: TextStyle(
                  fontSize: 18,
                  //fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),),
                SizedBox(height: 30,),

                DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    iconStyleData: IconStyleData(
                      iconSize: 30,
                    ),
                    isExpanded: true,
                    hint: Text(
                      'Select User Barcode ID',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    items: barcodelist
                        .map((String barcodelist) => DropdownMenuItem<String>(
                      value: barcodelist,
                      child: Text(
                        barcodelist,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ))
                        .toList(),
                    value: Barcode,
                    onChanged: (String? value) {
                      setState(() {
                        Barcode = value;
                      });
                    },

                    buttonStyleData:  ButtonStyleData(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black54,

                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      height: 65,
                      width: MediaQuery.of(context).size.width-35,
                    ),
                    dropdownStyleData: const DropdownStyleData(
                      maxHeight: 200,
                    ),
                    menuItemStyleData: MenuItemStyleData(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      //customHeights: _getCustomItemsHeights(),
                    ),

                    dropdownSearchData: DropdownSearchData(
                      searchController: _barcodeid,
                      searchInnerWidgetHeight: 75,
                      searchInnerWidget: Container(
                        height: 75,
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 4,
                          right: 8,
                          left: 8,
                        ),
                        child: TextFormField(
                          expands: true,
                          maxLines: null,
                          controller: _barcodeid,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            hintText: 'Search for barcode...',
                            hintStyle: const TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      searchMatchFn: (item, searchValue) {
                        return item.value.toString().contains(searchValue);
                      },
                    ),
                    //This to clear the search value when you close the menu
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        _barcodeid.clear();

                      }
                    },

                  ),
                ),
                SizedBox(height: 18,),
                TextField(
                  controller: _nameController,
                  onChanged: (value){
                    validname(value);
                  },
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z\\s]+'))],
                  keyboardType: TextInputType.name,
                  enableSuggestions: true,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: 'Sundar Pichai',
                    errorText: _nameerror,
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 18,),
                TextField(
                  controller: _phoneController,
                  onChanged: (value){validphone(value);},
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.phone,
                  enableSuggestions: true,
                  decoration: InputDecoration(
                    labelText: 'Number',
                    hintText: '7069402000',
                    errorText: _phonerror,
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(10),FilteringTextInputFormatter.digitsOnly],
                ),
                SizedBox(height: 18,),

                TextField(
                  controller: _emailController,
                  onChanged: (value){validmail(value);},
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  enableSuggestions: true,
                  decoration: InputDecoration(
                    labelText: 'Email-ID',
                    hintText: 'sundar@gmail.com',
                    errorText: _emailerror,
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 18,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        iconStyleData: IconStyleData(
                          iconSize: 30,
                        ),
                        isExpanded: true,
                        hint: Text(
                          'Select User Type',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        items: type
                            .map((String type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ))
                            .toList(),
                        value: userType,
                        onChanged: (String? value) {
                          setState(() {
                            userType = value;
                          });
                        },

                        buttonStyleData:  ButtonStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black54,

                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          height: 65,
                          width: MediaQuery.of(context).size.width-35,
                        ),
                        dropdownStyleData: const DropdownStyleData(
                          maxHeight: 200,
                        ),
                        menuItemStyleData: MenuItemStyleData(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          //customHeights: _getCustomItemsHeights(),
                        ),

                      ),
                    ),
                  ],
                ),


                Visibility(
                    visible: (userType != null && (userType!.compareTo('Sub admin')==0 || userType!.compareTo('Admin')==0)),
                    child: SizedBox(height: 18,)
                ),

                Visibility(
                  visible: (userType != null && (userType!.compareTo('Sub admin')==0 || userType!.compareTo('Admin')==0)),
                  child: TextField(
                    controller: _passController,
                    // onChanged: (value){validpass(value);},
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
                        icon: Icon(_passinvis ? Icons.visibility_off : Icons.visibility),
                        onPressed: (){
                          setState(() {
                            _passinvis = ! _passinvis;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Visibility(
                    visible: (userType != null && (userType!.compareTo('Sub admin')==0 || userType!.compareTo('Admin')==0)),
                    child: SizedBox(height: 18,)),

                Visibility(
                  visible: (userType != null && (userType!.compareTo('Sub admin')==0 || userType!.compareTo('Admin')==0)),
                  child: TextField(
                    controller: _confirmpassController,
                    //onChanged: (value){validconfirmpass(value, _passController.text);},
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _conpassinvis,
                    obscuringCharacter: '*',
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      errorText: _conpaserror,
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_conpassinvis ? Icons.visibility_off : Icons.visibility),
                        onPressed: (){
                          setState(() {
                            _conpassinvis = ! _conpassinvis;
                          });
                        },
                      ),
                    ),
                  ),
                ),


                SizedBox(height: 30,),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  child: ElevatedButton.icon(
                      icon: Icon(Icons.update),
                      onPressed: () async {
                        try{
                          final dio = Dio();
                          var response = await dio.post("https://www.instagram.com");
                          validname(_nameController.text);
                          validbarcode(Barcode);
                          validutype(userType);
                          validphone(_phoneController.text);
                          validmail(_emailController.text);
                          _emailerror =
                              (EmailValidator.validate(_emailController.text))
                                  ? null
                                  : 'Please enter valid email';
                          _phonerror = (_phoneController.text.length != 10)
                              ? '10 digits required.'
                              : null;

                          if ((userType != null) &&
                              userType!.compareTo('Member') != 0) {
                            validconfirmpass(_confirmpassController.text,
                                _passController.text);
                            validpass(_passController.text);
                          }

                          if ((userType != null) &&
                              (userType!.compareTo('Member') == 0) &&
                              (_nameerror == null) &&
                              (_phonerror == null) &&
                              (_emailerror == null) &&
                              (_barcodeerror == null) &&
                              (_utypeerror == null)) {
                            UpdateUser(
                                Barcode!,
                                _nameController.text,
                                _phoneController.text,
                                _emailController.text,
                                -1,
                                null);

                            var sb = SnackBar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.background,
                              content: Container(
                                padding: EdgeInsets.all(16),
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
                                ),
                                child: Center(
                                  child: Text(
                                    "User Updated :)",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              duration: Duration(seconds: 3),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(sb);

                            Timer(Duration(milliseconds: 3500), () {
                              Navigator.pop(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        HomePage(title: "Barcode Scanner")),
                              );
                            });
                          } else if ((_passerror == null) &&
                              (_conpaserror == null) &&
                              (_nameerror == null) &&
                              (_phonerror == null) &&
                              (_emailerror == null) &&
                              (_barcodeerror == null) &&
                              (_utypeerror == null)) {
                            if (userType!.compareTo('Admin') == 0)
                              UpdateUser(
                                  Barcode!,
                                  _nameController.text,
                                  _phoneController.text,
                                  _emailController.text,
                                  1,
                                  _passController.text);
                            else if (userType!.compareTo('Sub admin') == 0)
                              UpdateUser(
                                  Barcode!,
                                  _nameController.text,
                                  _phoneController.text,
                                  _emailController.text,
                                  0,
                                  _passController.text);

                            var sb = SnackBar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.background,
                              content: Container(
                                padding: EdgeInsets.all(16),
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
                                ),
                                child: Center(
                                  child: Text(
                                    "User Details Updated :)",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              duration: Duration(seconds: 3),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(sb);

                            Timer(Duration(milliseconds: 3500), () {
                              Navigator.pop(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        HomePage(title: "Barcode HomePage")),
                              );
                            });
                          } else if (_utypeerror != null) {
                            var sb = SnackBar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.background,
                              content: Container(
                                padding: EdgeInsets.all(16),
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Color(0xFFC72C41),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
                                ),
                                child: Center(
                                  child: Text(
                                    "UserType Missing!!",
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

                          setState(() {});
                        }
                        catch (e){
                          EasyLoading.showError('No Internet Connection !',duration: Duration(seconds: 4),dismissOnTap: false,);
                        }
                      },
                      label: Text('Update',
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
    );
  }
}
