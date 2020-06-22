import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_first_flutter_project/MainPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'CCData.dart';
import 'domain/Task.dart';
import 'domain/UserMain.dart';
import 'main.dart';

class TaskHistoryPage extends StatefulWidget {
  @override
  _TaskHistoryPageState createState() => new _TaskHistoryPageState();
}

class _TaskHistoryPageState extends State<TaskHistoryPage> {
  List<Task> task = [];
  List<CCData> data = [];
  UserMain user = new UserMain(id: 1, name: "", telephon: "");
  bool _isLoading = true;
  String url, token;

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
                  builder: (BuildContext context) => new MainPage()));
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
                          builder: (BuildContext context) => new MainPage()));
                }),
            title: Text("История"),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          body: _isLoading
              ? Center(child: CircularProgressIndicator())
              : builds(context),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.refresh),
            onPressed: () => _loadUser(),
          ),
        ),
      ),
    );
  }

  _loadUser() async {
    url = RiatMobile.getUrl;
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

    final responseTaskT = await http.get('$url/task/employee/$userId/inactive',
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
              // print(context);
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
                        Navigator.pushReplacementNamed(context, '/account/$id');
                      },
                    ),
                    subtitle: subTitle(context, task[i]),
                    onTap: () {
                      _task(task[i].id, task[i].taskId);
                      Navigator.of(context).pop();
                      Navigator.pushReplacementNamed(
                          context, '/taskHistoryDetail');
                    },
                  ),
                ),
              );
            }),
      ),
    );
  }

  _task(int id, int subtask) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt("task", id);
    sharedPreferences.setInt('subtask', subtask);
  }

  Widget subTitle(BuildContext context, Task task) {
    var color = Colors.green;
    if (task.taskStatusId == 3) {
      color = Colors.red;
    }
    double indicatorLevel = task.procent;
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
