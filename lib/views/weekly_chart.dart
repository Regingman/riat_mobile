import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class WeeklyChart extends StatelessWidget {
  final List<double> barChartDatas;
  final List<String> datas;

  WeeklyChart({@required this.barChartDatas, @required this.datas});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          barGroups: getBarGroups(),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: SideTitles(
              showTitles: false,
            ),
            bottomTitles: SideTitles(
              showTitles: true,
              getTitles: getWeek,
              textStyle: TextStyle(
                color: kBackgroundColor,
                fontSize: 10,
                fontWeight: FontWeight.w200,
              ),
            ),
          ),
        ),
      ),
    );
  }

  getBarGroups() {
    //тут нужны свои данные
    //List<double> barChartDatas = [6, 10, 8, 7, 10, 15, 9];
    List<BarChartGroupData> barChartGroups = [];
    barChartDatas.asMap().forEach(
          (i, value) => barChartGroups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  y: value,
                  //This is not the proper way, this is just for demo
                  color: i == 4 ? kPrimaryColor : kInactiveChartColor,
                  width: 16,
                )
              ],
            ),
          ),
        );
    return barChartGroups;
  }

  String getWeek(double value) {
    switch (value.toInt()) {
      case 0:
        return datas[0];
      case 1:
        return datas[1];
      case 2:
        return datas[2];
      case 3:
        return datas[3];
      case 4:
        return datas[4];
      case 5:
        return datas[5];
      case 6:
        return datas[6];
      default:
        return '';
    }
  }
}
