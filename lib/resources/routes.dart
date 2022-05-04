import 'package:todays_sales/pages/home.dart';
import 'package:todays_sales/pages/login/login.dart';
import 'package:todays_sales/pages/register/register.dart';
import 'package:flutter/material.dart';

final routes = {
  LoginPage.tag: (BuildContext context) => new LoginPage(),
  MyHomePage.tag: (BuildContext context) => new MyHomePage(),
  RegisterPage.tag: (BuildContext context) => new RegisterPage(),
};
