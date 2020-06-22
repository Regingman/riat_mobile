import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_first_flutter_project/All_taskPage.dart';
import 'package:my_first_flutter_project/models/chat_model.dart';
import 'package:my_first_flutter_project/models/story_model.dart';
import 'package:my_first_flutter_project/screen/char_screen.dart';
import 'package:my_first_flutter_project/views/department_user_statistic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../department_statistic_page.dart';
import '../main.dart';
import 'package:http/http.dart' as http;
import '../MainPage.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<StoryModel> stories = new List();
  List<ChatModel> chats = new List();

  @override
  void initState() {
    super.initState();
    _loadStoryModel();
    //stories = _loadStoryModel() as List<StoryModel>;
    //chats = getChats();
  }

  bool _isLoading = true;
  String token;

  _loadStoryModel() async {
    String url = RiatMobile.getUrl;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    token = sharedPreferences.getString('token');
    int userId = sharedPreferences.getInt('user');
    final responseStoryModel = await http.get('$url/departmentStaff/$userId',
        headers: {"Authorization": "Bearer_$token"});
    if (responseStoryModel.statusCode == 200) {
      var storyModelMap = jsonDecode(responseStoryModel.body);
      var tempStorys = List<StoryModel>();
      var tempChat = List<ChatModel>();
      for (var taskMap in storyModelMap) {
        tempStorys.add(StoryModel.fromJson(taskMap));
      }
      for (var tempStory in tempStorys) {
        for (var tempChatMap in tempStory.chatModel) {
          tempChatMap.name = tempStory.username;
          tempChat.add(tempChatMap);
        }
      }
      /*for (var tempMap in tempMaps) {
        tempChat.add(ChatModel.fromJson(tempMap));
      }*/
      setState(() {
        stories = tempStorys;
        chats = tempChat;

        _isLoading = false;
      });
    }
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
          title: Text("Отдел"),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.assessment,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) =>
                            new DepartmentStatisticPage()));
              },
            ),
          ],
        ),
        backgroundColor: Color.fromRGBO(50, 65, 85, 1),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 70,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: <Widget>[
                            Text(
                              "Сотрудники",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600),
                            ),
                            Spacer(),
                           
                          ],
                        ),
                      ),

                      /// now stories
                      SizedBox(
                        height: 50,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 0),
                        height: 120,
                        child: ListView.builder(
                            itemCount: stories.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return StoryTile(
                                imgUrl: stories[index].imgUrl != null
                                    ? stories[index].imgUrl
                                    : "",
                                username: stories[index].username != null
                                    ? stories[index].username
                                    : "",
                                id: stories[index].id != null
                                    ? stories[index].id
                                    : 0,
                                token: token,
                              );
                            }),
                      ),

                      /// CHats
                      ///
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30))),
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(top: 30),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      "Чаты",
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.more_vert,
                                      color: Colors.black45,
                                    )
                                  ],
                                ),
                              ),
                              ListView.builder(
                                  itemCount: chats.length,
                                  shrinkWrap: true,
                                  physics: ClampingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return ChatTile(
                                      imgUrl: stories[index].imgUrl != null
                                          ? stories[index].imgUrl
                                          : "",
                                      name: chats[index].name != null
                                          ? chats[index].name
                                          : "",
                                      lastMessage:
                                          chats[index].lastMessage != null
                                              ? chats[index].lastMessage
                                              : "",
                                      haveunreadmessages:
                                          chats[index].haveunreadmessages !=
                                                  null
                                              ? chats[index].haveunreadmessages
                                              : false,
                                      unreadmessages:
                                          chats[index].unreadmessages != null
                                              ? chats[index].unreadmessages
                                              : 0,
                                      lastSeenTime:
                                          chats[index].lastSeenTime != null
                                              ? chats[index].lastSeenTime
                                              : "",
                                      userId: chats[index].adresseeId != null
                                          ? chats[index].adresseeId
                                          : "",
                                      token: token,
                                    );
                                  }),
                            ],
                          ))
                    ],
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.arrow_left),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (BuildContext context) => new MainPage()));
          },
        ),
      ),
    );
  }
}

class StoryTile extends StatelessWidget {
  final String imgUrl;
  final String username;
  final String token;
  final int id;
  StoryTile(
      {@required this.imgUrl,
      @required this.username,
      @required this.id,
      @required this.token});
  @override
  String url = RiatMobile.getUrl;

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _addUser(id);
        Navigator.of(context).pop();
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => new Dashboard()));
      },
      child: Container(
        margin: EdgeInsets.only(right: 16),
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: new Image.network(
                '$url/img/$imgUrl',
                height: 60,
                width: 60,
                fit: BoxFit.cover,
                headers: {"Authorization": "Bearer_$token"},
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              username,
              style: TextStyle(
                  color: Color(0xff78778a),
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            )
          ],
        ),
      ),
    );
  }

  _addUser(int id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt("orderUser", id);
  }
}

class ChatTile extends StatelessWidget {
  final String imgUrl;
  final String name;
  final String lastMessage;
  final bool haveunreadmessages;
  final int unreadmessages;
  final String lastSeenTime;
  final int userId;
  final String token;
  ChatTile(
      {@required this.unreadmessages,
      @required this.haveunreadmessages,
      @required this.lastSeenTime,
      @required this.lastMessage,
      @required this.imgUrl,
      @required this.name,
      @required this.userId,
      @required this.token});
  String url = RiatMobile.getUrl;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _secondUser(userId);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ChatScreen(user: name)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: new Image.network(
                '$url/img/$imgUrl',
                height: 60,
                width: 60,
                fit: BoxFit.cover,
                headers: {"Authorization": "Bearer_$token"},
              ),
            ),
            SizedBox(
              width: 16,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 17,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    lastMessage,
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                        fontFamily: "Neue Haas Grotesk"),
                  )
                ],
              ),
            ),
            SizedBox(
              width: 14,
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(lastSeenTime),
                  SizedBox(
                    height: 16,
                  ),
                  haveunreadmessages
                      ? Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Color(0xffff410f),
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            "$unreadmessages",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ))
                      : Container()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _secondUser(int id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt("secondUser", id);
  }
}
