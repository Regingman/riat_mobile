import 'package:my_first_flutter_project/models/chat_model.dart';

class StoryModel {
  int id;
  String imgUrl;
  String username;
  List<ChatModel> chatModel;

  StoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int;
    username = json['firstName'];
    imgUrl = json['fileName'];
    var list = json['messages'] as List;
    print(list.runtimeType); //returns List<dynamic>
    List<ChatModel> chatModelList =
        list.map((i) => ChatModel.fromJson(i)).toList();
    chatModel = chatModelList;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': username,
      };

  StoryModel({this.id, this.username, this.imgUrl});
}
