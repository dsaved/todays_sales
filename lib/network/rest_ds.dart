import 'dart:async';
import 'dart:io';

import 'package:todays_sales/models/user.dart';
import 'package:todays_sales/network/network_util.dart';
import 'package:todays_sales/utils/constant.dart';
import 'package:flutter/material.dart';

class RestDatasource {
  NetworkUtil _netUtil = new NetworkUtil();
  bool _success = false, _verified = false;
  String _message, _storeCode;
  User _userdata;

  Future<Map<dynamic, dynamic>> login(
      String username, String password, String userType, String storeCode, BuildContext context) {
    String loginUrl = (userType == 'store_owner')
        ? Constant.login_store_owner
        : Constant.login_agent;
    return _netUtil.post(loginUrl, context, body: {
      "user": username.trim(),
      "password": password.trim(),
      "store_code": storeCode,
    }).then((dynamic res) {
      _message = res["message"];
      _success = res["success"];
      _verified = res["verified"];
      _storeCode = res["store_code"];
      _userdata = (res["success"] == true) ? User.map(res["user"]) : null;

      var map = new Map<String, dynamic>();
      map["success"] = _success;
      map["verified"] = _verified;
      map["store_code"] = _storeCode;
      map["message"] = _message;
      map["user"] = _userdata;
      return map;
    });
  }

  Future<Map<dynamic, dynamic>> register(
      String fullName, String phone, String password, BuildContext context) {
    return _netUtil.post(Constant.register, context, body: {
      "name": fullName,
      "phone": phone.trim(),
      "password": password.trim(),
    }).then((dynamic res) {
      _success = res["success"];
      _message = res["message"];

      var map = new Map<String, dynamic>();
      map["success"] = _success;
      map["message"] = _message;
      return map;
    });
  }

  Future<Map<dynamic, dynamic>> recover(String phone, BuildContext context) {
    return _netUtil.post(Constant.recover, context, body: {
      "phone": phone,
    }).then((dynamic res) {
      _message = res["message"];
      _success = res["success"];

      var map = new Map<String, dynamic>();
      map["success"] = _success;
      map["message"] = _message;
      return map;
    });
  }

  Future<Map<dynamic, dynamic>> verifyPhone(
      String phone,String code, BuildContext context) {
    return _netUtil.post(Constant.verify, context, body: {
      "phone": phone,
      "code": code,
    }).then((dynamic res) {
      _success = res["success"];
      _message = res["message"];
      _userdata = (res["success"] == true) ? User.map(res["user"]) : null;

      var map = new Map<String, dynamic>();
      map["success"] = _success;
      map["message"] = _message;
      map["user"] = _userdata;
      return map;
    });
  }

  Future<Map<dynamic, dynamic>> resendCode(
      String phone,BuildContext context) {
    return _netUtil.post(Constant.resend_code, context, body: {
      "phone": phone,
    }).then((dynamic res) {
      _success = res["success"];
      _message = res["message"];

      var map = new Map<String, dynamic>();
      map["success"] = _success;
      map["message"] = _message;
      return map;
    });
  }
}
