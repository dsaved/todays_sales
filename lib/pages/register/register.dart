import 'dart:async';
import 'dart:io';

import 'package:todays_sales/localization/LocalText.dart';
import 'package:todays_sales/models/user.dart';
import 'package:todays_sales/network/rest_ds.dart';
import 'package:todays_sales/pages/otp/otp.dart';
import 'package:todays_sales/resources/theme.dart' as appTheme;
import 'package:todays_sales/utils/constant.dart';
import 'package:todays_sales/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterPage extends StatefulWidget {
  static const String tag = "register-page";

  @override
  State<StatefulWidget> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _termsChecked = false, _isLoading = false;
  Map<String, dynamic> userData = new Map();
  String password, fullName, phone, source;

  RegisterPageState() {
    initDeviceData();
  }

  @override
  void initState() {
    super.initState();
  }

  Future initDeviceData() async {
    this.source = Platform.operatingSystem;
  }

  @override
  Widget build(BuildContext context) {
    void _launchURL() async {
      const url = Constant.terms_and_condition;
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        MyToast.showToast(context,LocalText.of(context).load('could_not_launch') + url);
      }
    }

    final termsCondition = MaterialButton(
      onPressed: _launchURL,
      textColor: Colors.white,
      child: Text(LocalText.of(context).load('read_and_accept_terms')),
    );

    void _validateForms() {
      final form = _formKey.currentState;
      form.save();
      if (fullName.isEmpty) {
        MyToast.showToast(context,LocalText.of(context).load('fullname_hint'));
      } else if (phone.isEmpty) {
        MyToast.showToast(context,LocalText.of(context).load("phone_required"));
      } else if (phone.length < 10) {
        MyToast.showToast(context,LocalText.of(context).load("incorrect_phone"));
      } else if (password.isEmpty) {
        MyToast.showToast(context,LocalText.of(context).load("password_required"));
      } else if (password.length < 4) {
        MyToast.showToast(context,LocalText.of(context).load("password_shot"));
      } else if (!_termsChecked) {
        // The checkbox wasn't checked
        MyToast.showToast(context,LocalText.of(context).load("accept_terms_condition"));
      } else {
        // Every of the data in the form are valid at this point
        setState(() => _isLoading = true);
        RestDatasource request = new RestDatasource();
        request
            .register(fullName, phone, password, context)
            .then((Map response) {
          if (response['success']) {
            onRegisterSuccess();
          } else {
            onRegisterError(response['message']);
          }
        });
      }
    }

    final logoImage = Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(LocalText.of(context).load('register_title'),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 27.00,
                  fontWeight: FontWeight.w700)),
          Padding(
            padding: EdgeInsets.only(bottom: 15.00),
          ),
        ],
      ),
    );

    final backgroundImage = Container(
        decoration: BoxDecoration(
      color: appTheme.AppColors.indigoMaterial,
    ));

    final terms = Container(
      decoration: BoxDecoration(
          shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(5.0)),
      child: CheckboxListTile(
          activeColor: appTheme.AppColors.pinkMaterial[300],
          title: new Text(
            LocalText.of(context).load("terms_condition"),
            style: TextStyle(color: Colors.white),
          ),
          value: _termsChecked,
          onChanged: (bool value) => setState(() => _termsChecked = value)),
    );

    final passwordField = Container(
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0)),
        child: TextFormField(
          textInputAction: TextInputAction.done,
          autofocus: false,
          onSaved: (String value) {
            password = value;
          },
          decoration: InputDecoration(
              hintText: LocalText.of(context).load("password_hint"),
              hintStyle: TextStyle(
                color: Colors.black,
              ),
              contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
              prefixIcon: Icon(
                Icons.password,
                color: appTheme.AppColors.pink[500],
              ),
              border: InputBorder.none),
          style: TextStyle(color: Colors.black),
          keyboardType: TextInputType.text,
          obscureText: true,
        ));

    final fullNameField = Container(
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0)),
        child: TextFormField(
          textInputAction: TextInputAction.next,
          autofocus: false,
          onSaved: (String value) {
            fullName = value;
          },
          decoration: InputDecoration(
              hintText: LocalText.of(context).load("fullname_hint"),
              hintStyle: TextStyle(
                color: Colors.black,
              ),
              contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
              prefixIcon: Icon(
                Icons.account_circle,
                color: appTheme.AppColors.pink[500],
              ),
              border: InputBorder.none),
          style: TextStyle(
            color: Colors.black,
          ),
          keyboardType: TextInputType.text,
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
            phone = value;
          },
          decoration: InputDecoration(
              hintText: LocalText.of(context).load("phone_hint"),
              hintStyle: TextStyle(
                color: Colors.black,
              ),
              contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
              prefixIcon: Icon(
                Icons.phone,
                color: appTheme.AppColors.pink[500],
              ),
              border: InputBorder.none),
          style: TextStyle(
            color: Colors.black,
          ),
          keyboardType: TextInputType.phone,
        ));

    final backToButton = Expanded(
      child: MaterialButton(
        onPressed: () {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        },
        textColor: Colors.white,
        child: Text(LocalText.of(context).load("back_to_login")),
      ),
    );

    final registerButton = Expanded(
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
          : Text(LocalText.of(context).load("register")),
      splashColor: appTheme.AppColors.pinkMaterial[300],
    ));

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
                    Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Theme(
                          data: ThemeData(
                              brightness: Brightness.dark,
                              primarySwatch: appTheme.AppColors.pinkMaterial,
                              inputDecorationTheme: InputDecorationTheme(
                                  hintStyle: TextStyle(
                                    color: Colors.black,
                                  ),
                                  labelStyle: TextStyle(
                                      color: appTheme
                                          .AppColors.pinkMaterial[500]))),
                          child: Container(
                            padding:
                                const EdgeInsets.only(left: 35.0, right: 35.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                logoImage,
                                fullNameField,
                                Padding(
                                    padding: const EdgeInsets.only(top: 10.0)),
                                phoneField,
                                Padding(
                                    padding: const EdgeInsets.only(top: 10.0)),
                                passwordField,
                                Padding(
                                    padding: const EdgeInsets.only(top: 10.0)),
                                termsCondition,
                                terms,
                                Container(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      backToButton,
                                      registerButton,
                                    ],
                                  ),
                                ),
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

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: appTheme.AppColors.indigoMaterial,
      body: SafeArea(child: Stack(
        fit: StackFit.expand,
        children: <Widget>[backgroundImage, pageContent],
      )),
    );
  }

  onRegisterError(String errorTxt) {
    MyToast.showToast(context, errorTxt);
    setState(() => _isLoading = false);
  }

  onRegisterSuccess() async {
    setState(() => _isLoading = false);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OTPPage(
            phone: phone,
          ),
        ));
  }

}
