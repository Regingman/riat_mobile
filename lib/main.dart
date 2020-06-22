import 'package:flutter/material.dart';
import 'package:my_first_flutter_project/AboutPage.dart';
import 'package:my_first_flutter_project/AccountPage.dart';
import 'package:my_first_flutter_project/CCList.dart';
import 'package:my_first_flutter_project/LoginPage.dart';
import 'package:my_first_flutter_project/TaskHistoryPage.dart';
import 'package:my_first_flutter_project/TaskPage.dart';
import 'package:my_first_flutter_project/department_statictis_page_detail.dart';
import 'package:my_first_flutter_project/department_statistic_page.dart';
import 'package:my_first_flutter_project/taskHistoryPageDetail.dart';
import 'package:my_first_flutter_project/task_create_page.dart';
import 'package:my_first_flutter_project/task_detail_manager_page.dart';
import 'package:my_first_flutter_project/views/home.dart';

import 'All_taskPage.dart';
import 'first.dart';

void main() => runApp(CCTracker());

class CCTracker extends StatelessWidget {
  static String url = "http://034631a74356.ngrok.io";

  static String get getUrl {
    return url;
  }

  static set setUrl(String _url) {
    url = _url;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riat',
      theme: ThemeData(
          primaryColor: Color.fromRGBO(50, 65, 85, 1),
          textTheme: TextTheme(title: TextStyle(color: Colors.white))),
      initialRoute: '/first',
      routes: {
        '/login': (context) => LoginPage(),
        '/mainEmployee': (context) => CCList(),
        '/task': (context) => TaskPage(),
        '/about': (context) => AboutPage(),
        '/account': (context) => AccountPage(),
        '/taskHistory': (context) => TaskHistoryPage(),
        '/taskCreate': (context) => FormScreen(),
        '/taskHistoryDetail': (context) => TaskHistoryPageDetail(),
        '/department': (context) => Home(),
        '/allTask': (context) => AllTaskPage(),
        '/first': (context) => OnboardingScreen(),
        '/taskDetailManager':(context)=>TaskDetailManagerPage(),
        '/departmentStatistic':(context)=>DepartmentStatisticPage(),
        '/departmentStatisticDetail':(context)=>DepartmentStatisticPageDetail(),
        
      },
      onGenerateRoute: (routeSettings) {
        var path = routeSettings.name.split('/');
        if (path[1] == 'account') {
          return new MaterialPageRoute(
              builder: (context) => new AccountPage(id: int.parse(path[2])),
              settings: routeSettings);
        }
      },
    );
  }
}
