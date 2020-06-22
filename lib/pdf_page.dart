import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

import 'domain/Task.dart';
import 'domain/UserMain.dart';
import 'main.dart';

import 'package:http/http.dart' as http;

class PdfPage extends StatefulWidget {
  @override
  _PdfPage createState() => new _PdfPage();
}

class _PdfPage extends State<PdfPage> {
  ThemeData myTheme;
  //String outputT = utf8.decode(latin1.encode(_header), allowMalformed: true);
  final pdf = pw.Document();
  List<List<String>> salidas = new List();
  List<Task> task = new List<Task>();

  String _fio, _countTask;
  //static const _header = 'Отчет за месяц';

  @override
  void initState() {
    _loadCC();
    super.initState();
  }

  int countMax, count = 0;
  UserMain user = new UserMain();

  _loadCC() async {
    String url = CCTracker.getUrl;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString('token');
    int userId = sharedPreferences.getInt('user');
    final responseTask = await http.get('$url/task/employee/1/active',
        headers: {"Authorization": "Bearer_$token"});
    if (responseTask.statusCode == 200) {
      var taskMaps = jsonDecode(responseTask.body);
      var taskList = List<Task>();
      for (var taskMap in taskMaps) {
        taskList.add(Task.fromJson(taskMap));
      }
      setState(() {
        task = taskList;
        // _isLoading = false;
      });

      int userId = sharedPreferences.getInt('orderUser');
      final responseUser = await http.get('$url/api/v1/users/$userId',
          headers: {"Authorization": "Bearer_$token"});
      if (responseUser.statusCode == 200) {
        var userMaps = jsonDecode(responseUser.body);
        var tempUser = UserMain.fromJson(userMaps);
        setState(() {
          user = tempUser;
        });
      }
    }
    salidas.add(<String>['№', 'Название', 'Статус', 'Время завершения']);
    String an1 = "Завершено";
    String an2 = "В процессе";
    String an3 = "Невыполенно";
    String an;
    for (var indice = 0; indice < task.length; indice++) {
      if (task[indice].taskStatusId == 2) {
        count++;
        an = an1;
      } else if (task[indice].taskStatusId == 1) {
        an = an2;
      } else {
        an = an3;
      }
      List<String> recind = <String>[
        (indice + 1).toString(),
        task[indice].name,
        an,
        task[indice].updateDate.toString()
      ];
      salidas.add(recind);
    }
  }

  writeOnPdf() async {
    /*final Uint8List fontData = File('cm_sans_serif_2012.ttf').readAsBytesSync();
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());
*/

    String month;
    if (DateTime.now().month == 1) {
      month = "Январь";
    } else if (DateTime.now().month == 2) {
      month = "Февраль";
    } else if (DateTime.now().month == 3) {
      month = "Март";
    } else if (DateTime.now().month == 4) {
      month = "Апрель";
    } else if (DateTime.now().month == 5) {
      month = "Май";
    } else if (DateTime.now().month == 6) {
      month = "Июнь";
    } else if (DateTime.now().month == 7) {
      month = "Июль";
    } else if (DateTime.now().month == 8) {
      month = "Август";
    } else if (DateTime.now().month == 9) {
      month = "Сентябрь";
    } else if (DateTime.now().month == 10) {
      month = "Октябрь";
    } else if (DateTime.now().month == 11) {
      month = "Ноябрь";
    } else if (DateTime.now().month == 12) {
      month = "Декабрь";
    }

    var data = await rootBundle.load('assets/fonts/second.ttf');
    var myFont = pw.Font.ttf(data);
    var myStule = pw.TextStyle(font: myFont);
    String _head = "Сеитбек уулу Атай";
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a5,
      margin: pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return <pw.Widget>[
          pw.Header(
            level: 0,
            child: pw.Text(
              'Отчет за $month',
              style: myStule, //pw.TextStyle(font: ttf),
            ),
          ),
          pw.Paragraph(text: "Сотрудник", style: myStule),
          pw.Paragraph(
              text: "${user.lastName} ${user.lastName}", style: myStule),
          pw.Table.fromTextArray(
              context: context,
              data: salidas,
              cellStyle: myStule,
              headerStyle: myStule,
              oddCellStyle: myStule),
          pw.Header(level: 2, child: pw.Text("В результате", style: myStule)),
          pw.Paragraph(
              text:
                  "Всего задач в течении месяца завершено $count из ${salidas.length - 1}",
              style: myStule),
        ];
      },
    ));
  }

  Future savePdf() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();

    String documentPath = documentDirectory.path;

    File file = File("$documentPath/example.pdf");

    file.writeAsBytesSync(pdf.save());
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "PDF Flutter",
          style: TextStyle(fontFamily: 'Ramon'),
        ),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "PDF TUTORIAL",
              style: TextStyle(fontSize: 34),
            )
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          writeOnPdf();
          await savePdf();

          Directory documentDirectory =
              await getApplicationDocumentsDirectory();

          String documentPath = documentDirectory.path;

          String fullPath = "$documentPath/example.pdf";

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PdfPreviewScreen(
                        path: fullPath,
                      )));
        },
        child: Icon(Icons.save),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class PdfPreviewScreen extends StatelessWidget {
  PdfPreviewScreen({this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
      path: path,
    );
  }
}
