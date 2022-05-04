import 'dart:async';

import 'package:todays_sales/dbhandler/databaseHelper.dart';
import 'package:todays_sales/pages/home.dart';
import 'package:todays_sales/pages/login/login.dart';
import 'package:todays_sales/resources/theme.dart' as appTheme;
import 'package:todays_sales/utils/constant.dart';
import 'package:flutter/material.dart';

class DispatchPage extends StatefulWidget {
  static const String tag = "dispatch-page";

  @override
  State<StatefulWidget> createState() => DispatchPageState();
}

class DispatchPageState extends State<DispatchPage> {
  DatabaseHelper db = DatabaseHelper.internal();
  bool isLoggedIn = false;
  Map<String, dynamic> userData = new Map();
  var _user;

  DispatchPageState() {
    checkLoggedin();
    initialize();
  }

  Future checkLoggedin() async {
    isLoggedIn = await db.isLoggedIn();
    setState(() {
      isLoggedIn = isLoggedIn;
    });
  }

  initialize() async {
    await loadUser();
    new Timer(new Duration(seconds: 2), handleTimeout);
  }

  loadUser() async {
    _user = await db.getUser();
    this.userData = _user;
  }

  Widget build(BuildContext context) {
    final backgroundImage = Container(
        decoration: BoxDecoration(
      color: appTheme.AppColors.indigoMaterial,
    ));

    double top = MediaQuery.of(context).size.height/5;
    return Scaffold(
      backgroundColor: appTheme.AppColors.backGroundColor,
      body: Container(
        constraints: BoxConstraints(maxWidth: 420.0),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            backgroundImage,
            Image.asset(
              Constant.splashBg,
              fit: BoxFit.fitHeight,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: top),
                  child: Image.asset(
                      Constant.todays_sales_splash,
                    width: 300,),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void handleTimeout() {
    if (isLoggedIn) {
      home();
    } else {
      login();
    }
  }

  void login() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ));
  }

  void home() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(
            data: this.userData,
          ),
        ));
  }
}
