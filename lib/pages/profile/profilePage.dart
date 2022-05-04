import 'dart:io';

import 'package:todays_sales/dbhandler/databaseHelper.dart';
import 'package:todays_sales/localization/LocalText.dart';
import 'package:todays_sales/network/network_util.dart';
import 'package:todays_sales/pages/profile/profileUpdate.dart';
import 'package:todays_sales/resources/theme.dart' as appTheme;
import 'package:todays_sales/utils/constant.dart';
import 'package:todays_sales/widgets/sliver_fab.dart';
import 'package:todays_sales/utils/utils.dart';
import 'package:todays_sales/widgets/Dialogs.dart';
import 'package:todays_sales/widgets/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
typedef userUpdated(bool);

// ignore: must_be_immutable
class ProfilePage extends StatefulWidget {
  static const String tag = "profile-page";

  ProfilePage({@required this.user, @required this.updated});

  Map<String, dynamic> user;
  userUpdated updated;

  @override
  State<StatefulWidget> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String name = "", phone = "", gender = "", address = "";
  bool otherAccount,
      profileIsInFav = false,
      _canEdit = false,
      editable = true,
      _loading = true,
      _hasError = false,
      addMessage = false;
  var _user, userData, onlineUser, widgetUser;
  List<dynamic> region_state;
  var db;
  Dialogs dialog;
  Map<String, dynamic> data = Map();
  ScrollController _scrollController;
  NetworkUtil _netUtil = new NetworkUtil();

  @override
  void initState() {
    super.initState();
    dialog = Dialogs();
    widgetUser = widget.user;
    initialize();
    _scrollController = new ScrollController();
    _scrollController.addListener(() => setState(() {}));
  }

  initialize() async {
    db = new DatabaseHelper();
    await loadUser();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  loadUser() async {
    _user = widgetUser;
    setState(() {
      this.name = _user["name"] != null ? _user["name"] : "No Name";
    });
    print("user: $_user");
    await _getUser();
  }

  _getUser() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    Map<String, dynamic> params = new Map();
    params["id"] = _user['uid'];

    final String paramUrl = _user['type'] == 'store_owner'
        ? Constant.store_owner_user_details
        : Constant.sales_agent_user_details;
    await _netUtil
        .post(paramUrl, context, body: params)
        .then((value) {
          setState(() {
            _loading = false;
          });
          if (value['success'] == true) {
            print(value['user']);
            _loadUser(value['user']);
            _canEdit = true;
          } else {
            MyToast.showToast(context,value['message']);
            setState(() {
              _loading = false;
              _hasError = true;
            });
          }
        })
        .timeout(Duration(seconds: 10))
        .catchError((error) {
          print("Error $error");
          setState(() {
            _loading = false;
            _hasError = true;
          });
        });
  }

  _loadUser(user) {
    onlineUser = user;
    setUserDetails();
  }

  setUserDetails() {
    setState(() {
      print('user gender: ${onlineUser["gender"]}');
      this.name =
          Utils.isNotEmpty(onlineUser["name"]) ? onlineUser["name"] : "No Name";
      this.phone = onlineUser["phone"];
      this.address = Utils.isNotEmpty(onlineUser["address"])
          ? onlineUser["address"]
          : "No Address";
      this.gender = Utils.isNotEmpty(onlineUser["gender"])
          ? onlineUser["gender"]
          : "No Gender Specified";
      userData = onlineUser;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SliverFab(
        floatingWidget: FloatingActionButton(
          onPressed: () {
            if (_canEdit) {
              editProfile(userData);
            }
          },
          child: Icon(Icons.edit),
        ),
        floatingPosition: FloatingPosition(right: 16),
        expandedHeight: MediaQuery.of(context).size.height / 2.2,
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height / 2.2,
            floating: false,
            pinned: true,
            snap: false,
            elevation: 50,
            flexibleSpace: FlexibleSpaceBar(
              title: Text("$name",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  )),
              background: Image.asset(
                Constant.navBarBg,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverList(
              delegate: new SliverChildListDelegate(_buildList(context))),
        ],
      ),
    );
  }

  List _buildList(context) {
    List<Widget> listItems = [];
    if (_loading) {
      listItems.add(Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Platform.isIOS
                ? CupertinoActivityIndicator(radius: 15)
                : CircularProgressIndicator(),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              "${LocalText.of(context).load("please_wait")}",
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ));
    } else if (!_hasError && !_loading) {
      listItems.add(Padding(
        padding: EdgeInsets.only(left: 45.0, right: 45.0, top: 45.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.black.withOpacity(.5),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("$gender",
                        style: TextStyle(
                          fontSize: 19.0,
                        )),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: LocalText.of(context).show("sex",
                          style: TextStyle(
                            color: Colors.black.withOpacity(.5),
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Divider(
              height: 2,
              color: Colors.grey,
              indent: 70,
            ),
          ],
        ),
      ));

      listItems.add(Padding(
        padding: EdgeInsets.only(left: 45.0, right: 45.0, top: 15.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.phone,
                    size: 30,
                    color: Colors.black.withOpacity(.5),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("$phone",
                        style: TextStyle(
                          fontSize: 19.0,
                        )),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: LocalText.of(context).show("mobile",
                          style: TextStyle(
                            color: Colors.black.withOpacity(.5),
                            fontWeight: FontWeight.bold,
                          )),
                    )
                  ],
                )
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Divider(
              height: 2,
              color: Colors.grey,
              indent: 70,
            ),
          ],
        ),
      ));

      listItems.add(Padding(
        padding: EdgeInsets.only(left: 45.0, right: 45.0, top: 15.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.location_on,
                    size: 30,
                    color: Colors.black.withOpacity(.5),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8 - 100,
                      child: Text(
                        "$address",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 19.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: LocalText.of(context).show("address",
                          style: TextStyle(
                            color: Colors.black.withOpacity(.5),
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 50,
            ),
          ],
        ),
      ));
    } else if (_hasError) {
      listItems.add(Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: CupertinoButton(
              color: appTheme.AppColors.pinkMaterial[700],
              onPressed: _getUser,
              pressedOpacity: 0.7,
              child: Text(LocalText.of(context).load("retry")),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              "${LocalText.of(context).load("error_executing_request")}",
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ));
    }
    return listItems;
  }

  editProfile(Map<String, dynamic> user) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfilePage(
              user: user,
              updatedUser: (user) {
                if (mounted) {
                  print("Returnd user: $user");
                  setState(() {
                    widgetUser = user;
                    widget.updated(true);
                  });
                }
                loadUser();
              }),
        ));
  }
}
