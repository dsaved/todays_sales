import 'dart:core';

import 'package:todays_sales/dbhandler/databaseHelper.dart';

class CurrentUser {
  int id = 0;
  String name, email, img, phone, password, type,gender, address;
  DatabaseHelper db;
  Map<String, dynamic> _user;

   getUser() async {
    db = new DatabaseHelper();
    _user = await db.getUser();
    this.id = int.parse(_user[DatabaseHelper.KEY_UID].toString());
    this.name = _user[DatabaseHelper.KEY_NAME];
    this.phone = _user[DatabaseHelper.KEY_PHONE];
    this.type = _user[DatabaseHelper.KEY_TYPE];
    this.gender = _user[DatabaseHelper.KEY_GENDER];
    this.address = _user[DatabaseHelper.KEY_ADDRESS];
  }

  String getEmail() {
    return email;
  }

  String getImg() {
    return img;
  }

  String getPhone() {
    return phone;
  }

  String getName() {
    return name;
  }

  int getId() {
    return id;
  }

  String getType() {
    return type;
  }

  String getGender(){
     return gender;
  }

  String getAddress(){
     return address;
  }
}
