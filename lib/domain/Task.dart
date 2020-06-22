import 'dart:convert';

class Task {
  int id;
  String name;
  String description;
  int taskStatusId;
  bool templateTask;
  double procent;
  DateTime termDate;
  DateTime createDate;
  DateTime updateDate;
  int ownerId;
  int taskId;
  String lastSeenTime;
  String fileName;
  String firstName;
  String lastName;

  Task.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int;
    name = json['name'];

    description = json['description'];
    templateTask = json['templateTask'];
    taskStatusId = json['taskStatusId'];
    taskId = json['taskId'];
    termDate = DateTime.parse(json['termDate'].toString());
    createDate = DateTime.parse(json['createDate'].toString());
    updateDate = DateTime.parse(json['updateDate'].toString());
    ownerId = json['ownerId'];
    fileName = json['fileName'];
    firstName = json['firstName'];
    lastName = json['lastName'];

    DateTime curDateTime = DateTime.now();
    int time = curDateTime.difference(termDate).inSeconds;
    int timeMax = createDate.difference(termDate).inSeconds;
    procent = time * 100 / timeMax;
    if (procent > 100) {
      procent = 100;
    }

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
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'procent': procent,
        'description': description,
        'templateTask': templateTask,
        'termDate': termDate,
        'taskId': taskId,
        'createDate': createDate,
        'updateDate': updateDate,
        'ownerId': ownerId,
        'taskStatusId': taskStatusId,
      };
  Task(
      {this.id,
      this.name,
      this.taskId,
      this.description,
      this.templateTask,
      this.termDate,
      this.createDate,
      this.updateDate,
      this.taskStatusId,
      this.ownerId});
}
