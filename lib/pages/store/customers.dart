import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todays_sales/localization/LocalText.dart';
import 'package:todays_sales/network/network_util.dart';
import 'package:todays_sales/resources/theme.dart';
import 'package:todays_sales/utils/constant.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({Key key, @required this.storeCode}) : super(key: key);
  final String storeCode;

  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  List<dynamic> customers = [];
  Map<String, dynamic> pagination = Map();
  final ScrollController scrollController = ScrollController();
  TextEditingController _searchInputController;
  NetworkUtil _netUtil = new NetworkUtil();
  SharedPreferences prefs;
  bool socketConnected = false,
      _loading = true,
      _loadingMore = false,
      searched = false;
  int result_per_page = 20, page = 1;
  String searchText = "";

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    initAll();

    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels == 0) {
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
    super.initState();
  }

  initAll() async {
    _searchInputController = new TextEditingController();
    prefs = await SharedPreferences.getInstance();

    String customersPrefs = prefs.getString(Constant.customersPrefs+widget.storeCode);
    if (customersPrefs != null) {
      _loading = false;
      customers = json.decode(customersPrefs);
      setState(() {});
      _getData(silent: true);
    }else{
      _getData();
    }
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
    params["result_per_page"] = result_per_page;
    params["search"] = search;
    params["store_code"] = widget.storeCode;
    params["page"] = page;

    await _netUtil
        .post("${Constant.getCustomers}", context, body: params)
        .then((value) {
          setState(() {
            _loading = false;
            _loadingMore = false;
          });
          pagination = value['pagination'];
          if (value['success'] == true) {
            if (more) {
              customers.insertAll(customers.length, value['customers']);
            } else {
              customers = value['customers'];
              prefs.setString(Constant.customersPrefs+widget.storeCode, json.encode(customers));
            }
            _loading = false;
            setState(() {});
          } else {
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
        });
  }

  @override
  Future didChangeAppLifecycleState(AppLifecycleState state) async {
    if (mounted) await _getData(silent: true);
  }

  @override
  dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyMaterial[100],
      appBar: new AppBar(
        brightness: Brightness.dark,
        title: Text('${LocalText.of(context).load('customers')}'),
      ),
      body: ListView(
        controller: scrollController,
        children: [
          Padding(
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
                      border: Border.all(
                          width: 1, color: AppColors.greyMaterial[300]),
                      borderRadius: BorderRadius.circular(5.0)),
                  child: TextFormField(
                    autofocus: false,
                    controller: _searchInputController,
                    onSaved: (String value) {},
                    decoration: InputDecoration(
                        hintText: LocalText.of(context).load('customer-search'),
                        contentPadding:
                            EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
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
                      customers = [];
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
          ),
          if (_loading)
            SpinKitRing(
              lineWidth: 4.0,
              color: AppColors.indigoMaterial,
              size: 30,
            )
          else
            customers != null && customers.length > 0
                ? Column(
                    children: [
                      Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: customers.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            var customer = customers[index];
                            return Container(
                              margin: EdgeInsets.only(
                                  left: 6.0, right: 6.0, bottom: 4.0),
                              child: Card(
                                elevation: 1,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: -50,
                                      bottom: 0,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0)),
                                        child: SizedBox(
                                          height: 150,
                                          child: AspectRatio(
                                            aspectRatio: 1.714,
                                            child: Opacity(
                                                opacity: 0.04,
                                                child: Image.asset(
                                                    Constant.card_bottom_left)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        Icons.account_circle_rounded,
                                        size: 35,
                                        color: AppColors.pinkMaterial,
                                      ),
                                      title: Text(
                                        '${customer['name']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${customer['phone']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: TextButton(
                                        onPressed: () {
                                          launch('tel://${customer['phone']}');
                                        },
                                        child: Icon(
                                          Icons.call,
                                          size: 25.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (_loadingMore)
                        SpinKitRing(
                          lineWidth: 4.0,
                          color: AppColors.indigoMaterial,
                          size: 30,
                        ),
                      SizedBox(height: 15)
                    ],
                  )
                : Center(
                    child: SizedBox(
                      child: Text(
                        '${LocalText.of(context).load('no-customers-available')}',
                        style: TextStyle(
                            color: AppColors.greyMaterial[500],
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
        ],
      ),
    );
  }
}
