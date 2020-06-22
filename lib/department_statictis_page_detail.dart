import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_first_flutter_project/models/statistic.dart';
import 'package:my_first_flutter_project/views/weekly_chart.dart';

import 'constants.dart';
import 'department_statistic_page.dart';

class DepartmentStatisticPageDetail extends StatelessWidget {
  final String title;
  final List<Statistic> statistic;

  DepartmentStatisticPageDetail(
      {@required this.title, @required this.statistic});

  List<double> barChartDatas = [0, 0, 0, 0, 0, 0, 0];
  List<String> tempDatas = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"];
  List<String> datas = new List<String>();
  int countInWeek = 0;

  taskUpdate() {
    int oneDay, secondDay, thirdDay, fourthDay, fifthDay, sixthDay, sevenDay;
    oneDay = DateTime.now().day - 6;
    secondDay = DateTime.now().day - 5;
    thirdDay = DateTime.now().day - 4;
    fourthDay = DateTime.now().day - 3;
    fifthDay = DateTime.now().day - 2;
    sixthDay = DateTime.now().day - 1;
    sevenDay = DateTime.now().day;
    int weekDay = DateTime.now().weekday;
    for (int i = weekDay; i < tempDatas.length; i++) {
      datas.add(tempDatas[i]);
    }
    for (int i = 0; i < weekDay; i++) {
      datas.add(tempDatas[i]);
    }

   // print(datas);

    for (var stat in statistic) {
      //print(stat.date.day);
      if (stat.date.day == oneDay) {
        barChartDatas[0] += 1;
        countInWeek++;
      } else if (stat.date.day == secondDay) {
        barChartDatas[1] += 1;
        countInWeek++;
      } else if (stat.date.day == thirdDay) {
        barChartDatas[2] += 1;
        countInWeek++;
      } else if (stat.date.day == fourthDay) {
        barChartDatas[3] += 1;
        countInWeek++;
      } else if (stat.date.day == fifthDay) {
        barChartDatas[4] += 1;
        countInWeek++;
      } else if (stat.date.day == sixthDay) {
        barChartDatas[5] += 1;
        countInWeek++;
      } else if (stat.date.day == sevenDay) {
        barChartDatas[6] += 1;
        countInWeek++;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    taskUpdate();
    return Scaffold(
      appBar: buildDetailsAppBar(context),
      backgroundColor: Color.fromRGBO(50, 65, 85, 0.9),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              decoration: BoxDecoration(
                color: Color.fromRGBO(50, 65, 85, 1),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 21),
                    blurRadius: 53,
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  buildTitleWithMoreIcon(),
                  SizedBox(height: 15),
                  buildCaseNumber(context),
                  SizedBox(height: 15),
                  Text(
                    "График задач за последние 7 дней",
                    style: TextStyle(
                      fontWeight: FontWeight.w200,
                      color: kTextLightColor,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 15),
                  WeeklyChart(
                    barChartDatas: barChartDatas,
                    datas: datas,
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      buildInfoTextWithPercentage(
                        percentage: "${countInWeek.toString()}",
                        title: "За последние 7 дней",
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  RichText buildInfoTextWithPercentage({String title, String percentage}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$percentage \n",
            style: TextStyle(
              fontSize: 20,
              color: kPrimaryColor,
            ),
          ),
          TextSpan(
            text: title,
            style: TextStyle(
              color: kTextLightColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  //свои данные о всех задач в течении месяца
  Row buildCaseNumber(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          "${statistic.length} ",
          style: Theme.of(context)
              .textTheme
              .display3
              .copyWith(color: kPrimaryColor, height: 1.2),
        ),
      ],
    );
  }

  Row buildTitleWithMoreIcon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          "Задач за месяц",
          style: TextStyle(
            color: kTextLightColor,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  //свой апп бар
  AppBar buildDetailsAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (BuildContext context) =>
                        new DepartmentStatisticPage()));
          }),
      title: Text("$title"),
    );
  }
}
