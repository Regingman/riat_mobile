class OrderList {
  int id;
  String name;

  OrderList.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        name = json['name'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
  OrderList({
    this.id,
    this.name,
  });
}
