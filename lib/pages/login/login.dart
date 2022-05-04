import 'dart:async';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:todays_sales/dbhandler/databaseHelper.dart';
import 'package:flutter/services.dart';
import 'package:todays_sales/localization/LocalText.dart';
import 'package:todays_sales/models/user.dart';
import 'package:todays_sales/network/rest_ds.dart';
import 'package:todays_sales/pages/home.dart';
import 'package:todays_sales/pages/otp/otp.dart';
import 'package:todays_sales/pages/recover/recover.dart';
import 'package:todays_sales/pages/register/register.dart';
import 'package:todays_sales/resources/theme.dart' as appTheme;
import 'package:todays_sales/resources/user_type.dart';
import 'package:todays_sales/utils/constant.dart';
import 'package:todays_sales/utils/utils.dart';
import 'package:todays_sales/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';

class LoginPage extends StatefulWidget {
  static const String tag = "login-page";

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  Map<String, dynamic> userData = new Map();
  SharedPreferences prefs;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String username, password, source, user_type, userType,storeCode;

  LoginPageState() {
    initDeviceData();
  }

  @override
  void initState() {
    super.initState();
  }

  Future initDeviceData() async {
    this.source = Platform.operatingSystem;
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    void _validateForms() {
      final form = _formKey.currentState;
      form.save();
      if (user_type == null || user_type.isEmpty) {
        MyToast.showToast(context,LocalText.of(context).load("usertype_required"));
      }else if (username.isEmpty) {
        MyToast.showToast(context,LocalText.of(context).load('user_required'));
      } else if (password.isEmpty) {
        MyToast.showToast(context,LocalText.of(context).load('password_required'));
      } else {
        // Every of the data in the form are valid at this point
        setState(() => _isLoading = true);
        RestDatasource request = new RestDatasource();
        String user_type_ = UserType.getUserTypeCode(user_type);
        request
            .login(username, password, user_type_, storeCode, context)
            .then((Map response) {
          if (response['success']) {
            if(user_type == UserType.getUserType('sales_agent')) {
              print(response['store_code']);
              prefs.setString(Constant.storeCodePrefs, response['store_code']);
            }
            if (response['user'].type == "store_owner" &&
                response['verified'] == false) {
              onVerifyPhone(response['user'].phone);
            } else {
              MyToast.showToast(context,response['message']);
              onLoginSuccess(response['user']);
            }
          } else {
            onLoginError(response['message']);
          }
        });
      }
    }

    final backgroundImage = Container(
        decoration: BoxDecoration(
      color: appTheme.AppColors.indigoMaterial,
    ));

    final passwordField = Container(
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0)),
        child: TextFormField(
          textInputAction: TextInputAction.done,
          obscuringCharacter: '#',
          autofocus: false,
          onSaved: (String value) {
            password = value;
          },
          onFieldSubmitted: (_) => _validateForms(),
          decoration: InputDecoration(
              hintText: LocalText.of(context).load('password_hint'),
              contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
              prefixIcon: Icon(
                Icons.password,
                color: appTheme.AppColors.pinkMaterial,
              ),
              border: InputBorder.none),
          style: TextStyle(color: Colors.black),
          keyboardType: TextInputType.text,
          obscureText: true,
        ));

    final phoneField = Container(
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0)),
        child: TextFormField(
          textInputAction: TextInputAction.next,
          autofocus: false,
          onSaved: (String value) {
            username = value;
          },
          decoration: InputDecoration(
              hintText: LocalText.of(context).load('phone_hint'),
              contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
              prefixIcon: Icon(
                Icons.phone,
                color: appTheme.AppColors.pinkMaterial,
              ),
              border: InputBorder.none),
          style: TextStyle(
            color: Colors.black,
          ),
          keyboardType: TextInputType.phone,
        ));


    final userTypeField = Container(
      width: double.infinity,
      color: Colors.white,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.person,
                  color: appTheme.AppColors.pink[500],
                ),
                SizedBox(
                  width: 10,
                ),
                LocalText.of(context).show(
                  "account_hint",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          style: TextStyle(
            color: Colors.black,
          ),
          value: user_type,
          onChanged: (String newValue) {
            setState(() {
              user_type = newValue;
            });
          },
          items: UserType.getUserTypeList()
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.person,
                      color: appTheme.AppColors.pink[500],
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      Utils.truncate(value, 25, "..."),
                      style: TextStyle(
                          fontSize: 12.5,
                          color: appTheme.AppColors.pinkMaterial),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );

    final cannotLoginButton = Expanded(
      child: MaterialButton(
        onPressed: () {
          Navigator.of(context).pushNamed(RecoverPage.tag);
        },
        textColor: Colors.white,
        child: Text(LocalText.of(context).load('cant_login')),
      ),
    );

    final loginButton = Expanded(
        child: MaterialButton(
      onPressed: _validateForms,
      color: appTheme.AppColors.pinkMaterial[700],
      textColor: Colors.white,
      child: _isLoading
          ? CollectionScaleTransition(
              children: <Widget>[
                Icon(Icons.keyboard_arrow_right),
                Icon(Icons.keyboard_arrow_right),
                Icon(Icons.keyboard_arrow_right),
              ],
            )
          : Text(LocalText.of(context).load('login')),
      splashColor: appTheme.AppColors.pinkMaterial[400],
    ));

    final skipButton = MaterialButton(
      onPressed: skipRegistration,
      color: appTheme.AppColors.pinkMaterial[700],
      textColor: Colors.white,
      child: Text(LocalText.of(context).load('skip')),
      splashColor: appTheme.AppColors.pinkMaterial[400],
    );

    final registerPageButton = MaterialButton(
      onPressed: () {
        Navigator.of(context).pushNamed(RegisterPage.tag);
      },
      textColor: Colors.white,
      child: Text(LocalText.of(context).load('not_registered')),
    );

    var pageContent = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 420.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      Constant.todays_sales_splash,
                      width: 300,
                    ),
                    Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Theme(
                          data: ThemeData(
                              brightness: Brightness.light,
                              primarySwatch: appTheme.AppColors.orangeMaterial,
                              inputDecorationTheme: InputDecorationTheme(
                                  labelStyle: TextStyle(
                                      color: appTheme
                                          .AppColors.orangeMaterial[500]))),
                          child: Container(
                            padding:
                                const EdgeInsets.only(left: 35.0, right: 35.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                LocalText.of(context).show("login_title",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 27.0,
                                        fontWeight: FontWeight.bold)),
                                Padding(
                                    padding: const EdgeInsets.only(top: 10.0)),
                                userTypeField,
                                Padding(
                                    padding: const EdgeInsets.only(top: 10.0)),
                                phoneField,
                                Padding(
                                    padding: const EdgeInsets.only(top: 10.0)),
                                passwordField,
                                Container(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      cannotLoginButton,
                                      loginButton,
                                    ],
                                  ),
                                ),
                                registerPageButton,
//                                SizedBox(height: 2),
                                skipButton
                              ],
                            ),
                          ),
                        ))
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    Widget pageData = Stack(
      fit: StackFit.expand,
      children: <Widget>[backgroundImage, pageContent],
    );

    Widget widget = Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: appTheme.AppColors.indigoMaterial,
      body: SafeArea(child: pageData),
    );

    return widget;
  }

  onLoginError(String errorTxt) {
    MyToast.showToast(context,errorTxt);
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  onLoginSuccess(User user) async {
    setState(() => _isLoading = false);
    var db = new DatabaseHelper();
    await db.saveUser(user);
    this.userData = await db.getUser();
    home();
  }

  onVerifyPhone(String phone) async {
    setState(() => _isLoading = false);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OTPPage(
            phone: phone,
          ),
        ));
  }

  skipRegistration() async {
    setState(() => _isLoading = false);
    var db = new DatabaseHelper();
    await db.saveUser(User.skip());
    this.userData = await db.getUser();
    home();
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
