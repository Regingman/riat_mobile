class UserMain {
  int id;
  String name;
  String telephon;
  String firstName;
  String lastName;
  String patronymic;
  int position;
  String fileName;
  String positionName;

  UserMain.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int;
    name = json['username'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    patronymic = json['patronymic'];
    telephon = json['telephone'];
    position = json['position'];
    fileName = json['fileName'];

    if (position != null) if (position == 1) {
      positionName = "горничная";
    } else {
      positionName = "Менеджер";
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'username': name,
        //'procent': procent,
        'telephon': telephon,
        //'templateTask': templateTask,
        //'termDate': termDate,
        //'createDate': createDate,
        //'updateDate': updateDate,
      };
  UserMain({
    this.id,
    this.name,
    this.telephon,
    this.patronymic,
    this.firstName,
    this.lastName,
    this.position,
  });
}
