import 'package:todays_sales/dbhandler/databaseHelper.dart';

import '../utils/constant.dart';

class User {
  String _name, _type, _gender, _address, _phone, _auth;
  int _id;

  User(this._id, this._name, this._type, this._gender, this._address,
      this._phone, this._auth);

  User.map(dynamic obj) {
    this._name = obj['name'];
    this._phone = obj['phone'];
    this._type = obj['type'];
    this._gender = obj['gender'];
    this._address = obj['address'];
    this._id = int.tryParse(obj['userid'].toString());
    this._auth = obj['auth'];
  }

  User.skip() {
    this._name = Constant.gestuser;
    this._phone = Constant.gestuserPhone;
    this._type = 'store_owner';
    this._address = 'No Address';
    this._gender = 'NA';
    this._id = 0;
    this._auth = 'noauthprovied';
  }

  String get name => _name;

  String get type => _type;

  int get userId => _id;

  String get phone => _phone;

  String get gender => _gender;

  String get address => _address;

  String get auth => _auth;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map[DatabaseHelper.KEY_NAME] = _name;
    map[DatabaseHelper.KEY_PHONE] = _phone;
    map[DatabaseHelper.KEY_GENDER] = _gender;
    map[DatabaseHelper.KEY_ADDRESS] = _address;
    map[DatabaseHelper.KEY_UID] = _id;
    map[DatabaseHelper.KEY_TYPE] = _type;
    map[DatabaseHelper.KEY_AUTH] = _auth;
    return map;
  }
}
