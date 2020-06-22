import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_first_flutter_project/TaskHistoryPage.dart';
import 'package:my_first_flutter_project/subtask_create_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'All_taskPage.dart';
import 'CCList.dart';
import 'animation/FadeAnimation.dart';
import 'domain/Task.dart';
import 'main.dart';

class TaskDetailManagerPage extends StatefulWidget {
  @override
  _TaskDetailManagerPage createState() => new _TaskDetailManagerPage();
}

class _TaskDetailManagerPage extends State<TaskDetailManagerPage> {
  Task mainTask = new Task(
    name: "",
    termDate: DateTime.now(),
    description: "",
    taskStatusId: 1,
    templateTask: true,
  );
  List<Task> task = [];

  @override
  void initState() {
    super.initState();
    _loadCC();
  }

  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop();
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => new AllTaskPage()));
      },
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new AllTaskPage()));
                    }),
                title: Text("Задача"),
                actions: <Widget>[
                  Stack(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 12.0, right: 20.0),
                        child: InkResponse(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        new SubtaskCreatePage()));
                          },
                          child: Icon(
                            Icons.add,
                            size: 30.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
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
                                                  "\n${mainTask.lastSeenTime}.",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16),
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
                                          "Сеитбек уулу Атай",
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
                                FadeAnimation(
                                    1.4,
                                    SizedBox(
                                        height: 400, child: builds(context))),
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
                ],
              ),
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.check),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Изменение задач"),
                          content:
                              Text("Вы уверене что хотите внести изменения?"),
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
                                            new TaskDetailManagerPage()));
                              },
                            )
                          ],
                        );
                      });
                },
              ),
            ),
    );
  }

  _taskApp() async {
    String url = CCTracker.getUrl;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString('token');
    int userId = 1;
    //sharedPreferences.getInt('user');
    for (var tempTask in task) {
      await http.post(
          '$url/task/status/${tempTask.id}/$userId/${tempTask.taskStatusId}',
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
                              new TaskDetailManagerPage()));
                },
              )
            ],
          );
        });
  }

  _loadCC() async {
    String url = CCTracker.getUrl;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString('token');
    int taskId = sharedPreferences.getInt('task');
    int subtaskId = sharedPreferences.getInt('subtask');
    int userId = sharedPreferences.getInt('orderUser');
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

       // print(task.length);
      });
    }
    _isLoading = false;
  }

  Widget builds(BuildContext context) {
    if (task.length > 0)
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
                  child: Card(
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
                            });
                          },
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
                                      new TaskHistoryPage()));
                        },
                      ),
                    ),
                  ),
                );
              }),
        ),
      );
  }

  remove(int i) async {
    task.removeAt(i);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String url = CCTracker.getUrl;
    String token = sharedPreferences.getString('token');
   await http.delete('$url/listOfEmployee/${task[i].id}',
        headers: {"Authorization": "Bearer_$token"});
  }

  _task(int id, int subtask) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt("task", id);
    sharedPreferences.setInt('subtask', subtask);
  }
}
