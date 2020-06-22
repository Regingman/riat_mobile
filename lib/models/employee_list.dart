class EmployeeList {
  int id;
  int orderId;
  String name;
  bool flag = false;

  EmployeeList.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        orderId = json['orderId'],
        name = json['name'];

   Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'name': name,
      };
  EmployeeList({
    this.orderId,
    this.id,
    this.name,
  });
}
