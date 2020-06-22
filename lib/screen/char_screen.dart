import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_first_flutter_project/domain/UserMain.dart';
import 'package:my_first_flutter_project/models/message_model.dart';
import 'package:my_first_flutter_project/views/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../main.dart';

class ChatScreen extends StatefulWidget {
  final String user;

  ChatScreen({@required this.user});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool flag = false;
  List<MessageModel> messages = new List<MessageModel>();
  int user;
  _buildMessage(MessageModel message, bool isMe) {
    final Container msg = Container(
      margin: isMe
          ? EdgeInsets.only(
              top: 8.0,
              bottom: 8.0,
              left: 80.0,
            )
          : EdgeInsets.only(
              top: 8.0,
              bottom: 8.0,
            ),
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
        color: isMe ? Theme.of(context).accentColor : Color(0xFFFFEFEE),
        borderRadius: isMe
            ? BorderRadius.only(
                topLeft: Radius.circular(15.0),
                bottomLeft: Radius.circular(15.0),
              )
            : BorderRadius.only(
                topRight: Radius.circular(15.0),
                bottomRight: Radius.circular(15.0),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            message.sendDate,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            message.text,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    if (isMe) {
      return msg;
    }
    return Row(
      children: <Widget>[msg],
    );
  }

  _loadCC() async {
    print(widget.user);
    if (flag == false) {
      String url = CCTracker.getUrl;
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String token = sharedPreferences.getString('token');
      int userId = sharedPreferences.getInt('user');
      int secondUserId = sharedPreferences.getInt('secondUser');
      final responseTask = await http.get('$url/message/$userId/$secondUserId',
          headers: {"Authorization": "Bearer_$token"});
      //print(responseTask.statusCode);
      if (responseTask.statusCode == 200) {
        //print(responseTask.body);
        var taskMaps = jsonDecode(responseTask.body);
        var taskList = List<MessageModel>();
        for (var taskMap in taskMaps) {
          taskList.add(MessageModel.fromJson(taskMap));
          //print(taskMap);
        }
        setState(() {
          messages = taskList;
          // print(messages);
          user = userId;
          flag = true;
        });
      }
    }
  }

  _sendMsg(value) async {
    String url = CCTracker.getUrl;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString('token');
    int userId = sharedPreferences.getInt('user');
    int secondUserId = sharedPreferences.getInt('secondUser');
    Map data = {
      'addresseeId': secondUserId,
      'senderId': userId,
      'read_or_no': 0,
      'text': value.text
    };
    final responseTask = await http.post('$url/message',
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer_$token"
        },
        body: utf8.encode(json.encode(data)));
    //print(responseTask.statusCode);
    if (responseTask.statusCode == 201) {
      //print(responseTask.body);
      var taskMaps = jsonDecode(responseTask.body);
      var msg = MessageModel.fromJson(taskMaps);
      setState(() {
        messages.add(msg);
        msgText.text = '';
      });
    }
  }

  @override
  void initState() {
    //_loadCC();
    super.initState();
  }

  final TextEditingController msgText = new TextEditingController();

  _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.photo),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: msgText,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {},
              decoration: InputDecoration.collapsed(
                hintText: 'Отправить сообщение...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              _sendMsg(msgText);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _loadCC();
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop();
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => new Home()));
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
                        builder: (BuildContext context) => new Home()));
              }),
          title: Text(
            widget.user,
            style: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.more_horiz),
              iconSize: 30.0,
              color: Colors.white,
              onPressed: () {},
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                    child: ListView.builder(
                      reverse: true,
                      padding: EdgeInsets.only(top: 15.0),
                      itemCount: messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        //print(messages[(messages.length - 1) - index].text);
                        final MessageModel message =
                            messages[(messages.length - 1) - index];
                        final bool isMe = message.senderId == user;
                        return _buildMessage(message, isMe);
                      },
                    ),
                  ),
                ),
              ),
              _buildMessageComposer(),
            ],
          ),
        ),
      ),
    );
  }
}
