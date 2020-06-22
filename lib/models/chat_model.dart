import 'dart:convert';

class ChatModel {
  String imgUrl;
  String name;
  String lastMessage;
  bool haveunreadmessages;
  int unreadmessages;
  String lastSeenTime;
  int adresseeId;
  int userId;

  ChatModel.fromJson(Map<String, dynamic> json) {
    name = json['firstName'];
    lastMessage = json['text'];
    imgUrl = json['fileName'];
    adresseeId = json['adresseeId'] as int;
    userId = json['userId'] as int;
    haveunreadmessages = json['haveunreadmessages'] as bool;
    if (json['lastSeenTime'] != null) {
      DateTime msgDateTime = DateTime.parse(json['lastSeenTime'].toString());
      DateTime curDateTime = DateTime.now();
      //lastSeenTime = ;
      int time = curDateTime.difference(msgDateTime).inSeconds;
      if (time < 60) {
        lastSeenTime = "${time.toString()} сек";
      } else if (time > 60 && time < 3600) {
        int min = time ~/ 60;
        int sec = time - 60 * min;
        lastSeenTime = '$min мин $sec сек';
      } else if (time > 3600 && time < 86400) {
        int hour = time ~/ 3600;
        int min = (time - 3600 * hour) ~/ 60;
        lastSeenTime = '$hour ч $min мин';
      } else if (time > 86400) {
        int day = time ~/ 86400;
        int hour = (time - 86400 * day) ~/ 3600;
        lastSeenTime = '$day д $hour ч';
      }
    }
    unreadmessages = json['unreadmessages'] as int;
  }

  Map<String, dynamic> toJson() => {
        'firstName': name,
        'text': lastMessage,
      };

  ChatModel(
      {this.name,
      this.lastMessage,
      this.imgUrl,
      this.adresseeId,
      this.haveunreadmessages,
      this.userId,
      this.lastSeenTime,
      this.unreadmessages});
}
