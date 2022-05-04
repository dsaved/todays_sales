import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todays_sales/dbhandler/databaseHelper.dart';
import 'package:todays_sales/events/eventBus.dart';
import 'package:todays_sales/localization/LocalText.dart';
import 'package:todays_sales/pages/dashboard/SalesAgent.dart';
import 'package:todays_sales/pages/dashboard/StoreOwner.dart';
import 'package:todays_sales/pages/feedback/Feedback.dart';
import 'package:todays_sales/pages/login/login.dart';
import 'package:todays_sales/pages/profile/profilePage.dart';
import 'package:todays_sales/pages/store/un_sync_history.dart';
import 'package:todays_sales/resources/theme.dart' as appTheme;
import 'package:todays_sales/utils/constant.dart';
import 'package:todays_sales/utils/utils.dart';
import 'package:todays_sales/widgets/Dialogs.dart';
import 'package:todays_sales/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:package_info/package_info.dart';

import '../utils/constant.dart';
import '../widgets/toast.dart';

class MyHomePage extends StatefulWidget {
  static const String tag = "home-page";

  MyHomePage({Key key, this.data}) : super(key: key);
  final Map<String, dynamic> data;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  String name = "",
      email = "",
      image = "",
      phone = "",
      address = "",
      storeCode = "";
  Map<String, dynamic> userData = new Map();
  DatabaseHelper db;
  var _user;
  bool isLoading = false,
      hasData = false,
      _navOpened = false,
      isLoadingHistory = true,
      hasDataHistory = false;
  PackageInfo packageInfo;
  int _currentView = 0;
  EventBus eventBus = EventBus();
  Timer timer;

  PageController _pageController = PageController();

  @override
  void initState() {
    initAll();
    super.initState();
    db = new DatabaseHelper();
    syncSale();
    this.userData = widget.data;
    WidgetsBinding.instance.addObserver(this);
    eventBus.on<CoinUpdated>().listen((event) {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (timer.isActive) {
      timer.cancel();
    }
    super.dispose();
  }

  initAll() async {
    packageInfo = await PackageInfo.fromPlatform();
    await loadUser();
  }

  syncSale() {
    Future.delayed(Duration.zero, () {
      Utils.syncSales(db, context);
    });
    timer = Timer.periodic(Duration(seconds: 35), (timer) {
      Utils.syncSales(db, context);
    });
  }

  @override
  Future didChangeAppLifecycleState(AppLifecycleState state) async {
    await initAll();
  }

  loadUser() async {
    _user = await db.getUser();
    if (mounted)
      setState(() {
        this.name = _user[DatabaseHelper.KEY_NAME];
        this.phone = _user[DatabaseHelper.KEY_PHONE];
        this.userData = _user;
      });
  }

  List<Widget> _buildDrawerList(BuildContext context) {
    List<Widget> children = [];
    children
      ..addAll(_buildUserAccounts(context))
      ..addAll(_buildActions(context))
      ..addAll([new Divider()])
      ..addAll(_buildActionsSystem(context));
    return children;
  }

  List<Widget> _buildUserAccounts(BuildContext context) {
    return [
      UserAccountsDrawerHeader(
        decoration: BoxDecoration(
          color: appTheme.AppColors.indigoMaterial,
          image: new DecorationImage(
            fit: BoxFit.cover,
            colorFilter: new ColorFilter.mode(
                Colors.black.withOpacity(0.2), BlendMode.dstATop),
            image: AssetImage(
              Constant.navBarBg,
            ),
          ),
        ),
        accountName: Text(name),
        accountEmail: Text(phone),
        currentAccountPicture: new GestureDetector(
          onTap: () {
            if (_user['uid'] != 0) {
              openAccount(context);
            }
          },
          child: Stack(
            children: <Widget>[
              SpinKitPulse(
                color: Colors.white,
                size: 100.0,
              ),
              CircleAvatar(
                radius: 100.0,
                child: Icon(
                  Icons.person,
                  size: 35,
                ),
              )
            ],
          ),
        ),
      )
    ];
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      InkWell(
        child: Container(
          color: _currentView == 0 ? Colors.grey[200] : Colors.transparent,
          child: ListTile(
            selected: _currentView == 0 ? true : false,
            title: new Text(LocalText.of(context).load("home"),
                style: TextStyle(fontWeight: FontWeight.w500)),
            leading: Image.asset(
              Constant.todays_sales_icon_white,
              width: 25,
              height: 25,
              color: _currentView == 0
                  ? appTheme.AppColors.indigoMaterial
                  : appTheme.AppColors.grey[600],
            ),
            onTap: () => setView(0),
          ),
        ),
      ),
      InkWell(
        child: Container(
          color: _currentView == 1 ? Colors.grey[200] : Colors.transparent,
          child: ListTile(
            selected: _currentView == 1 ? true : false,
            title: new Text(LocalText.of(context).load("feedback"),
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w500)),
            leading: Icon(
              Icons.email,
            ),
            onTap: () => setView(1),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildActionsSystem(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: LocalText.of(context).show("system"),
      ),
      InkWell(
        child: ListTile(
          title: new Text(LocalText.of(context).load("account"),
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
          leading: Icon(
            Icons.person,
          ),
          onTap: () => openAccount(context),
        ),
      ),
      name == Constant.gestuser
          ? InkWell(
              highlightColor: appTheme.AppColors.greyMaterial[200],
              child: ListTile(
                title: new Text(LocalText.of(context).load("login"),
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w500)),
                leading: Icon(
                  Icons.exit_to_app,
                ),
                onTap: () => login(context),
              ))
          : InkWell(
              highlightColor: appTheme.AppColors.greyMaterial[200],
              child: ListTile(
                title: new Text(LocalText.of(context).load("logout"),
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w500)),
                leading: Icon(
                  Icons.power_settings_new,
                ),
                onTap: () => loginPage(context),
              )),
    ];
  }

  @override
  Widget build(BuildContext context) {
    Widget drawer = new Drawer(
      child: MyDrawer(
        child: ListView(
            padding: const EdgeInsets.only(top: 0.0),
            children: _buildDrawerList(context)),
        drawerState: (opened) {
          _navOpened = opened;
        },
      ),
    );

    return WillPopScope(
        onWillPop: () => onWillPop(),
        child: Scaffold(
          backgroundColor: appTheme.AppColors.greyMaterial[50],
          appBar: new AppBar(
            brightness: Brightness.dark,
            title: getTitle(_currentView),
            actions: [
              if (userData['type'] == 'sales_agent')
                IconButton(
                  onPressed: openUnSyncHistory,
                  icon: Icon(Icons.receipt),
                )
            ],
          ),
          body: PageView(
              controller: _pageController,
              children: <Widget>[
                userData['type'] == 'store_owner'
                    ? StoreOwner(
                        user: userData,
                        updated: (bool) {
                          if (bool == true) {
                            loadUser();
                          }
                        },
                      )
                    : SalesAgent(onStoreCode: (code) {
                        storeCode = code;
                        if (mounted) setState(() {});
                      }),
                Feedbacks(user: userData),
              ],
              physics: NeverScrollableScrollPhysics()),
          drawer: new SafeArea(child: drawer),
        ));
  }

  Future<bool> onWillPop() {
    if (_currentView != 0) {
      if (_navOpened) {
        Navigator.of(context).pop();
      }
      setView(0, pop: false);
      return Future.value(false);
    }
    return Future.value(true);
  }

  setView(int view, {pop = true}) {
    if (pop) {
      Navigator.of(context).pop();
    }
    if (_currentView == view) {
      return;
    }
    setState(() {
      _currentView = view;
      _pageController.jumpToPage(view);
    });
  }

  Widget getTitle(int view) {
    if (view == 0) {
      if (userData['type'] == 'store_owner') {
        return Text('My Stores');
      }
      return Text('Store $storeCode');
    } else if (view == 1) {
      return Text('Feedback');
    }
    return Container();
  }

  login(BuildContext context) async {
    var db = new DatabaseHelper();
    await db.deleteUsers();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ));
  }

  loginPage(BuildContext context) async {
    var dialogs = Dialogs();
    dialogs.confirm(context, LocalText.of(context).load('logout'),
        LocalText.of(context).load('confirm-logout'),
        onPressed: (confirmed) async {
      if (confirmed) {
        var db = new DatabaseHelper();
        var pref = await SharedPreferences.getInstance();
        pref.remove(Constant.storesPrefs);
        pref.remove(Constant.salesPrefs);
        pref.remove(Constant.salesStatsPrefs);
        pref.remove(Constant.storeDataPrefs);
        pref.remove(Constant.customersPrefs);
        pref.remove(Constant.agentsPrefs);
        pref.remove(Constant.storeCodePrefs);
        pref.remove(Constant.itemListPrefs);
        pref.remove(Constant.itemsListPrefs);
        await db.deleteUsers();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ));
      }
    });
  }

  openUnSyncHistory() async {
    if (name == Constant.gestuser) {
      return MyToast.showToast(context, "Please Login Or Create an Account");
    }
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UnSyncHistory(storeCode),
        ));
  }

  openAccount(BuildContext context) {
    if (name == Constant.gestuser) {
      return MyToast.showToast(context, "Please Login Or Create an Account");
    }
    Navigator.of(context).pop();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            user: _user,
            updated: (bool) {
              if (bool == true) {
                loadUser();
              }
            },
          ),
        ));
  }
}
