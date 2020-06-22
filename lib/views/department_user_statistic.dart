import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_first_flutter_project/All_taskPage.dart';
import 'package:my_first_flutter_project/domain/UserMain.dart';
import 'package:my_first_flutter_project/models/statistic.dart';
import 'package:my_first_flutter_project/pdf_page.dart';
import 'package:my_first_flutter_project/views/home.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../department_statictis_page_detail.dart';
import '../main.dart';
import 'info_card.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String url = CCTracker.getUrl;
  String token;
  List<Statistic> statistic = new List<Statistic>();

  List<Statistic> statisticFailed = new List<Statistic>();
  List<Statistic> statisticSucces = new List<Statistic>();
  List<Statistic> statisticInProgress = new List<Statistic>();

  bool _isLoading = true;
  UserMain user = new UserMain(id: 1, name: "", telephon: "");
  double procent;
  List<FlSpot> allSpot = new List<FlSpot>();
  List<FlSpot> fSpot = new List<FlSpot>();
  List<FlSpot> sSpot = new List<FlSpot>();
  List<FlSpot> ipSpot = new List<FlSpot>();

  _generateData() async {
    var taskList = List<Statistic>();
    var taskListF = List<Statistic>();
    var taskListS = List<Statistic>();
    var taskListP = List<Statistic>();

    String url = CCTracker.getUrl;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString('token');
    int userId = sharedPreferences.getInt('orderUser');
    final responseTask = await http.get('$url/listOfEmployee/$userId',
        headers: {"Authorization": "Bearer_$token"});
    //print(responseTask.statusCode);
    if (responseTask.body == '') {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Ошибка!"),
              content:
                  Text("Задачи отсутствуют, формирование ведомости невозможно"),
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
    if (responseTask.statusCode == 200) {
      //print(responseTask.body);
      var taskMaps = jsonDecode(responseTask.body);

      for (var taskMap in taskMaps) {
        taskList.add(Statistic.fromJson(taskMap));
      }
    }

    for (var stat in taskList) {
      if (stat.date.month == DateTime.now().month) {
        if (stat.name.contains("В процессе")) {
          taskListP.add(stat);
        } else if (stat.name.contains("Завершено")) {
          taskListS.add(stat);
        } else {
          taskListF.add(stat);
        }
      }
    }

    setState(() {
      procent = (taskListS.length * 100) / taskList.length;
      statistic = taskList;
      statisticFailed = taskListF;
      statisticSucces = taskListS;
      statisticInProgress = taskListP;
      //_isLoading = false;
    });

    int day = DateTime.now().day;
    int summ = 0;

    for (int i = 1; i <= day; i++) {
      for (int j = 0; j < statistic.length; j++) {
        if (statistic[j].date.day == i) summ++;
      }
      allSpot.add(new FlSpot(i.toDouble(), summ.toDouble()));
      summ = 0;
    }

    for (int i = 1; i <= day; i++) {
      for (int j = 0; j < statisticFailed.length; j++) {
        if (statistic[j].date.day == i) summ++;
      }
      fSpot.add(new FlSpot(i.toDouble(), summ.toDouble()));
      summ = 0;
    }

    for (int i = 1; i <= day; i++) {
      for (int j = 0; j < statisticInProgress.length; j++) {
        if (statistic[j].date.day == i) summ++;
      }
      ipSpot.add(new FlSpot(i.toDouble(), summ.toDouble()));
      summ = 0;
    }

    for (int i = 1; i <= day; i++) {
      for (int j = 0; j < statisticSucces.length; j++) {
        if (statistic[j].date.day == i) summ++;
      }
      sSpot.add(new FlSpot(i.toDouble(), summ.toDouble()));
      summ = 0;
    }
  }

  _loadUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    token = sharedPreferences.getString('token');
    int userId = sharedPreferences.getInt('orderUser');
    final responseTask = await http.get('$url/api/v1/users/$userId',
        headers: {"Authorization": "Bearer_$token"});
    if (responseTask.statusCode == 200) {
      var userMaps = jsonDecode(responseTask.body);
      var tempUser = UserMain.fromJson(userMaps);
      setState(() {
        user = tempUser;
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _generateData();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : WillPopScope(
            onWillPop: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) => new Home()));
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
                              builder: (BuildContext context) => new Home()));
                    }),
                elevation: 0,
                titleSpacing: 0,
                backgroundColor: Color.fromRGBO(50, 65, 85, 1),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 30,
                      height: 50,
                      margin: EdgeInsets.only(right: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.network('$url/img/${user.fileName}',
                            headers: {"Authorization": "Bearer_$token"}),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${user.firstName} ${user.lastName}',
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new AllTaskPage()));
                    },
                    child: Stack(
                      overflow: Overflow.visible,
                      children: <Widget>[
                        Container(
                          width: 20,
                          child: Icon(
                            Icons.assignment,
                            color: Theme.of(context).accentColor,
                            size: 35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: <Widget>[
                              Text(
                                'Номер телефона'.toUpperCase(),
                                style: TextStyle(
                                  color: Color.fromRGBO(50, 65, 85, 1),
                                  fontFamily: 'Bebas',
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${user.telephon}',
                                style: TextStyle(
                                  color: Color.fromRGBO(50, 65, 85, 0.9),
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Позиция'.toUpperCase(),
                                style: TextStyle(
                                  color: Color.fromRGBO(50, 65, 85, 1),
                                  fontFamily: 'Bebas',
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${user.positionName}',
                                style: TextStyle(
                                  color: Color.fromRGBO(50, 65, 85, 0.9),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 25,
                          color: Colors.grey[300],
                        ),
                        Container(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Всего задач',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${statistic.length}',
                                            style: TextStyle(
                                              fontSize: 20,
                                              color:
                                                  Theme.of(context).accentColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[],
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      'Выполненных задач в %',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                '${procent.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 20,
                                              color:
                                                  Theme.of(context).accentColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' %',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Divider(
                          height: 25,
                          color: Colors.grey[300],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                        ),
                        Wrap(
                          runSpacing: 20,
                          spacing: 20,
                          children: <Widget>[
                            InfoCard(
                              title: "Всего",
                              iconColor: Color(0xFFFF8C00),
                              lineColor: Colors.white,
                              flSpot: allSpot,
                              effectedNum: statistic.length,
                              press: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return DepartmentStatisticPageDetail(
                                        title: "Всего",
                                        statistic: statistic,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            InfoCard(
                              title: "Завершено",
                              iconColor: Color(0xFFFF2D55),
                              lineColor: Colors.green,
                              flSpot: sSpot,
                              effectedNum: statisticSucces.length,
                              press: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return DepartmentStatisticPageDetail(
                                        title: "Завершено",
                                        statistic: statisticSucces,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            InfoCard(
                              title: "В процессе",
                              iconColor: Color(0xFF50E3C2),
                              lineColor: Colors.yellowAccent,
                              flSpot: ipSpot,
                              effectedNum: statisticInProgress.length,
                              press: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return DepartmentStatisticPageDetail(
                                        title: "В процессе",
                                        statistic: statisticInProgress,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            InfoCard(
                              title: "Провалено",
                              iconColor: Color(0xFF5856D6),
                              lineColor: Colors.redAccent,
                              flSpot: fSpot,
                              effectedNum: statisticFailed.length,
                              press: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return DepartmentStatisticPageDetail(
                                        title: "Провалено",
                                        statistic: statisticFailed,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
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
