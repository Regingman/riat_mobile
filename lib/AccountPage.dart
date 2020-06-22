import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_first_flutter_project/screen/char_screen.dart';
import 'package:my_first_flutter_project/views/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'CCList.dart';
import 'domain/UserMain.dart';
import 'main.dart';

class AccountPage extends StatefulWidget {
  int id;

  AccountPage({this.id});

  @override
  _AccountPageState createState() => new _AccountPageState(id: id);
}

class _AccountPageState extends State<AccountPage> {
  int id;
  String token;
  String url = CCTracker.getUrl;

  _AccountPageState({this.id});
  bool flag = true;

  UserMain user = new UserMain(name: "", telephon: "");

  Widget _buildCoverImage(Size screenSize) {
    return Container(
      height: screenSize.height / 3,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: new NetworkImage('$url/img/${user.fileName}',
              headers: {"Authorization": "Bearer_$token"}),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Container(
        width: 140.0,
        height: 140.0,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: new NetworkImage('$url/img/${user.fileName}',
                headers: {"Authorization": "Bearer_$token"}),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(80.0),
          border: Border.all(
            color: Colors.white,
            width: 10.0,
          ),
        ),
      ),
    );
  }

  Widget _buildFullName() {
    TextStyle _nameTextStyle = TextStyle(
      fontFamily: 'Roboto',
      color: Colors.black,
      fontSize: 28.0,
      fontWeight: FontWeight.w700,
    );

    return Text(
      "${user.firstName} ${user.lastName} ${user.patronymic}",
      style: _nameTextStyle,
    );
  }

  Widget _buildStatus(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        user.telephon,
        style: TextStyle(
          fontFamily: 'Spectral',
          color: Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  @override
  void initState() {
    _loadUser();
    super.initState();
  }

  int departmentId;

  _loadUser() async {
    String url = CCTracker.getUrl;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    token = sharedPreferences.getString('token');
    int userId = sharedPreferences.getInt('user');
    if (id == userId) {
      flag = false;
    }
    final responseTask = await http.get('$url/api/v1/users/$id',
        headers: {"Authorization": "Bearer_$token"});
    if (responseTask.statusCode == 200) {
      var userMaps = jsonDecode(responseTask.body);
      var tempUser = UserMain.fromJson(userMaps);
      setState(() {
        user = tempUser;
        _isLoading = false;
      });
    }
  }

  Widget _buildButtons() {
    if (flag)
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: <Widget>[
            SizedBox(width: 10.0),
            Expanded(
              child: InkWell(
                onTap: () {
                  _second();
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (BuildContext context) =>
                              new ChatScreen(user: user.firstName)));
                },
                child: Container(
                  height: 40.0,
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        "Сообщение",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    else {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: InkWell(
                onTap: () {},
                child: Container(
                  height: 40.0,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    color: Color(0xFF404A5C),
                  ),
                  child: Center(
                    child: Text(
                      "Изменить личные данные",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  _second() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt("secondUser", user.id);
  }

  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : WillPopScope(
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
                title: Text("Профиль"),
              ),
              body: Stack(
                children: <Widget>[
                  _buildCoverImage(screenSize),
                  SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: screenSize.height / 6.4),
                          _buildProfileImage(),
                          _buildFullName(),
                          _buildStatus(context),
                          _buildButtons(),
                          SizedBox(height: 10.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.arrow_left),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (BuildContext context) => new CCList()));
                },
              ),
            ),
          );
  }
}
