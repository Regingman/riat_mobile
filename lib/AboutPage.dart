import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_first_flutter_project/CCList.dart';
import 'package:my_first_flutter_project/models/statistic.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import 'main.dart';

class AboutPage extends StatefulWidget {
  final Widget child;

  AboutPage({Key key, this.child}) : super(key: key);

  _AboutPage createState() => _AboutPage();
}

class _AboutPage extends State<AboutPage> {
  List<Statistic> statistic = new List<Statistic>();
  List<charts.Series<Pollution, String>> _seriesData;
  List<charts.Series<Task, String>> _seriesPieData;
  List<charts.Series<Sales, int>> _seriesLineData;

  _generateData() async {
    String url = CCTracker.getUrl;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString('token');
    int userId = sharedPreferences.getInt('user');
    final responseTask = await http.get('$url/listOfEmployee/$userId',
        headers: {"Authorization": "Bearer_$token"});
    //print(responseTask.statusCode);
    if (responseTask.statusCode == 200) {
      //print(responseTask.body);
      var taskMaps = jsonDecode(responseTask.body);
      var taskList = List<Statistic>();
      for (var taskMap in taskMaps) {
        taskList.add(Statistic.fromJson(taskMap));
      }
      setState(() {
        statistic = taskList;
      });
    }

    int processCount = 0;
    int activeCount = 0;
    int inactiveCount = 0;

    for (var stat in statistic) {
      if (stat.date.month == DateTime.now().month) {
        if (stat.name.contains("В процессе")) {
          processCount++;
        } else if (stat.name.contains("Завершено")) {
          activeCount++;
        } else {
          inactiveCount++;
        }
      }
    }
   // print(processCount);
    //print(activeCount);
    //print(inactiveCount);
    var data1, data2, data3;
    setState(() {
      data1 = [
        new Pollution(1980, 'Выполненные', activeCount),
      ];
      data2 = [
        new Pollution(1980, 'В процессе', processCount),
      ];
      data3 = [
        new Pollution(1985, 'Невыполненные', inactiveCount),
      ];
    });

    int summ = activeCount + processCount + inactiveCount;

    var piedata = [
      new Task('Выполненные', (activeCount * 100 / summ), Color(0xff3366cc)),
      new Task('В процессе', (processCount * 100 / summ), Color(0xff990099)),
      new Task(
          'Невыполненные', (inactiveCount * 100 / summ), Color(0xff109618)),
    ];

    var linesalesdata = [
      new Sales(1, 0),
      new Sales(5, 0),
      new Sales(10, 0),
      new Sales(15, 0),
      new Sales(20, 0),
      new Sales(25, 0),
      new Sales(30, 0),
    ];
    var linesalesdata1 = [
      new Sales(1, 0),
      new Sales(5, 0),
      new Sales(10, 0),
      new Sales(15, 1),
      new Sales(20, 1),
      new Sales(25, 1),
      new Sales(30, 2),
    ];

    var linesalesdata2 = [
      new Sales(1, 1),
      new Sales(5, 2),
      new Sales(10, 2),
      new Sales(15, 1),
      new Sales(20, 2),
      new Sales(25, 3),
      new Sales(30, 3),
    ];

    _seriesData.add(
      charts.Series(
        domainFn: (Pollution pollution, _) => pollution.place,
        measureFn: (Pollution pollution, _) => pollution.quantity,
        id: '2017',
        data: data1,
        fillPatternFn: (_, __) => charts.FillPatternType.solid,
        fillColorFn: (Pollution pollution, _) =>
            charts.ColorUtil.fromDartColor(Color(0xff990099)),
      ),
    );

    _seriesData.add(
      charts.Series(
        domainFn: (Pollution pollution, _) => pollution.place,
        measureFn: (Pollution pollution, _) => pollution.quantity,
        id: '2018',
        data: data2,
        fillPatternFn: (_, __) => charts.FillPatternType.solid,
        fillColorFn: (Pollution pollution, _) =>
            charts.ColorUtil.fromDartColor(Color(0xff109618)),
      ),
    );

    _seriesData.add(
      charts.Series(
        domainFn: (Pollution pollution, _) => pollution.place,
        measureFn: (Pollution pollution, _) => pollution.quantity,
        id: '2019',
        data: data3,
        fillPatternFn: (_, __) => charts.FillPatternType.solid,
        fillColorFn: (Pollution pollution, _) =>
            charts.ColorUtil.fromDartColor(Color(0xffff9900)),
      ),
    );

    _seriesPieData.add(
      charts.Series(
        domainFn: (Task task, _) => task.task,
        measureFn: (Task task, _) => task.taskvalue,
        colorFn: (Task task, _) =>
            charts.ColorUtil.fromDartColor(task.colorval),
        id: 'Air Pollution',
        data: piedata,
        labelAccessorFn: (Task row, _) => '${row.taskvalue}',
      ),
    );

    _seriesLineData.add(
      charts.Series(
        colorFn: (__, _) => charts.ColorUtil.fromDartColor(Color(0xff990099)),
        id: 'Air Pollution',
        data: linesalesdata,
        domainFn: (Sales sales, _) => sales.yearval,
        measureFn: (Sales sales, _) => sales.salesval,
      ),
    );
    _seriesLineData.add(
      charts.Series(
        colorFn: (__, _) => charts.ColorUtil.fromDartColor(Color(0xff109618)),
        id: 'Air Pollution',
        data: linesalesdata1,
        domainFn: (Sales sales, _) => sales.yearval,
        measureFn: (Sales sales, _) => sales.salesval,
      ),
    );
    _seriesLineData.add(
      charts.Series(
        colorFn: (__, _) => charts.ColorUtil.fromDartColor(Color(0xffff9900)),
        id: 'Air Pollution',
        data: linesalesdata2,
        domainFn: (Sales sales, _) => sales.yearval,
        measureFn: (Sales sales, _) => sales.salesval,
      ),
    );
    _isLoading = false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _seriesData = List<charts.Series<Pollution, String>>();
    _seriesPieData = List<charts.Series<Task, String>>();
    _seriesLineData = List<charts.Series<Sales, int>>();
    _generateData();
  }

  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromRGBO(50, 65, 85, 1),
            //backgroundColor: Color(0xff308e1c),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) => new CCList()));
              },
            ),
            bottom: TabBar(
              indicatorColor: Color(0xff9962D0),
              tabs: [
                Tab(
                  icon: Icon(FontAwesomeIcons.solidChartBar),
                ),
                Tab(icon: Icon(FontAwesomeIcons.chartPie)),
                Tab(icon: Icon(FontAwesomeIcons.chartLine)),
              ],
            ),
            title: Text('Ведомость задач'),
          ),
          body: _isLoading
              ? Center(child: CircularProgressIndicator())
              : TabBarView(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Container(
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Text(
                                'Задачи на текущий месяц',
                                style: TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: charts.BarChart(
                                  _seriesData,
                                  animate: true,
                                  barGroupingType:
                                      charts.BarGroupingType.grouped,
                                  //behaviors: [new charts.SeriesLegend()],
                                  animationDuration: Duration(seconds: 2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Container(
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Text(
                                'Все задачи за текущий месяц',
                                style: TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Expanded(
                                child: charts.PieChart(_seriesPieData,
                                    animate: true,
                                    animationDuration: Duration(seconds: 3),
                                    behaviors: [
                                      new charts.DatumLegend(
                                        outsideJustification: charts
                                            .OutsideJustification.endDrawArea,
                                        horizontalFirst: false,
                                        desiredMaxRows: 2,
                                        cellPadding: new EdgeInsets.only(
                                            right: 4.0, bottom: 4.0),
                                        entryTextStyle: charts.TextStyleSpec(
                                            color: charts.MaterialPalette.purple
                                                .shadeDefault,
                                            fontFamily: 'Georgia',
                                            fontSize: 11),
                                      )
                                    ],
                                    defaultRenderer:
                                        new charts.ArcRendererConfig(
                                            arcWidth: 100,
                                            arcRendererDecorators: [
                                          new charts.ArcLabelDecorator(
                                              labelPosition: charts
                                                  .ArcLabelPosition.inside)
                                        ])),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Container(
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Text(
                                'Задачи за текущий месяц',
                                style: TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: charts.LineChart(_seriesLineData,
                                    defaultRenderer:
                                        new charts.LineRendererConfig(
                                            includeArea: true, stacked: true),
                                    animate: true,
                                    animationDuration: Duration(seconds: 3),
                                    behaviors: [
                                      new charts.ChartTitle('Дни',
                                          behaviorPosition:
                                              charts.BehaviorPosition.bottom,
                                          titleOutsideJustification: charts
                                              .OutsideJustification
                                              .middleDrawArea),
                                      new charts.ChartTitle('Кол-во',
                                          behaviorPosition:
                                              charts.BehaviorPosition.start,
                                          titleOutsideJustification: charts
                                              .OutsideJustification
                                              .middleDrawArea),
                                      new charts.ChartTitle(
                                        'Кол-во',
                                        behaviorPosition:
                                            charts.BehaviorPosition.end,
                                        titleOutsideJustification: charts
                                            .OutsideJustification
                                            .middleDrawArea,
                                      )
                                    ]),
                              ),
                            ],
                          ),
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

class Pollution {
  String place;
  int year;
  int quantity;

  Pollution(this.year, this.place, this.quantity);
}

class Task {
  String task;
  double taskvalue;
  Color colorval;

  Task(this.task, this.taskvalue, this.colorval);
}

class Sales {
  int yearval;
  int salesval;

  Sales(this.yearval, this.salesval);
}
