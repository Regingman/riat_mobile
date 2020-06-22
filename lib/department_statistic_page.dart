import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_first_flutter_project/views/home.dart';
import 'package:my_first_flutter_project/views/info_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'department_statictis_page_detail.dart';
import 'main.dart';
import 'models/statistic.dart';

class DepartmentStatisticPage extends StatefulWidget {
  @override
  _DepartmentStatisticPage createState() => _DepartmentStatisticPage();
}

class _DepartmentStatisticPage extends State<DepartmentStatisticPage> {
  List<Statistic> statistic = new List<Statistic>();

  List<Statistic> statisticFailed = new List<Statistic>();
  List<Statistic> statisticSucces = new List<Statistic>();
  List<Statistic> statisticInProgress = new List<Statistic>();
  bool _isLoading = true;

  List<FlSpot> allSpot = new List<FlSpot>();
  List<FlSpot> fSpot = new List<FlSpot>();
  List<FlSpot> sSpot = new List<FlSpot>();
  List<FlSpot> ipSpot = new List<FlSpot>();

  _generateData() async {
    var taskList = List<Statistic>();
    var taskListF = List<Statistic>();
    var taskListS = List<Statistic>();
    var taskListP = List<Statistic>();

    String url = RiatMobile.getUrl;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString('token');
    int userId = sharedPreferences.getInt('user');
    final responseTask = await http.get('$url/listOfEmployee/$userId/all',
        headers: {"Authorization": "Bearer_$token"});
    if (responseTask.statusCode == 200) {
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
      statistic = taskList;
      statisticFailed = taskListF;
      statisticSucces = taskListS;
      statisticInProgress = taskListP;
      _isLoading = false;
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

  @override
  void initState() {
    super.initState();
    _generateData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop();
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => new Home()));
      },
      child: Scaffold(
        appBar: buildAppBar(context),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Ведомость задач отдела за месяц'.toUpperCase(),
                          style: TextStyle(
                            color: Color.fromRGBO(50, 65, 85, 1),
                            fontFamily: 'Bebas',
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left: 20, top: 20, right: 20, bottom: 40),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(50, 65, 85, 0.9),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                    ),
                    child: Wrap(
                      runSpacing: 20,
                      spacing: 20,
                      children: <Widget>[
                        InfoCard(
                          title: "Всего",
                          iconColor: Color(0xFFFF8C00),
                          lineColor: Colors.white,
                          effectedNum: statistic.length,
                          flSpot: allSpot,
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
                          lineColor: Colors.red,
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
                  ),
                ],
              ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (BuildContext context) => new Home()));
          }),
      title: Text("Ведомость задач"),
    );
  }
}
