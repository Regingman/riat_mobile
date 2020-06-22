import 'dart:convert';

import 'package:my_first_flutter_project/models/story_model.dart';
import 'package:my_first_flutter_project/models/chat_model.dart';
import 'package:my_first_flutter_project/models/message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import '../main.dart';

Future<List<StoryModel>> getStories() async {
  List<StoryModel> stories = new List();
  StoryModel storyModel = new StoryModel();

  String url = CCTracker.getUrl;
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String token = sharedPreferences.getString('token');
  int userId = sharedPreferences.getInt('user');
  final responseStoryModel = await http.get('$url/departmentStaff/1/1',
      headers: {"Authorization": "Bearer_$token"});
  if (responseStoryModel.statusCode == 200) {
    var storyModelMap = jsonDecode(responseStoryModel.body);

    for (var taskMap in storyModelMap) {
      stories.add(StoryModel.fromJson(taskMap));
    }
  }
/*
  //1
  storyModel.imgUrl = "http://i.pravatar.cc/300";
  storyModel.username = "Atai";
  stories.add(storyModel);

  storyModel = new StoryModel();

  //1
  storyModel.imgUrl = "http://i.pravatar.cc/300";
  storyModel.username = "Ular";
  stories.add(storyModel);

  storyModel = new StoryModel();

  //1
  storyModel.imgUrl = "http://i.pravatar.cc/300";
  storyModel.username = "Alibek";
  stories.add(storyModel);

  storyModel = new StoryModel();

  //1
  storyModel.imgUrl = "http://i.pravatar.cc/300";
  storyModel.username = "Artem";
  stories.add(storyModel);

  storyModel = new StoryModel();

  //1
  storyModel.imgUrl = "http://i.pravatar.cc/300";
  storyModel.username = "Azamat";
  stories.add(storyModel);

  storyModel = new StoryModel();

  //1
  storyModel.imgUrl = "http://i.pravatar.cc/300";
  storyModel.username = "Nurlan";
  stories.add(storyModel);

  storyModel = new StoryModel();
*/
  return stories;
}

List<ChatModel> getChats() {
  List<ChatModel> chats = new List();
  ChatModel chatModel = new ChatModel();

  //1
  chatModel.name = "Atai";
  chatModel.imgUrl = "http://i.pravatar.cc/300";
  chatModel.lastMessage = "Здравствуйте, можно задать вопрос на счет задачи?";
  chatModel.lastSeenTime = "5m";
  chatModel.haveunreadmessages = true;
  chatModel.unreadmessages = 1;
  chats.add(chatModel);

  chatModel = new ChatModel();

  //1
  chatModel.name = "Ular";
  chatModel.imgUrl = "http://i.pravatar.cc/300";
  chatModel.lastMessage = "Я не смог выполнить данную задачу.";
  chatModel.lastSeenTime = "30 m";
  chatModel.haveunreadmessages = false;
  chatModel.unreadmessages = 1;
  chats.add(chatModel);

  chatModel = new ChatModel();

  //1
  chatModel.name = "Alibek";
  chatModel.imgUrl = "http://i.pravatar.cc/300";
  chatModel.lastMessage = "Что надо здесь реализовать?";
  chatModel.lastSeenTime = "6 m";
  chatModel.haveunreadmessages = false;
  chatModel.unreadmessages = 1;
  chats.add(chatModel);

  chatModel = new ChatModel();

  //1
  chatModel.name = "Nuraim";
  chatModel.imgUrl = "http://i.pravatar.cc/300";
  chatModel.lastMessage = "Что тут необходимо реализовать";
  chatModel.lastSeenTime = "5 m";
  chatModel.haveunreadmessages = false;
  chatModel.unreadmessages = 1;
  chats.add(chatModel);

  chatModel = new ChatModel();

  //1
  chatModel.name = "Artem";
  chatModel.imgUrl = "http://i.pravatar.cc/300";
  chatModel.lastMessage = "Здесь необходимо убрать комнату в таком порядке...";
  chatModel.lastSeenTime = "1 hr";
  chatModel.haveunreadmessages = false;
  chatModel.unreadmessages = 1;
  chats.add(chatModel);

  chatModel = new ChatModel();

  return chats;
}

List<MessageModel> getMessages() {
  List<MessageModel> messages = new List();
  MessageModel messageModel = new MessageModel();

//*/1
  /*messageModel.isByme = true;
  messageModel.message = "Спасибо за наставления!";
  messages.add(messageModel);

  messageModel = new MessageModel();

//1
  messageModel.isByme = false;
  messageModel.message = "Что именно вам интересно?";
  messages.add(messageModel);

  messageModel = new MessageModel();

//1
  messageModel.isByme = true;
  messageModel.message = "Именно какая задача?";
  messages.add(messageModel);

  messageModel = new MessageModel();

  return messages;
*/}
