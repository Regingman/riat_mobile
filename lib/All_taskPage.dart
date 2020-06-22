import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_first_flutter_project/pdf_page.dart';
import 'package:my_first_flutter_project/views/department_user_statistic.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'CCData.dart';
import 'package:pdf/widgets.dart' as pw;
import 'domain/Task.dart';
import 'domain/UserMain.dart';
import 'main.dart';

class AllTaskPage extends StatefulWidget {
  @override
  _AllTaskPage createState() => new _AllTaskPage();
}

class _AllTaskPage extends State<AllTaskPage> {
  List<Task> task = [];
  List<CCData> data = [];
  UserMain user = new UserMain(id: 1, name: "", telephon: "");

  @override
  Widget build(BuildContext context) {
    if (user == null) return null;
    return Container(
      child: WillPopScope(
        onWillPop: () {
          Navigator.of(context).pop();
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) => new Dashboard()));
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (BuildContext context) => new Dashboard()));
                }),
            title: Text("Задачи ${user.firstName}"),
            actions: <Widget>[
              FlatButton(
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
                child: Stack(
                  overflow: Overflow.visible,
                  children: <Widget>[
                    Container(
                      width: 20,
                      child: Icon(
                        Icons.save,
                        color: Theme.of(context).accentColor,
                        size: 35,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          backgroundColor: Theme.of(context).primaryColor,
          body: builds(context),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.check),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Изменение задач"),
                      content: Text("Вы уверене что хотите внести изменения?"),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("Да"),
                          onPressed: () {
                            _taskApp();
                          },
                        ),
                        FlatButton(
                          child: Text("Нет"),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        new AllTaskPage()));
                          },
                        )
                      ],
                    );
                  });
            },
          ),
        ),
      ),
    );
  }

  _loadUser() async {
    String url = CCTracker.getUrl;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString('token');
    int userId = sharedPreferences.getInt('orderUser');
    final responseTask = await http.get('$url/api/v1/users/$userId',
        headers: {"Authorization": "Bearer_$token"});
    if (responseTask.statusCode == 200) {
      var userMaps = jsonDecode(responseTask.body);
      var tempUser = UserMain.fromJson(userMaps);
      setState(() {
        user = tempUser;
      });
    }
  }

  _loadCC() async {
    String url = CCTracker.getUrl;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString('token');
    int userId = sharedPreferences.getInt('orderUser');
    final responseTask = await http.get('$url/task/employee/$userId/active',
        headers: {"Authorization": "Bearer_$token"});
    //print(responseTask.statusCode);

    final responseTaskInv = await http.get(
        '$url/task/employee/$userId/inactive',
        headers: {"Authorization": "Bearer_$token"});
    var taskList = List<Task>();

    if (responseTaskInv.statusCode == 200) {
      var taskInvMaps = jsonDecode(responseTaskInv.body);
      // print(taskInvMaps);
      for (var taskMap in taskInvMaps) {
        taskList.add(Task.fromJson(taskMap));
      }
    }

    if (responseTask.statusCode == 200) {
      //print(responseTask.body);
      var taskMaps = jsonDecode(responseTask.body);

      for (var taskMap in taskMaps) {
        taskList.add(Task.fromJson(taskMap));
      }
    }
    setState(() {
      task = taskList;
    });

    if (task.length==0) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Ошибка!"),
              content: Text("Задачи отсутствуют, формирование отчета невозможно"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Ок"),
                  onPressed: () {
                    return;
                  },
                )
              ],
            );
          });
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
        '${task[indice].updateDate.day}.${task[indice].updateDate.month}.${task[indice].updateDate.year} ${task[indice].updateDate.hour}:${task[indice].updateDate.minute}'
      ];
      salidas.add(recind);
    }
  }

  @override
  void initState() {
    //print("init")
    _loadCC();
    _loadUser();
    super.initState();
  }

  bool checkBoxValue = false;
  Widget builds(BuildContext context) {
    return Container(
      child: Container(
        child: ListView.builder(
            itemCount: task.length,
            itemBuilder: (context, i) {
              return new Dismissible(
                key: new Key(task[i].id.toString()),
                onDismissed: (direction) {
                  remove(i);
                  Scaffold.of(context).showSnackBar(new SnackBar(
                    content: new Text("Задача была удалена"),
                  ));
                },
                child: new Card(
                  elevation: 2.0,
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Container(
                    decoration:
                        BoxDecoration(color: Color.fromRGBO(50, 65, 85, 0.9)),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      leading: Checkbox(
                        value: task[i].taskStatusId == 1 ? false : true,
                        onChanged: (bool value) {
                          setState(() {
                            task[i].taskStatusId = value == true ? 2 : 1;
                            //print(task[i].taskStatusId);
                          });
                        },
                      ),
                      title: Text(
                        task[i].name,
                        style: TextStyle(
                            color: Theme.of(context).textTheme.title.color,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: subTitle(context, task[i]),
                      onTap: () {
                        _task(task[i].id, task[i].taskId);
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(
                            context, '/taskDetailManager');
                      },
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }

  ThemeData myTheme;
  //String outputT = utf8.decode(latin1.encode(_header), allowMalformed: true);
  final pdf = pw.Document();
  List<List<String>> salidas = new List();

  String _fio, _countTask;
  //static const _header = 'Отчет за месяц';

  int countMax, count = 0;

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

    var data = await rootBundle.load('assets/fonts/first.ttf');
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
              text: "${user.lastName} ${user.firstName}", style: myStule),
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

  _task(int id, int subtask) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt("task", id);
    sharedPreferences.setInt('subtask', subtask);
  }

  remove(int i) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String url = CCTracker.getUrl;
    String token = sharedPreferences.getString('token');
    await http.delete('$url/listOfEmployee/${task[i].id}',
        headers: {"Authorization": "Bearer_$token"});
    task.removeAt(i);
  }

  _taskApp() async {
    String url = CCTracker.getUrl;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString('token');
    int userId = sharedPreferences.getInt('orderUser');
    //sharedPreferences.getInt('user');
    for (var tempTask in task) {
      // print(tempTask.taskStatusId);
      await http.post(
          '$url/task/status/${tempTask.taskId}/$userId/${tempTask.taskStatusId}',
          headers: {"Authorization": "Bearer_$token"});
    }
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text("Изменения прошли успешно!"),
            actions: <Widget>[
              FlatButton(
                child: Text("Закрыть"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (BuildContext context) =>
                              new AllTaskPage()));
                },
              )
            ],
          );
        });
  }

  Widget subTitle(BuildContext context, Task task) {
    var color = Colors.grey;
    double indicatorLevel = task.procent;
    if (indicatorLevel < 30 && indicatorLevel > 0) {
      color = Colors.green;
    } else if (indicatorLevel < 60 && indicatorLevel > 31) {
      color = Colors.yellow;
    } else if (indicatorLevel < 101 && indicatorLevel > 61) {
      color = Colors.red;
    }
    return Row(
      children: <Widget>[
        Expanded(
          flex: 6,
          child: LinearProgressIndicator(
            backgroundColor: Theme.of(context).textTheme.title.color,
            value: indicatorLevel,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        /*SizedBox(width: 20),
        Expanded(
            flex: 3,
            child: Text(task.description,
                style:
                    TextStyle(color: Theme.of(context).textTheme.title.color))),
      */
      ],
    );
  }
}
