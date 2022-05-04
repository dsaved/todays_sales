import 'package:todays_sales/dbhandler/databaseHelper.dart';
import 'package:todays_sales/localization/LocalText.dart';
import 'package:todays_sales/models/CurrentUser.dart';
import 'package:todays_sales/models/user.dart';
import 'package:todays_sales/network/network_util.dart';
import 'package:todays_sales/resources/theme.dart' as appTheme;
import 'package:todays_sales/utils/constant.dart';
import 'package:todays_sales/widgets/toast.dart';
import 'package:todays_sales/utils/utils.dart';
import 'package:todays_sales/widgets/Dialogs.dart';
import 'package:flutter/services.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef void ProfileUpdated(Map<String, dynamic> success);

// ignore: must_be_immutable
class EditProfilePage extends StatefulWidget {
  static const String tag = "profileUpade-page";

  EditProfilePage({@required this.user, @required this.updatedUser});

  Map<String, dynamic> user;
  ProfileUpdated updatedUser;

  @override
  State<StatefulWidget> createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  String name = "",
      gender = "",
      phone = "",
      address = "",
      oldpassword = "",
      newpassword = "",
      newpassword2 = "";

  NetworkUtil _netUtil = new NetworkUtil();
  var _user;
  bool edited = false, change_password = false;
  TextEditingController nameInputController,
      phoneInputController,
      addressInputController,
      oldpasswordInputController,
      newpasswordInputController,
      newpassword2InputController;
  Dialogs dialogs;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    dialogs = new Dialogs();
    initialize();
  }

  @override
  void dispose() {
    nameInputController.dispose();
    phoneInputController.dispose();
    addressInputController.dispose();

    newpasswordInputController.dispose();
    newpassword2InputController.dispose();
    oldpasswordInputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  initialize() async {
    await loadUser();
  }

  _scrollToBottom() async {
    double height = MediaQuery.of(context).size.height;
    _scrollController.animateTo(height,
        duration: Duration(milliseconds: 1500), curve: Curves.ease);
  }

  loadUser() async {
    _user = widget.user;
    setState(() {
      this.name = _user["name"];
      this.gender = Utils.isNotEmpty(_user["gender"]) ? _user["gender"] : null;
      this.phone = _user["phone"];
      this.address = _user["address"];
    });

    nameInputController = TextEditingController(text: name);
    phoneInputController = TextEditingController(text: phone);
    addressInputController = TextEditingController(text: address);

    newpasswordInputController = TextEditingController();
    newpassword2InputController = TextEditingController();
    oldpasswordInputController = TextEditingController();
    initializeControllers();
  }

  initializeControllers() {
    nameInputController.addListener(() {
      if (nameInputController.text.isNotEmpty &&
          nameInputController.text != name) {
        if (mounted)
          setState(() {
            edited = true;
          });
      }
    });

    phoneInputController.addListener(() {
      if (phoneInputController.text.isNotEmpty &&
          phoneInputController.text != phone) {
        if (mounted)
          setState(() {
            edited = true;
          });
      }
    });

    addressInputController.addListener(() {
      if (addressInputController.text.isNotEmpty &&
          addressInputController.text != address) {
        if (mounted)
          setState(() {
            edited = true;
          });
      }
    });
  }

  updateUser() async {
    if (nameInputController.text.isNotEmpty) {
      var user_type = await DatabaseHelper.internal().userType();
      Map data = new Map();
      data['name'] = nameInputController.text;
      data['phone'] = phoneInputController.text;
      data['id'] = _user['id'];
      data['address'] = addressInputController.text;
      data['gender'] = gender;

      final String paramUrl = user_type == 'store_owner'
          ? Constant.store_owner_update_user
          : Constant.sales_agent_update_user;

      //show loading
      dialogs.loading(context, LocalText.of(context).load('updating_account'),
          Dialogs.SLIDE_TRANSITION);
      print(data);
      _netUtil
          .post(paramUrl, context, body: data)
          .then((value) {
            dialogs.close(context);
            if (value['success'] == true) {
              MyToast.showToast(context,
                  "${LocalText.of(context).load("success_update")}");
              saveUser();
            } else {
              MyToast.showToast(context,
                  "${LocalText.of(context).load("failed_update")}");
            }
          })
          .timeout(Duration(seconds: 55))
          .catchError((error) {
            print("Error $error");
            MyToast.showToast(context,"$error");
          });
    }
  }

  saveUser() async {
    var authentication = await DatabaseHelper.internal().authentication();
    var user_type = await DatabaseHelper.internal().userType();
    Map<String, dynamic> data = new Map();
    data['userid'] = _user['id'];
    data['name'] = nameInputController.text;
    data['phone'] = phoneInputController.text;
    data['address'] = addressInputController.text;
    data['gender'] = gender;
    data['type'] = user_type;
    data['auth'] = authentication;

    var db = new DatabaseHelper();
    await db.updateUser(User.map(data));

    data['uid'] = _user['id'];

    widget.updatedUser(data);
    MyToast.showToast(context,"${LocalText.of(context).load("success_update")}");
    Navigator.of(context).pop();
  }

  Widget build(BuildContext context) {
    final genderField = Container(
      width: double.infinity,
      color: Colors.white,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.account_circle_sharp,
                  color: appTheme.AppColors.pink[500],
                ),
                SizedBox(
                  width: 10,
                ),
                LocalText.of(context).show(
                  "gender_hint",
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
          value: gender,
          onChanged: (String newValue) {
            setState(() {
              gender = newValue;
              edited = true;
            });
          },
          items: ['male', 'female', 'other']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.account_circle_sharp,
                      color: appTheme.AppColors.pink[500],
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      value,
                      style: TextStyle(fontSize: 14.5, color: Colors.black),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: appTheme.AppColors.backGroundColor,
      key: _scaffoldKey,
      appBar: new AppBar(
        elevation: 0,
        actions: <Widget>[
          (edited)
              ? IconButton(
                  icon: Icon(Icons.done_all),
                  onPressed: updateUser,
                )
              : Container(),
        ],
        title: Text(LocalText.of(context).load("edit_profile")),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: <Widget>[
            Container(
              color: appTheme.AppColors.pinkMaterial,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 42, right: 42, bottom: 2, top: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  LocalText.of(context).load('name'),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5.0)),
                                  child: TextFormField(
                                    autofocus: false,
                                    controller: nameInputController,
                                    decoration: InputDecoration(
                                        hintText: LocalText.of(context)
                                            .load('fullname_hint'),
                                        prefixIcon: Icon(
                                          Icons.person,
                                          color:
                                              appTheme.AppColors.pinkMaterial,
                                        ),
                                        contentPadding: EdgeInsets.fromLTRB(
                                            20.0, 15.0, 15.0, 15.0),
                                        border: InputBorder.none),
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                    keyboardType: TextInputType.text,
                                  )),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            //second action set
            Container(
              padding: EdgeInsets.only(right: 42, left: 42, top: 2, bottom: 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            LocalText.of(context).load('mobile'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5.0)),
                          child: TextFormField(
                            enabled: false,
                            autofocus: false,
                            controller: phoneInputController,
                            decoration: InputDecoration(
                                hintText:
                                    LocalText.of(context).load('phone_hint'),
                                prefixIcon: Icon(
                                  Icons.phone,
                                  color: appTheme.AppColors.pinkMaterial,
                                ),
                                contentPadding:
                                    EdgeInsets.fromLTRB(20.0, 15.0, 15.0, 15.0),
                                border: InputBorder.none),
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            LocalText.of(context).load('sex'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5.0)),
                          child: genderField,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            LocalText.of(context).load('address'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5.0)),
                          child: TextFormField(
                            autofocus: false,
                            maxLines: 3,
                            controller: addressInputController,
                            decoration: InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                hintText:
                                    LocalText.of(context).load('address_hint'),
                                prefixIcon: Icon(
                                  Icons.location_on,
                                  color: appTheme.AppColors.pinkMaterial,
                                ),
                                contentPadding:
                                    EdgeInsets.fromLTRB(20.0, 15.0, 15.0, 15.0),
                                border: InputBorder.none),
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            keyboardType: TextInputType.multiline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: CupertinoButton(
                      pressedOpacity: 0.7,
                      onPressed: togglePasswordChange,
                      child: !change_password
                          ? LocalText.of(context).show('enable_password_change')
                          : LocalText.of(context)
                              .show('disable_password_change'),
                    ),
                  ),
                  change_password
                      ? Form(
                          child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      LocalText.of(context)
                                          .load("current_password"),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: Colors.white,
                                        border: Border.all(color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    child: TextFormField(
                                      obscuringCharacter: '#',
                                      autofocus: false,
                                      controller: oldpasswordInputController,
                                      decoration: InputDecoration(
                                          hintText: LocalText.of(context)
                                              .load("enter_current_password"),
                                          prefixIcon: Icon(
                                            Icons.password,
                                            color:
                                                appTheme.AppColors.pinkMaterial,
                                          ),
                                          contentPadding: EdgeInsets.fromLTRB(
                                              20.0, 15.0, 15.0, 15.0),
                                          border: InputBorder.none),
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                      obscureText: true,
                                      keyboardType: TextInputType.text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      LocalText.of(context)
                                          .load("new_password"),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: Colors.white,
                                        border: Border.all(color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    child: TextFormField(
                                      obscuringCharacter: '#',
                                      autofocus: false,
                                      controller: newpasswordInputController,
                                      decoration: InputDecoration(
                                          hintText: LocalText.of(context)
                                              .load('enter_new_password'),
                                          prefixIcon: Icon(
                                            Icons.password,
                                            color:
                                                appTheme.AppColors.pinkMaterial,
                                          ),
                                          contentPadding: EdgeInsets.fromLTRB(
                                              20.0, 15.0, 15.0, 15.0),
                                          border: InputBorder.none),
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                      obscureText: true,
                                      keyboardType: TextInputType.text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      LocalText.of(context)
                                          .load("retype_password"),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: Colors.white,
                                        border: Border.all(color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    child: TextFormField(
                                      obscuringCharacter: '#',
                                      autofocus: false,
                                      controller: newpassword2InputController,
                                      decoration: InputDecoration(
                                          hintText: LocalText.of(context)
                                              .load("retype_password_again"),
                                          prefixIcon: Icon(
                                            Icons.password,
                                            color:
                                                appTheme.AppColors.pinkMaterial,
                                          ),
                                          contentPadding: EdgeInsets.fromLTRB(
                                              20.0, 15.0, 15.0, 15.0),
                                          border: InputBorder.none),
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                      obscureText: true,
                                      keyboardType: TextInputType.text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: CupertinoButton(
                                color: appTheme.AppColors.pinkMaterial,
                                pressedOpacity: 0.7,
                                onPressed: changePassword,
                                child: LocalText.of(context)
                                    .show("change_password"),
                              ),
                            ),
                          ],
                        ))
                      : Container(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  togglePasswordChange() {
    setState(() {
      change_password = !change_password;
      newpasswordInputController.text = "";
      newpassword2InputController.text = "";
      oldpasswordInputController.text = "";
    });
    if (change_password) {
      _scrollToBottom();
    }
  }

  changePassword() async{
    if (newpasswordInputController.text.isNotEmpty &&
        newpassword2InputController.text.isNotEmpty &&
        oldpasswordInputController.text.isNotEmpty) {
      if (newpasswordInputController.text == newpassword2InputController.text) {
        // send data online
        Map<String, dynamic> data = new Map();
        data['id'] = _user['id'];
        data['oldpassword'] = oldpasswordInputController.text;
        data['password'] = newpasswordInputController.text;

        var user_type = await DatabaseHelper.internal().userType();
        final String paramUrl = user_type == 'store_owner'
            ? Constant.store_owner_change_user_password
            : Constant.sales_agent_change_user_password;

        //show loading
        dialogs.loading(
            context,
            LocalText.of(context).load('changing_password'),
            Dialogs.SLIDE_TRANSITION);
        _netUtil
            .post(paramUrl, context, body: data)
            .then((value) {
              //stop loading
              dialogs.close(context);
              if (Utils.isSuccess(value)) {
                //togglePasswordChange();
                MyToast.showToast(context,
                    "${LocalText.of(context).load("password_changed")}");
                saveUser();
              } else {
                MyToast.showToast(context,value['message']);
              }
            })
            .timeout(Duration(seconds: 55))
            .catchError((error) {
              print("Error $error");
              MyToast.showToast(context,"$error");
            });
      } else {
        MyToast.showToast(context,LocalText.of(context).load("password_not_match"));
      }
    }
  }
}
