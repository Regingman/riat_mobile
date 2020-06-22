import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_first_flutter_project/main.dart';
import 'package:my_first_flutter_project/models/employee_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'MainPage.dart';

import 'package:intl/intl.dart';
import 'domain/data.dart';
import 'models/order_list.dart';

class FormScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FormScreenState();
  }
}

class FormScreenState extends State<FormScreen> {
  String name;
  String taskStatus;
  String user;
  String data;
  String discription;

  List<DateModel> dates = new List<DateModel>();

  String todayDateIs = "12";

  bool _isLoading = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Container buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      child: RaisedButton(
        onPressed: nameController.text == "" ||
                descriptionController.text == "" ||
                _selectedEmployee == "" ||
                _selectedOrder == ""
            ? null
            : () {
                setState(() {
                  _isLoading = true;
                });
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Создание задачи"),
                        content: Text("Вы уверене что хотите создать задачу?"),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("Да"),
                            onPressed: () {
                              signIn();
                            },
                          ),
                          FlatButton(
                            child: Text("Нет"),
                            onPressed: () {
                              setState(() {
                                _isLoading = false;
                              });
                            },
                          )
                        ],
                      );
                    });
              },
        elevation: 0.0,
        color: Colors.blueGrey,
        child: Text("Создать", style: TextStyle(color: Colors.white70)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

  DateTime _dateTime;

  Widget _dataPicker() {
    return RaisedButton(
      color: Colors.black26,
      child: _dateTime == null
          ? Text('Выберите дату')
          : Text("${_dateTime.day}-${_dateTime.month}-${_dateTime.year}"),
      onPressed: () {
        showDatePicker(
                context: context,
                initialDate: _dateTime == null ? DateTime.now() : _dateTime,
                firstDate: DateTime(2001),
                lastDate: DateTime(2021))
            .then((date) {
          setState(() {
            _dateTime = date;
          });
        });
      },
    );
  }

  Widget calender() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 60, horizontal: 30),
        child: Container(
          height: 60,
          child: ListView.builder(
              itemCount: dates.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return DateTile(
                  weekDay: dates[index].weekDay,
                  date: dates[index].date,
                  isSelected: todayDateIs == dates[index].date,
                );
              }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
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
          title: Text("Создание задачи"),
        ),
        body: Container(
          //height: MainAxisSize.max,
          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),

          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // calender(),
                    textSection(),
                    _dataPicker(),
                    _orderSelect(context),
                    _employeeSelect(context),
                    buttonSection(),
                  ],
                ),
        ),
      ),
    );
  }

  final TextEditingController nameController = new TextEditingController();
  final TextEditingController descriptionController =
      new TextEditingController();

  Widget textSection() {
    return Column(
      children: <Widget>[
        TextFormField(
          controller: nameController,
          cursorColor: Colors.black,
          style: TextStyle(color: Colors.black),
          maxLines: 2,
          decoration: InputDecoration(
            hintText: "Название",
            border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black)),
            hintStyle: TextStyle(color: Colors.black),
          ),
        ),
        TextFormField(
          controller: descriptionController,
          cursorColor: Colors.black,
          maxLines: 4,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: "Описание",
            border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black)),
            hintStyle: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Future<List<OrderList>> _getOrderList() async {
    String url = RiatMobile.getUrl;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString('token');
    final responseContainers = await http
        .get('$url/department', headers: {"Authorization": "Bearer_$token"});
    //print(responseTask.statusCode);
    if (responseContainers.statusCode == 200) {
      //  print(responseContainers.body);
      var containersMaps = jsonDecode(responseContainers.body);
      var containersList = List<OrderList>();
      for (var containersMap in containersMaps) {
        containersList.add(OrderList.fromJson(containersMap));
      }
      return containersList;
      /* setState(() {
        orders.addAll(value);
      });*/
    }
  }

  Future<List<EmployeeList>> _getEmployeeList() async {
    String url = RiatMobile.getUrl;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString('token');
    final responseContainers = await http.get('$url/departmentStaff',
        headers: {"Authorization": "Bearer_$token"});
    //print(responseTask.statusCode);
    if (responseContainers.statusCode == 200) {
      // print(responseContainers.body);
      var containersMaps = jsonDecode(responseContainers.body);
      var containersList = List<EmployeeList>();
      for (var containersMap in containersMaps) {
        containersList.add(EmployeeList.fromJson(containersMap));
      }

      _isLoading = false;
      return containersList;
    }
  }

  signIn() async {
    if (_dateTime == null) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Ошибка!"),
              content: Text("Пожалуйста укажите дату!"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Ок"),
                  onPressed: () {},
                )
              ],
            );
          });
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Ошибка!"),
              content: Text("Выберите сотрудников!"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Ок"),
                  onPressed: () {},
                )
              ],
            );
          });
    }

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int user = sharedPreferences.getInt('user');
    int subtaskId = sharedPreferences.getInt('subtaskId');
    String token = sharedPreferences.getString('token');
    _dateTime = new DateTime(
        _dateTime.year, _dateTime.month, _dateTime.hour, _dateTime.second);
    //var date = new DateFormat.yMd().add_Hms().format(_dateTime);
    String timeH;
    String timeM;
    String timeS;
    String timeMonth;
    String timeDay;
    if (_dateTime.day < 10) {
      timeDay = '0${_dateTime.day}';
    } else {
      timeDay = _dateTime.day.toString();
    }
    if (_dateTime.month < 10) {
      timeMonth = '0${_dateTime.month}';
    } else {
      timeMonth = _dateTime.month.toString();
    }
    if (_dateTime.hour < 10) {
      timeH = '0${_dateTime.hour}';
    } else {
      timeH = _dateTime.hour.toString();
    }
    if (_dateTime.minute < 10) {
      timeM = '0${_dateTime.minute}';
    } else {
      timeM = _dateTime.minute.toString();
    }
    if (_dateTime.second < 10) {
      timeS = '0${_dateTime.second}';
    } else {
      timeS = _dateTime.second.toString();
    }
    //print('${_dateTime.year}-$timeMonth-$timeDay $timeH:$timeM:$timeS');

    Map data = {
      'name': nameController.text,
      'description': descriptionController.text,
      "user_id": userId,
      "owner_id": user,
      "ownDate": '${_dateTime.year}-$timeMonth-$timeDay $timeH:$timeM:$timeS'
    };
    var jsonResponse;
    String url = RiatMobile.getUrl;
    var response = await http.post("$url/task",
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer_$token"
        },
        body: utf8.encode(json.encode(data)));
    if (response.statusCode == 201) {
      jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Успешно!"),
                content: Text("Задача была успешно создана!"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Ок"),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (BuildContext context) => MainPage()),
                          (Route<dynamic> route) => false);
                    },
                  )
                ],
              );
            });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      //print(response.body);
    }
  }

  List<EmployeeList> employees = [];
  List<OrderList> orders = [];
  List<int> userId = [];
  List<EmployeeList> tempEmp = [];

  @override
  void initState() {
    _getOrderList().then((value) {
      setState(() {
        orders.addAll(value);
      });
    });
    _getEmployeeList().then((val) {
      setState(() {
        employees.addAll(val);
      });
    });
    super.initState();
  }

  String _selectedOrder;
  String _selectedEmployee;

  Widget _orderSelect(BuildContext context) {
    return Expanded(
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            isDense: true,
            hint: new Text("Выберите отдел"),
            value: _selectedOrder,
            onChanged: (String newValue) {
              setState(() {
                _selectedOrder = newValue;
              });
              reEmp();
            },
            items: orders.map((OrderList map) {
              return new DropdownMenuItem<String>(
                value: map.id.toString(),
                // value: _mySelection,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Text(map.name)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _employeeSelect(BuildContext context) {
    return Expanded(
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            isDense: true,
            hint: new Text("Выберите сотрудника"),
            value: _selectedEmployee,
            onChanged: (String newValue) {
              setState(() {
                _selectedEmployee = newValue;
              });

              // print(_selectedEmployee);
            },
            items: tempEmp.map((EmployeeList map) {
              return new DropdownMenuItem<String>(
                value: map.id.toString(),
                // value: _mySelection,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Text(map.name)),
                    Checkbox(
                      value: map.flag, //тут надо вставить флаг из модели
                      onChanged: (val) {
                        setState(() {
                          map.flag = _flagRe(map.flag, map.id);
                        });
                      },
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  bool _flagRe(bool val, int id) {
    if (val) {
      userId.remove(id);

      return false;
    } else {
      userId.add(id);
      return true;
    }
  }

  reEmp() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int user = sharedPreferences.getInt('user');
    tempEmp = [];
    var temppEMPP = List<EmployeeList>();
    for (var emp in employees) {
      if (emp.orderId.toString().contains(_selectedOrder) && emp.id != user) {
        temppEMPP.add(emp);
      }
    }
    setState(() {
      tempEmp = temppEMPP;
    });
  }
}

class DateTile extends StatelessWidget {
  String weekDay;
  String date;
  bool isSelected;
  DateTile({this.weekDay, this.date, this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: isSelected ? Color(0xffFCCD00) : Colors.transparent,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            date,
            style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            weekDay,
            style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }
}
