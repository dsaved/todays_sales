import 'dart:async';
import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todays_sales/dbhandler/databaseHelper.dart';
import 'package:todays_sales/localization/LocalText.dart';
import 'package:todays_sales/models/CurrentUser.dart';
import 'package:todays_sales/network/network_util.dart';
import 'package:todays_sales/pages/profile/profilePage.dart';
import 'package:todays_sales/pages/store/store.dart';
import 'package:todays_sales/resources/theme.dart';
import 'package:todays_sales/utils/constant.dart';
import 'package:todays_sales/widgets/Dialogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:sprintf/sprintf.dart';
import 'dart:io';

import 'package:todays_sales/widgets/toast.dart';

class StoreOwner extends StatefulWidget {
  static const String tag = "stores-page";

  StoreOwner({
    @required this.user,
    @required this.updated,
  });

  final Map<String, dynamic> user;
  final userUpdated updated;

  @override
  _StoreOwnerPageState createState() => new _StoreOwnerPageState();
}

class _StoreOwnerPageState extends State<StoreOwner>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin<StoreOwner> {
  NetworkUtil _netUtil = new NetworkUtil();
  Dialogs _alertDialog;
  bool _loading = true, _showFAB = true, _loadingMore = false, searched = false;
  SharedPreferences prefs;
  ScrollController _scrollController = new ScrollController();
  List<dynamic> stores;
  String _message = "", publicKey, encryptionKey;
  String searchText = "";

  Map<String, dynamic> pagination = Map();
  int resultPerPage = 20, page = 1;
  TextEditingController _searchInputController;

  @override
  void initState() {
    super.initState();
    initData();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        _showFAB = true;
        reloadState();
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        _showFAB = false;
        reloadState();
      }
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        //load more if view reaches last index of page
      }

      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels == 0) {
          // You're at the top.
          if (!searched) {
            page = 1;
            _getData(silent: true, page: page);
          }
        } else {
          // You're at the bottom.
          if (pagination != null &&
              pagination.isNotEmpty &&
              pagination['hasNext']) {
            page += 1;
            _getData(more: true, silent: true, page: page, search: searchText);
          }
        }
      }
    });
  }

  @override
  Future didChangeAppLifecycleState(AppLifecycleState state) async {
    if (mounted) await _getData(silent: true);
  }

  initData() async {
    _searchInputController = new TextEditingController();
    prefs = await SharedPreferences.getInstance();
    _alertDialog = new Dialogs();

    String storesPrefs = prefs.getString(Constant.storesPrefs);
    if (storesPrefs != null) {
      _loading = false;
      stores = json.decode(storesPrefs);
      reloadState();
      _getData(silent: true);
    } else {
      _getData();
    }
  }

  reloadState() {
    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _getData({more = false, silent = false, page = 1, search = ""}) async {
    if (more) {
      _loadingMore = true;
      setState(() {});
    }
    if (!silent) {
      setState(() {
        _loading = true;
      });
    }

    Map<String, dynamic> params = new Map();
    params["result_per_page"] = resultPerPage;
    params["search"] = search;
    params["owner"] = widget.user['uid'];
    params["page"] = page;

    await _netUtil
        .post("${Constant.get_stores}", context, body: params)
        .then((value) {
          setState(() {
            _loading = false;
            _loadingMore = false;
          });
          pagination = value['pagination'];
          if (value['success'] == true) {
            if (more) {
              stores.insertAll(stores.length, value['stores']);
            } else {
              _loading = false;
              stores = value['stores'];
              prefs.setString(Constant.storesPrefs, json.encode(stores));
              reloadState();
            }
            _loading = false;
            setState(() {});
          } else {
            _message = "${value['message']}";
            _loading = false;
            if (!silent) {
              if (mounted) {
                setState(() {});
              }
            }
          }
        })
        .timeout(Duration(seconds: 10))
        .catchError((error) {
          print("Error $error");
          _loading = false;
          _loadingMore = false;
          reloadState();
        });
  }

  @override
  Widget build(BuildContext context) {
    Widget searchArea = Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutGrid(
        areas: '''
                header header header
                search search btn
                content content content
              ''',
        columnSizes: [auto, auto, 50.px],
        rowSizes: [auto, auto, auto],
        columnGap: 12,
        rowGap: 12,
        children: [
          Container(
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white,
                border:
                    Border.all(width: 1, color: AppColors.greyMaterial[300]),
                borderRadius: BorderRadius.circular(5.0)),
            child: TextFormField(
              autofocus: false,
              controller: _searchInputController,
              onSaved: (String value) {},
              decoration: InputDecoration(
                  hintText: LocalText.of(context).load('store-search'),
                  contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                  border: InputBorder.none),
              style: TextStyle(
                color: Colors.black,
              ),
              keyboardType: TextInputType.text,
            ),
          ).inGridArea('search'),
          TextButton(
            onPressed: () {
              String result = _searchInputController.text;
              if (result != null) {
                stores = [];
                page = 1;
                searched = true;
                searchText = result;
                _getData(page: page, search: result);
              }
            },
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(AppColors.greyMaterial[50]),
              elevation: MaterialStateProperty.all(2.0),
            ),
            child: Icon(
              Icons.search,
              size: 30,
              color: AppColors.pinkMaterial,
            ),
          ).inGridArea('btn'),
          if (searched)
            Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 0, bottom: 10),
              child: InkWell(
                child: Text(
                  '${LocalText.of(context).load('clear-search')}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    letterSpacing: 0.0,
                    color: AppColors.greyMaterial[600],
                  ),
                ),
                onTap: () {
                  searched = false;
                  page = 1;
                  searchText = "";
                  _searchInputController.text = "";
                  if (mounted) {
                    setState(() {});
                  }
                  _getData(page: page);
                },
              ),
            ).inGridArea('content')
        ],
      ),
    );

    super.build(context);
    if (_loading) {
      return Center(
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: <Widget>[
            Column(
              children: <Widget>[
                searchArea,
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
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                Constant.splashBg,
                fit: BoxFit.fitHeight,
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: LiquidPullToRefresh(
          onRefresh: () => _getData(silent: true),
          showChildOpacityTransition: false,
          color: AppColors.pinkMaterial[200],
          child: ListView(
            controller: _scrollController,
            children: <Widget>[
              searchArea,
              SizedBox(
                height: 1.0,
              ),
              Builder(builder: (BuildContext context) {
                List<Widget> feedsData = [];
                if (stores != null && stores.isNotEmpty) {
                  for (var i = 0; i < stores.length; i++) {
                    var data = stores[i];
                    feedsData.add(GestureDetector(
                      onTap: () {
                        openStore(data);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                            top: 5, bottom: 3, left: 8, right: 8),
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              bottomLeft: Radius.circular(8.0),
                              bottomRight: Radius.circular(8.0),
                              topRight: Radius.circular(8.0)),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: AppColors.greyMaterial.withOpacity(0.4),
                                offset: Offset(1.1, 1.1),
                                blurRadius: 10.0),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -50,
                              bottom: 0,
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                child: SizedBox(
                                  height: 120,
                                  child: AspectRatio(
                                    aspectRatio: 1.714,
                                    child: Opacity(
                                        opacity: 0.2,
                                        child: Image.asset(
                                            Constant.card_bottom_left)),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: -140,
                              bottom: 0,
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                child: SizedBox(
                                  height: 175,
                                  child: AspectRatio(
                                    aspectRatio: 1.714,
                                    child: Opacity(
                                        opacity: 0.3,
                                        child: Image.asset(
                                            Constant.card_top_right)),
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    radius: 20.0,
                                    child: Icon(
                                      Icons.store,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    '${data['store_name']}'.toUpperCase(),
                                    style: TextStyle(
                                        color: AppColors.pinkMaterial,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  subtitle: Text(
                                    '${data['store_code']}',
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.9),
                                        fontWeight: FontWeight.w500),
                                  ),
                                  trailing: PopupMenuButton(
                                      icon: Icon(Icons.more_vert_sharp),
                                      elevation: 20,
                                      onSelected: (value) {
                                        if (value == 1) {
                                          updateStore(data);
                                        } else if (value == 2) {
                                          deleteStore(data);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                            PopupMenuItem(
                                              child: Text(
                                                '${LocalText.of(context).load('edit_button')}',
                                                style: TextStyle(
                                                    color: Colors.black
                                                        .withOpacity(0.9),
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              value: 1,
                                            ),
                                            PopupMenuItem(
                                              child: Text(
                                                '${LocalText.of(context).load('delete_button')}',
                                                style: TextStyle(
                                                    color: Colors.black
                                                        .withOpacity(0.9),
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              value: 2,
                                            )
                                          ]),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0,
                                      right: 15.0,
                                      top: 5.0,
                                      bottom: 15.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.my_location_rounded,
                                            size: 20,
                                            color: AppColors.greyMaterial[600],
                                          ),
                                          SizedBox(width: 5),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                80,
                                            child: Text(
                                              '${data['store_address']}',
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(.9),
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 20,
                                            color: AppColors.greyMaterial[600],
                                          ),
                                          SizedBox(width: 5),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                80,
                                            child: Text(
                                              '${data['store_location']}',
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(.9),
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_outlined,
                                            size: 20,
                                            color: AppColors.greyMaterial[600],
                                          ),
                                          SizedBox(width: 5),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                80,
                                            child: Text(
                                              '${data['created']}',
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.9),
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ));
                    feedsData.add(SizedBox(
                      height: 1.0,
                    ));
                  }
                } else {
                  feedsData.add(Stack(
                    alignment: AlignmentDirectional.topCenter,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          Constant.splashBg,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.store,
                                color: Colors.black.withOpacity(.4),
                                size: 150.0,
                              ),
                              Text(
                                '$_message',
                                style: TextStyle(
                                    color: Colors.black.withOpacity(.4),
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ));
                }

                if (_loadingMore) {
                  feedsData.add(SpinKitRing(
                    lineWidth: 4.0,
                    color: AppColors.indigoMaterial,
                    size: 30,
                  ));
                  feedsData.add(SizedBox(height: 15));
                }
                var widgets = Column(
                  children: feedsData,
                );
                return widgets;
              }),
            ],
          ),
        ),
        floatingActionButton: _showFAB
            ? FloatingActionButton.extended(
                onPressed: () {
                  if (widget.user[DatabaseHelper.KEY_NAME] == Constant.gestuser) {
                    return MyToast.showToast(context, "Please Login Or Create an Account");
                  }
                  addStore();
                },
                icon: const Icon(Icons.store),
                label: const Text('Add Store'),
                backgroundColor: AppColors.pinkMaterial,
              )
            : Container(),
      );
    }
  }

  addStore() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return CreateStoreDialog(completed: () {
            _getData();
          });
        });
  }

  updateStore(Map<String, dynamic> store) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return CreateStoreDialog(
              storeData: store,
              completed: () {
                _getData();
              });
        });
  }

  deleteStore(Map<String, dynamic> store) {
    String description = sprintf(
        LocalText.of(context).load('confirm_store_delete'),
        [store['store_name'], store['store_code']]);
    _alertDialog.confirm(
        context, LocalText.of(context).load('delete_warn'), description,
        onPressed: (_continue) {
      if (_continue) {
        _alertDialog.inputDialog(
            context, LocalText.of(context).load('password_hint'),
            keyboardType: TextInputType.text, onPressed: (text) async {
          if (text != null) {
            _alertDialog.loading(
                context, "Deleting store, please wait", Dialogs.GLOWING);
            final String password = text;
            var user = new CurrentUser();
            await user.getUser();
            NetworkUtil _netUtil = new NetworkUtil();
            await _netUtil.post(Constant.delete_store, context, body: {
              "owner": user.getId(),
              "password": password,
              "store": '${store['store_name']} (${store['store_code']})',
              "store_code": store['store_code'],
            }).then((value) async {
              _alertDialog.close(context);
              MyToast.showToast(context, value['message']);
              if (value['success'] == true) {
                stores = [];
                prefs.setString(Constant.storesPrefs, json.encode(stores));
                _loading = true;
                reloadState();
                _getData();
              }
            }).catchError((error) {
              _alertDialog.close(context);
              MyToast.showToast(context, "An Error Occurred");
              print("Error $error");
            });
          }
        });
      }
    });
  }

  openStore(store) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StorePage(
            storeData: store,
          ),
        ));
  }

  @override
  bool get wantKeepAlive => true;
}

class CreateStoreDialog extends StatefulWidget {
  CreateStoreDialog({this.storeData, @required this.completed});

  final Map<String, dynamic> storeData;
  final VoidCallback completed;

  @override
  _MyDialogState createState() => new _MyDialogState();
}

class _MyDialogState extends State<CreateStoreDialog> {
  bool _creatingStore = false, editing = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _storeNameController,
      _storeLocationController,
      _storeAddressController;

  String storeName = "", storeLocation = "", storeAddress = "";
  int storeID = 0;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> storeData = widget.storeData;
    if (storeData != null && storeData.isNotEmpty) {
      storeID = int.parse('${storeData['id']}');
      storeName = storeData['store_name'];
      storeLocation = storeData['store_location'];
      storeAddress = storeData['store_address'];
    }
    editing = storeID != 0;
    _storeNameController = TextEditingController(text: storeName);
    _storeLocationController = TextEditingController(text: storeLocation);
    _storeAddressController = TextEditingController(text: storeAddress);
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeLocationController.dispose();
    _storeAddressController.dispose();
    super.dispose();
  }

  reloadState() {
    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: LocalText.of(context).show(
        'add_store_title',
        style: TextStyle(
            color: AppColors.pinkMaterial,
            fontSize: 16,
            fontWeight: FontWeight.bold),
      ),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.always,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _storeNameController,
                decoration: InputDecoration(
                  labelText: LocalText.of(context).load('store_name_hint'),
                  icon: Icon(Icons.dynamic_feed),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _storeAddressController,
                decoration: InputDecoration(
                  labelText: LocalText.of(context).load('store_address_hint'),
                  icon: Icon(Icons.my_location),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _storeLocationController,
                decoration: InputDecoration(
                  labelText: LocalText.of(context).load('store_location_hint'),
                  icon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          child: LocalText.of(context).show('cancel_text',
              style: TextStyle(color: AppColors.greyMaterial[700])),
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(AppColors.greyMaterial[200])),
        ),
        ElevatedButton(
            child: _creatingStore
                ? SizedBox(
                    width: 35,
                    child: SpinKitRing(
                      lineWidth: 2.0,
                      color: AppColors.greyMaterial[50],
                      size: 15,
                    ),
                  )
                : editing
                    ? LocalText.of(context).show('update')
                    : LocalText.of(context).show('create'),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _creatingStore = true;
                reloadState();
                if (editing) {
                  updateStore();
                } else {
                  createStore();
                }
              }
            })
      ],
    );
  }

  createStore() async {
    var user = new CurrentUser();
    await user.getUser();
    NetworkUtil _netUtil = new NetworkUtil();
    print(user.getId());
    await _netUtil.post(Constant.add_store, context, body: {
      "store_name": _storeNameController.text,
      "owner": user.getId(),
      "store_address": _storeAddressController.text,
      "store_location": _storeLocationController.text,
    }).then((value) async {
      MyToast.showToast(context, value['message']);
      _creatingStore = false;
      reloadState();
      if (value['success'] == true) {
        widget.completed();
        Navigator.of(context).pop();
      }
    }).catchError((error) {
      MyToast.showToast(context, "An Error Occurred");
      print("Error $error");
    });
  }

  updateStore() async {
    var user = new CurrentUser();
    NetworkUtil _netUtil = new NetworkUtil();
    await _netUtil.post(Constant.update_store, context, body: {
      "id": storeID,
      "store_name": _storeNameController.text,
      "owner": user.getId(),
      "store_address": _storeAddressController.text,
      "store_location": _storeLocationController.text,
    }).then((value) async {
      MyToast.showToast(context, value['message']);
      _creatingStore = false;
      reloadState();
      if (value['success'] == true) {
        widget.completed();
        Navigator.of(context).pop();
      }
    }).catchError((error) {
      MyToast.showToast(context, "An Error Occurred");
      print("Error $error");
    });
  }
}
