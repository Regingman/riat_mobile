import 'package:flutter/material.dart';
import 'package:my_first_flutter_project/TaskHistoryPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CCData.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'domain/Task.dart';
import 'domain/UserMain.dart';
import 'main.dart';

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => new MainPageState();
}

class MainPageState extends State<MainPage> {
  String url = RiatMobile.getUrl;
  List<Task> task = [];
  List<CCData> data = [];
  UserMain user = new UserMain(id: 1, firstName: "", telephon: "");
  String token;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    if (user == null) return null;
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Container(
            child: Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              appBar: AppBar(
                title: Text('Список задач'),
              ),
              drawer: new Drawer(
                child: ListView(
                  children: <Widget>[
                    new UserAccountsDrawerHeader(
                      accountName: new Text(user.lastName +
                          " " +
                          user.firstName +
                          '\n' +
                          user.positionName),
                      accountEmail: new Text(user.telephon),
                      currentAccountPicture: new CircleAvatar(
                        backgroundImage: new NetworkImage(
                            '$url/img/${user.fileName}',
                            headers: {"Authorization": "Bearer_$token"}),
                      ),
                    ),
                    new ListTile(
                      leading: Icon(Icons.mode_edit),
                      title: new Text(
                        'История задач',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    new TaskHistoryPage()));
                      },
                    ),
                    new ListTile(
                      leading: Icon(Icons.check_circle),
                      title: new Text(
                        'Ведомость задач',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/about');
                      },
                    ),
                    new ListTile(
                      leading: Icon(Icons.person),
                      title: new Text(
                        'Аккаунт',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () {
                        int userId = user.id;
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/account/$userId');
                        //print(userId);
                      },
                    ),
                    new ListTile(
                      leading: Icon(Icons.check_circle),
                      title: new Text(
                        'Мой отдел',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/department');
                      },
                    ),
                    user.position == 2
                        ? new ListTile(
                            leading: Icon(Icons.text_rotate_up),
                            title: new Text(
                              'Создание задачи',
                              style: TextStyle(fontSize: 18),
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.pushNamed(context, '/taskCreate');
                            },
                          )
                        : new ListTile(
                            leading: Icon(Icons.arrow_back),
                            title: new Text(
                              'Выйти',
                              style: TextStyle(fontSize: 18),
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.pushNamed(context, '/login');
                            },
                          ),
                  ],
                ),
              ),
              body: builds(context),
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.refresh),
                onPressed: () => _loadUser(),
              ),
            ),
          );
  }

  _loadUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    token = sharedPreferences.getString('token');
    int userId = sharedPreferences.getInt('user');
    final responseTask = await http.get('$url/api/v1/users/$userId',
        headers: {"Authorization": "Bearer_$token"});
    if (responseTask.statusCode == 200) {
      var userMaps = jsonDecode(responseTask.body);
      var tempUser = UserMain.fromJson(userMaps);
      setState(() {
        user = tempUser;
      });
    }

    final responseTaskT = await http.get('$url/task/employee/$userId/active',
        headers: {"Authorization": "Bearer_$token"});
    if (responseTaskT.statusCode == 200) {
      var taskMaps = jsonDecode(responseTaskT.body);
      var taskList = List<Task>();
      for (var taskMap in taskMaps) {
        taskList.add(Task.fromJson(taskMap));
      }
      setState(() {
        task = taskList;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _loadUser();
    super.initState();
  }

  Widget builds(BuildContext context) {
    return Container(
      child: Container(
        child: ListView.builder(
            itemCount: task.length,
            itemBuilder: (context, i) {
              return Card(
                elevation: 2.0,
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Container(
                  decoration:
                      BoxDecoration(color: Color.fromRGBO(50, 65, 85, 0.9)),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    leading: Container(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.mode_edit,
                        color: Theme.of(context).textTheme.title.color,
                      ),
                      decoration: BoxDecoration(
                          border: Border(
                              right:
                                  BorderSide(width: 1, color: Colors.white24))),
                    ),
                    title: Text(
                      task[i].name,
                      style: TextStyle(
                          color: Theme.of(context).textTheme.title.color,
                          fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: new CircleAvatar(
                        backgroundImage: new NetworkImage(
                            '$url/img/${task[i].fileName}',
                            headers: {"Authorization": "Bearer_$token"}),
                      ),
                      onPressed: () {
                        int id = task[i].ownerId;
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/account/$id');
                      },
                    ),
                    subtitle: subTitle(context, task[i]),
                    onTap: () {
                      _task(task[i].id, task[i].taskId);
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/task');
                    },
                  ),
                ),
              );
            }),
      ),
    );
  }

  _task(int id, int subtaskId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt("task", id);
    sharedPreferences.setInt("subtask", subtaskId);
  }

  Widget subTitle(BuildContext context, Task task) {
    var color = Colors.grey;
    double indicatorLevel = task.procent / 100;
    if (task.procent < 30 && task.procent > 0) {
      color = Colors.green;
    } else if (task.procent < 60 && task.procent > 31) {
      color = Colors.yellow;
    } else if (task.procent < 101 && task.procent > 61) {
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
      ],
    );
  }
}
