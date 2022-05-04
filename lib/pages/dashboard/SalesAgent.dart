import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todays_sales/localization/LocalText.dart';
import 'package:todays_sales/models/CurrentUser.dart';
import 'package:todays_sales/models/items.dart';
import 'package:todays_sales/network/network_util.dart';
import 'package:todays_sales/pages/store/customers.dart';
import 'package:todays_sales/pages/store/new_sale.dart';
import 'package:todays_sales/pages/store/sales_details.dart';
import 'package:todays_sales/resources/theme.dart';
import 'package:todays_sales/utils/constant.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

typedef StringCallback(String code);

class SalesAgent extends StatefulWidget {
  const SalesAgent({Key key, this.onStoreCode}) : super(key: key);
  final StringCallback onStoreCode;

  @override
  _SalesAgentState createState() => _SalesAgentState();
}

class _SalesAgentState extends State<SalesAgent> with WidgetsBindingObserver {
  Map<String, dynamic> store;
  List<dynamic> sales = [];
  Map<String, dynamic> pagination = Map();
  final ScrollController scrollController = ScrollController();
  TextEditingController _searchInputController;
  final money = new NumberFormat("GHS #,##0.00", "en_US");
  SharedPreferences prefs;
  String storeCode = '';
  CurrentUser _currentUser = new CurrentUser();

  NetworkUtil _netUtil = new NetworkUtil();
  bool socketConnected = false,
      _loading = true,
      _showFAB = true,
      _loadingMore = false,
      searched = false;
  int resultPerPage = 20, page = 1;
  String searchText = "";
  Timer _timer;
  String _saleTypeOption = "All Sales";

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    initData();
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        _showFAB = true;
        if (mounted) {
          setState(() {});
        }
      } else if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        _showFAB = false;
        if (mounted) {
          setState(() {});
        }
      }

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

  initData() async {
    await _currentUser.getUser();
    _searchInputController = new TextEditingController();
    prefs = await SharedPreferences.getInstance();
    storeCode = prefs.getString(Constant.storeCodePrefs);
    widget.onStoreCode(storeCode);
    _();
    _timer = Timer.periodic(Duration(minutes: 5), (timer) {
      _();
    });

    String storeDataPrefs = prefs.getString(
        Constant.storeDataPrefs + storeCode + '${_currentUser.getId()}');
    if (storeDataPrefs != null) {
      store = json.decode(storeDataPrefs);
      print(store);
      if (mounted) {
        setState(() {});
      }
    }

    String salesPrefs = prefs
        .getString(Constant.salesPrefs + storeCode + '${_currentUser.getId()}');
    if (salesPrefs != null) {
      _loading = false;
      sales = json.decode(salesPrefs);
      if (mounted) {
        setState(() {});
      }
      _getData(silent: true);
    } else {
      _getData();
    }
  }

  _() async {
    await _netUtil.post("${Constant.getItemCatalogs}", context,
        body: {'store_code': storeCode}).then((value) async {
      if (value['success'] == true) {
        var items = value['items'];
        prefs.setString(
            Constant.itemsListPrefs + storeCode, json.encode(items));
        await ItemsViewModel.loadItems(storeCode);
      }
    }).catchError((error) {
      print("Error $error");
    });
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
    params["store_code"] = storeCode;
    params["agent"] = '${_currentUser.getId()}';
    params["page"] = page;
    params["sale_type"] = _saleTypeOption;

    await _netUtil
        .post("${Constant.get_sales_agent_sales}", context, body: params)
        .then((value) {
          setState(() {
            _loading = false;
            _loadingMore = false;
          });
          pagination = value['pagination'];
          if (value['success'] == true) {
            if (more) {
              sales.insertAll(sales.length, value['sales']);
            } else {
              sales = value['sales'];
              store = value['store'];
              prefs.setString(
                  Constant.salesPrefs + storeCode + '${_currentUser.getId()}',
                  json.encode(sales));
              prefs.setString(
                  Constant.storeDataPrefs +
                      storeCode +
                      '${_currentUser.getId()}',
                  json.encode(store));
            }
            _loading = false;
            setState(() {});
          } else {
            store = value['store'];
            if (_saleTypeOption != 'All Sales') {
              sales = value['sales'];
            }
            prefs.setString(
                Constant.storeDataPrefs + storeCode + '${_currentUser.getId()}',
                json.encode(store));
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
    if (_timer.isActive) {
      _timer.cancel();
    }
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var data = store;

    return Scaffold(
      backgroundColor: AppColors.greyMaterial[100],
      body: ListView(
        controller: scrollController,
        children: [
          Stack(
            children: [
              Positioned(
                right: -50,
                top: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  child: SizedBox(
                    height: 150,
                    child: AspectRatio(
                      aspectRatio: 1.714,
                      child: Opacity(
                          opacity: 0.2,
                          child: Image.asset(Constant.card_bottom_left)),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -140,
                top: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  child: SizedBox(
                    height: 180,
                    child: AspectRatio(
                      aspectRatio: 1.714,
                      child: Opacity(
                          opacity: 0.3,
                          child: Image.asset(Constant.card_top_right)),
                    ),
                  ),
                ),
              ),
              if (store != null)
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
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 5.0, bottom: 15.0),
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
                                width: MediaQuery.of(context).size.width - 80,
                                child: Text(
                                  '${data['store_address']}',
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(.9),
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
                                width: MediaQuery.of(context).size.width - 80,
                                child: Text(
                                  '${data['store_location']}',
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(.9),
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
                                width: MediaQuery.of(context).size.width - 80,
                                child: Text(
                                  '${data['created']}',
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.9),
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Container(height: 120),
            ],
          ),
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${LocalText.of(context).load('sales-history')}',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ).inGridArea('header'),
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
                        hintText:
                            LocalText.of(context).load('sales-search-agent'),
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
                      sales = [];
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
                Padding(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, top: 2, bottom: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: Text(
                        "Filter sale type",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          letterSpacing: -0.2,
                          color: AppColors.greyMaterial.withOpacity(.5),
                        ),
                      ),
                      value: _saleTypeOption,
                      isExpanded: true,
                      onChanged: (String newValue) {
                        if (_saleTypeOption != newValue) {
                          _saleTypeOption = newValue;
                          _getData();
                        }
                        setState(() {});
                      },
                      icon: Icon(Icons.filter_list_outlined),
                      items: <String>['All Sales', 'Credit Sale', 'Cash Sale']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ).inGridArea('content'),
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
            ),
          sales != null && sales.length > 0
              ? Column(
                  children: [
                    Container(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: sales.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          var sale = sales[index];
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
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListTile(
                                      onTap: () {
                                        openSales(sale, store);
                                      },
                                      leading: Icon(
                                        Icons.receipt,
                                        size: 20,
                                        color: AppColors.pinkMaterial,
                                      ),
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              '${LocalText.of(context).load('sales-number')}'),
                                          Text(
                                            '${sale['sales_number']}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  '${LocalText.of(context).load('customer-phone')}'),
                                              Text('${sale['customer']}'),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  '${LocalText.of(context).load('total-price')}'),
                                              Text(
                                                  '${money.format(double.parse('${sale['total_price']}'))}'),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  '${LocalText.of(context).load('sales-date')}'),
                                              Text('${sale['datetime']}'),
                                            ],
                                          ),
                                        ],
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
                      '${LocalText.of(context).load('no-sales-available')}',
                      style: TextStyle(
                          color: AppColors.greyMaterial[500],
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )
        ],
      ),
      floatingActionButton: _showFAB
          ? FloatingActionButton.extended(
              onPressed: () {
                addSale(data);
              },
              icon: const Icon(Icons.add),
              label: Text('${LocalText.of(context).load('new-sale')}'),
              backgroundColor: AppColors.pinkMaterial,
            )
          : Container(),
    );
  }

  openSales(Map<String, dynamic> sale, Map<String, dynamic> store) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SalesDetailsPage(
              store: store,
              salesData: sale,
              isAgent: true,
              done: () {
                _getData();
              }),
        ));
  }

  addSale(Map<String, dynamic> store) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewSalePage(
            store: store,
          ),
        ));
  }

  openCustomers(String storeCode) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerPage(storeCode: storeCode),
        ));
  }
}
