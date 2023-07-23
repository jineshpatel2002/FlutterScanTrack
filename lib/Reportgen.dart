import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class reportgen extends StatefulWidget {
  const reportgen({super.key});

  @override
  State<reportgen> createState() => _reportgenState();
}

class _reportgenState extends State<reportgen> {

  late DateTime now,todaydate;
  DateTime? pickedDateS,pickedDateE;
  String? _sdateerror,_edateerror;
  var number =0;
  @override
  void initState() {
    now = DateTime.now();
    todaydate = DateTime(now.year,now.month,now.day);
    EasyLoading.init();
    super.initState();
    setState(() {
    });
  }
  @override
  void dispose() {
    super.dispose();
  }

  TextEditingController dateInputControllerS = TextEditingController();
  TextEditingController dateInputControllerE = TextEditingController();

  void validsdate(String val){
    setState(() {
      _sdateerror = val.isEmpty ? 'Start date is required.':null;
    });
  }

  void validedate(String val){
    setState(() {
      _edateerror = val.isEmpty ? 'End date is required.':null;
    });
  }


  Future<Uint8List> createHelloWorld() {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text("Hello World"),
          );
        },
      ),
    );

    return pdf.save();
  }


  Future<Uint8List> createReport(List<List<dynamic>> Tdata) {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context){
          return [
            pw.TableHelper.fromTextArray(
              headers : ['Sr no.','Barcode Id','Name','Mobile','Attendance','Date'],
                data: Tdata,
            )
          ];
    }
      )
    );

    return pdf.save();
  }


  Future<void> savePdfFile(String fileName, Uint8List byteList) async {
    final output = await getTemporaryDirectory();
    var filePath = "${output.path}/$fileName.pdf";
    final file = File(filePath);
    await file.writeAsBytes(byteList);
    await OpenFile.open(filePath);
    EasyLoading.dismiss();
  }


  Future<void> attendReport(String sdate,String edate) async { // New user entry
    final dio = Dio();
    var formData = FormData.fromMap({
      'method': 'attendReport',
      'sdate' : sdate,
      'edate' : edate,

    });
    try{
      var response = await dio.post("https://firstflutterapp.000webhostapp.com/myfirstflutter/barcodedb.php", data: formData);
      String responseBody = response.data;
      var stat = json.decode(responseBody)['status'];

      if(stat=="1"){
        var msg = json.decode(responseBody)['main_data'] ;
        print(msg.runtimeType);

        var ind =1;
        for(final row in msg){
          row['Sr no.'] = ind++;
          if(row['Attendance']=="1")row['Attendance'] = 'Present';
          else if(row['Attendance']=="0")row['Attendance'] = 'Absent';

        }
        final DATA = msg.map<List<dynamic>>((item) {
          return [
            item['Sr no.'],
            item['Barcode Id'],
            item['Name'],
            item['Mobile'],
            item['Attendance'],
            item['Date'],
          ];
        }).toList();
        final data = await createReport(DATA);
        savePdfFile("report_$number", data);
        number++;
      }
      else{
        print("^^^^^^^^^^^^^^^^^^^^ : "+stat);
      }
    }
    catch (e){
      EasyLoading.dismiss();
      EasyLoading.showError('Connection Error!',duration: Duration(seconds: 4),dismissOnTap: true,);
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Report'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Choose Start Date : "),
              SizedBox(height: 30,),

              TextField(
                decoration:  InputDecoration(
                  errorText: _sdateerror,
                  hintText: 'Date',
                   suffixIcon: (pickedDateS==null)?Icon(Icons.calendar_month,size: 27,):Icon(FontAwesomeIcons.calendarCheck),
                   border: OutlineInputBorder(),
                ),
                controller: dateInputControllerS,
                readOnly: true,
                onTap: () async {
                 pickedDateS = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2023,06,20),
                      lastDate: todaydate
                  );
                  setState(() {
                    this.pickedDateS = pickedDateS;
                  });
                  if (pickedDateS != null) {
                    dateInputControllerS.text ="${pickedDateS!.year}-${pickedDateS!.month}-${pickedDateS!.day}";
                  }
                },
              ),
              
              SizedBox(height: 60,),
              
              Text("Choose End Date :"),
              SizedBox(height: 30,),

              TextField(
                decoration:  InputDecoration(
                  errorText: _edateerror,
                  hintText: 'Date',
                  suffixIcon: (pickedDateE==null)?Icon(Icons.calendar_month,size: 27,):Icon(FontAwesomeIcons.calendarCheck),
                  border: OutlineInputBorder(),
                ),
                controller: dateInputControllerE,
                readOnly: true,
                onTap: () async {
                  pickedDateE = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2023,06,20),
                      lastDate: todaydate
                  );
                  setState(() {
                    this.pickedDateE = pickedDateE;
                  });
                  if (pickedDateE != null) {
                    dateInputControllerE.text ="${pickedDateE!.year}-${pickedDateE!.month}-${pickedDateE!.day}";
                  }
                },
              ),

              SizedBox(height: 45,),

              ElevatedButton(
                  onPressed: () async{
                    try{
                      final dio = Dio();
                      var response = await dio.post("https://www.instagram.com");
                      validedate(dateInputControllerE.text);
                      validsdate(dateInputControllerS.text);
                      if (_sdateerror == null && _edateerror == null) {
                        EasyLoading.show(status: 'Generating Report...');
                        attendReport(dateInputControllerS.text,
                            dateInputControllerE.text);
                      }
                    }
                    catch (e){
                      EasyLoading.showError('No Internet Connection !',duration: Duration(seconds: 4),dismissOnTap: false,);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("   PDF   ",
                      style: TextStyle(
                        fontSize: 15,
                      ),),
                  )
              )
              
            ],

          ),
        ),
      ),
    );
  }
}
