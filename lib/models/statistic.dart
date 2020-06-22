import 'dart:convert';

class Statistic {
  DateTime date;
  String name;

  Statistic.fromJson(Map<String, dynamic> json)
      : date = DateTime.parse(json['date']),
        name = json['name'];

  Map<String, dynamic> toJson() => {
        'date': date,
        'name': name,
      };
  Statistic({
    this.date,
    this.name,
  });
}
