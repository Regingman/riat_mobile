import 'dart:math';

import 'package:my_first_flutter_project/domain/data.dart';


List<DateModel> getDates(){

  List<DateModel> dates = new List<DateModel>();
  DateModel dateModel = new DateModel();

  //1
  dateModel.date = "27";
  dateModel.weekDay = "Пн";
  dates.add(dateModel);

  dateModel = new DateModel();

  //1
  dateModel.date = "28";
  dateModel.weekDay = "Вт";
  dates.add(dateModel);

  dateModel = new DateModel();


  //1
  dateModel.date = "29";
  dateModel.weekDay = "Ср";
  dates.add(dateModel);

  dateModel = new DateModel();

  //1
  dateModel.date = "30";
  dateModel.weekDay = "Чт";
  dates.add(dateModel);

  dateModel = new DateModel();


  //1
  dateModel.date = "1";
  dateModel.weekDay = "Пт";
  dates.add(dateModel);

  dateModel = new DateModel();


  //1
  dateModel.date = "2";
  dateModel.weekDay = "Вск";
  dates.add(dateModel);

  dateModel = new DateModel();


  //1
  dateModel.date = "3";
  dateModel.weekDay = "Пн";
  dates.add(dateModel);

  dateModel = new DateModel();

  return dates;

}

