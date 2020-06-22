import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_first_flutter_project/CCList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'animation/FadeAnimation.dart';
import 'domain/Task.dart';
import 'main.dart';

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => new _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  Task mainTask = new Task(
    name: "",
    termDate: DateTime.now(),
    description: "",
    taskStatusId: 1,
    templateTask: true,
  );
  List<Task> task = [];
  String button = '';
  @override
  void initState() {
    super.initState();
    _loadCC();
  }

  Widget taskBody(BuildContext context) {
    //_loadCC();
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop();
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => new CCList()));
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
                        builder: (BuildContext context) => new CCList()));
              }),
          title: Text("Задача"),
        ),
        backgroundColor: Colors.grey,
        body: Stack(
          children: <Widget>[
            CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: 290,
                  backgroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Container(
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.bottomRight,
                                colors: [
                              Colors.white,
                              Colors.white.withOpacity(.3)
                            ])),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              FadeAnimation(
                                  1,
                                  Text(
                                    mainTask.name,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30),
                                  )),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  FadeAnimation(
                                      1.2,
                                      Text(
                                        "Завершить задачу до: \n" +
                                            mainTask.termDate.toString() +
                                            "\n ${mainTask.lastSeenTime}.",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16),
                                      )),
                                  SizedBox(
                                    width: 100,
                                  )
                                ],
                              ),
                              FadeAnimation(
                                  1.6,
                                  Text(
                                    mainTask.description,
                                    style: TextStyle(
                                        color: Colors.black, height: 1.1),
                                  )),
                              SizedBox(
                                height: 20,
                              ),
                              FadeAnimation(
                                  1.6,
                                  Text(
                                    "Поручил",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  )),
                              SizedBox(
                                height: 10,
                              ),
                              FadeAnimation(
                                  1.4,
                                  Text(
                                    "${mainTask.firstName} ${mainTask.lastName}",
                                    style: TextStyle(color: Colors.black),
                                  )),
                              SizedBox(
                                height: 0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          FadeAnimation(
                              1.6,
                              Text(
                                "Подзадачи",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              )),
                          SizedBox(
                            height: 10,
                          ),
                          FadeAnimation(1.4,
                              SizedBox(height: 400, child: builds(context))),
                          SizedBox(
                            height: 300,
                          ),
                        ],
                      ),
                    )
                  ]),
                ),
              ],
            ),
            Positioned.fill(
              bottom: 50,
              child: Container(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FadeAnimation(
                    2,
                    InkWell(
                        onTap: mainTask.taskStatusId == 2
                            ? () {
                                //  print(mainTask.taskStatusId);
                              }
                            : () {
                                _taskApp();
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Успешно"),
                                        content:
                                            Text("Задача успешно завершена!"),
                                        actions: <Widget>[
                                          FlatButton(
                                            child: Text("Ок"),
                                            onPressed: () {},
                                          )
                                        ],
                                      );
                                    });
                              },
                        child: new Container(
                          margin: EdgeInsets.symmetric(horizontal: 30),
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.yellow[700]),
                          child: Align(
                              child: Text(
                            button,
                            style: TextStyle(color: Colors.black),
                          )),
                        )),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _taskApp() async {
    if (mainTask.taskStatusId != 2) {
      String url = CCTracker.getUrl;
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String token = sharedPreferences.getString('token');
      int taskId = sharedPreferences.getInt('subtask');
      int userId = sharedPreferences.getInt('user');
      final responseTask = await http.post('$url/task/status/$taskId/$userId/2',
          headers: {"Authorization": "Bearer_$token"});
    }
  }

  _loadCC() async {
    String url = CCTracker.getUrl;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString('token');
    int taskId = sharedPreferences.getInt('task');
    int subtaskId = sharedPreferences.getInt('subtask');
    int userId = sharedPreferences.getInt('user');
    final responseTask = await http.get('$url/task/subTask/$subtaskId',
        headers: {"Authorization": "Bearer_$token"});
    final responseMainTask = await http.get('$url/task/user/$subtaskId/$userId',
        headers: {"Authorization": "Bearer_$token"});
    if (responseMainTask.statusCode == 200) {
      Map<String, dynamic> mainTaskMaps = jsonDecode(responseMainTask.body);
      Task tempMainTask = Task.fromJson(mainTaskMaps);
      if (responseTask.statusCode == 200) {
        if (responseTask.body != "") {
          var taskMaps = jsonDecode(responseTask.body);
          List<Task> taskList = List<Task>();
          for (var taskMap in taskMaps) {
            taskList.add(Task.fromJson(taskMap));
          }
          setState(() {
            task = taskList;
          });
        }
      }
      setState(() {
        mainTask = tempMainTask;
        if (mainTask.taskStatusId == 2) {
          button = 'Задача завершена';
        } else {
          button = 'Завершить задачу';
        }
      });
    }
    _isLoading = false;
  }

  _task(int id, int subtask) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt("task", id);
    sharedPreferences.setInt('subtask', subtask);
  }

  Widget builds(BuildContext context) {
    if (task.length > 0)
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
                                right: BorderSide(
                                    width: 1, color: Colors.white24))),
                      ),
                      title: Text(
                        task[i].name,
                        style: TextStyle(
                            color: Theme.of(context).textTheme.title.color,
                            fontWeight: FontWeight.bold),
                      ),
                      trailing: Icon(
                        Icons.keyboard_arrow_right,
                        color: Theme.of(context).textTheme.title.color,
                      ),
                      onTap: () {
                        _task(task[i].id, task[i].taskId);
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    new TaskPage()));
                      },
                    ),
                  ),
                );
              }),
        ),
      );
  }

  bool _isLoading = true;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : taskBody(context),
    );
  }
}
